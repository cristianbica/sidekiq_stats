module SidekiqStats
  class ApplicationController < ActionController::API
    include ActionController::MimeResponds
    # protect_from_forgery with: :exception
  end
end
