# frozen_string_literal: true

require "hanami"
require "hanami/middleware/body_parser"
require "pry"
require "redis"
require_relative "./middlewares/rate_limit"
require_relative "./setup_redis_with_csv_data"

module App
  class App < Hanami::App
    $REDIS = Redis.new(host: 'redis', port: 6379)

    # This happens everytime app boot, and only once.
    # This is a bad idea for a production app, where we have a proper datastorage for all transactions made
    # Also, I'm reusing Redis here as a *hack* as I'm not fully confident in adding/managing another DB using Hanami.
    # Since the dataset provided is small (260kb) and we can search on redis based on a predefined key, we can get away with this solution
    SetupRedisWithCSVData.call($REDIS)
    config.middleware.use ::Middlewares::RateLimit, $REDIS
    config.middleware.use Hanami::Middleware::BodyParser, :json
  end
end
