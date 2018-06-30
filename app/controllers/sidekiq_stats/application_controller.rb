module SidekiqStats
  class ApplicationController < ::ApplicationController
    include ActionController::MimeResponds
    # protect_from_forgery with: :exception
  end
end
