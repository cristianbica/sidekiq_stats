require_dependency "sidekiq_stats/application_controller"
require "sidekiq/api"

module SidekiqStats
  class StatsController < ApplicationController
    def show
      respond_to do |format|
        format.json { render json: as_json }
        format.influxdb { render plain: as_influxdb }
      end
    end

    private

    def as_json
      data.map do |line|
        line[:tags].merge(line[:values])
      end
    end

    def as_influxdb
      data.map do |line|
        [
          "sidekiq_stats,",
          line[:tags].map { |k, v| "#{k}=#{v}" }.join(","),
          " ",
          line[:values].map { |k, v| "#{k}=#{v}" }.join(","),
        ].join
      end.join("\n")
    end

    def data
      lines = []
      lines << {
        tags: { app: app_name, env: Rails.env, global: "yes" },
        values: raw_data[:stats]
      }
      raw_data[:queues].each do |queue_data|
        lines << {
          tags: { app: app_name, env: Rails.env, global: "no", queue: queue_data[:name] },
          values: queue_data.except(:name)
        }
      end
      lines
    end

    def app_name
      Rails.application.class.parent_name
    end

    def raw_data
      @raw_data ||= {
        stats: compute_stats,
        queues: compute_queues
      }
    end

    def compute_stats
      {
        processed: sidekiq_stats.processed,
        processing: sidekiq_stats.workers_size,
        enqueued: sidekiq_stats.enqueued,
        failed: sidekiq_stats.failed,
        scheduled: sidekiq_stats.scheduled_size,
        retring: sidekiq_stats.retry_size,
        dead: sidekiq_stats.dead_size,
        workers_available: workers_available,
        workers_busy: workers_busy,
        workers_usage: (workers_available > 0 && workers_busy / workers_available || 0.0).round(2),
        latency: (sidekiq_queues.map(&:latency).max || 0.0).round(2),
        max_worktime: (sidekiq_jobs.map { |j| Time.now.to_i - j["run_at"] }.max || 0.0).round(2)
      }
    end

    def compute_queues
      sidekiq_queues.map do |queue|
        {
          name: queue.name,
          processing: sidekiq_jobs.count { |j| j["queue"] == queue.name },
          enqueued: queue.size,
          latency: queue.latency.round(2)
        }
      end
    end

    def sidekiq_stats
      @sidekiq_stats ||= Sidekiq::Stats.new
    end

    def sidekiq_processes
      @sidekiq_processes ||= Sidekiq::ProcessSet.new
    end

    def sidekiq_queues
      @sidekiq_queues ||= Sidekiq::Queue.all
    end

    def sidekiq_jobs
      @sidekiq_jobs ||= Sidekiq::Workers.new.to_a.map(&:last)
    end

    def workers_available
      sidekiq_processes.map { |p| p["concurrency"] }.inject(0.0, &:+)
    end


    def workers_busy
      sidekiq_processes.map { |p| p["busy"] }.inject(0.0, &:+)
    end
  end
end
