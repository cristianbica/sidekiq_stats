module SidekiqStats
  class Engine < ::Rails::Engine
    isolate_namespace SidekiqStats
    config.generators.api_only = true

    Mime::Type.register "text/influxdb", :influxdb
  end
end
