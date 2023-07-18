# frozen_string_literal: true

require "hanami"
require "pry"
require "redis"
require_relative "./middlewares/rate_limit"

module App
  class App < Hanami::App
    $REDIS = Redis.new(host: 'redis', port: 6379)

    config.middleware.use ::Middlewares::RateLimit, $REDIS
  end
end
