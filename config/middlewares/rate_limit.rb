# frozen_string_literal: true
require "pry"
require "pry-remote"

module Middlewares
  # Rate limit **every** request on this app based on a single token counter
  # This is a naive implementation, just to show how the token based algorithm works

  class RateLimit
    RATE_LIMIT_STATUS = 429
    ERROR_MESSAGE = "No tokens left, your request is now rate limited."
    LAST_UPDATE_TOKEN = 'last_update_time'
    TOKEN_KEY = 'ratelimit' # If we want to separate by request/by_ip/some_context, we need to create more keys, with a proper eviction policy
    MAX_TOKENS = 10.0 # can burst 10 requests in a second
    REFILL_RATE = 0.1 # refill 0.1 requests per second or 1 request every 10 seconds

    def initialize(app, redis)
      @app = app
      @redis = redis
      @redis.set(LAST_UPDATE_TOKEN, Time.now.to_i)
      @redis.set(TOKEN_KEY, MAX_TOKENS)
    end

    def call(env)
      refill_token
      if consume_token
        
        @app.call(env).tap do |status, headers, body|
          headers['X-Ratelimit-Remaining'] = @redis.get(TOKEN_KEY).to_f.round(2)
        end
      else
        [ RATE_LIMIT_STATUS, { 'X-Ratelimit-Remaining': @redis.get(TOKEN_KEY).to_f.round(2) }, [ ERROR_MESSAGE ] ]
      end
    end

    private

    # The following LUA script is the equivalent to this ruby script:
    # 
    # ``` ruby
    # curr_time = Time.now      
    # time = (curr_time - @last_refill_at).to_i
    # @tokens = [
    #   MAX_TOKENS, 
    #   @tokens + time * REFILL_RATE
    # ].min
    # @last_refill_at = curr_time
    # ```
    # 
    # Add tokens based on the difference between the last time it refilled the tokens
    # Cap the tokens on MAX_TOKENS
    # Update new timestamp
    # But since we need a "single source of truth", we need this logic inside and atomic operation in Redis. 
    # That's why we moved to a LUA script eval'd inside Redis.
    # Do keep in mind that, the more LUA scripts Redis process, the more our Redis becames a bottleneck
    # 

    def refill_token
      lua_script = <<~LUA
        local last_update_time =  redis.call('GET', KEYS[2]) 
        local current_time = tonumber(redis.call('TIME')[1])
        local refill_rate = tonumber(ARGV[1])
        local max_tokens = tonumber(ARGV[2])
        local curr_tokens = redis.call('GET', KEYS[1])
        local time_difference_seconds = current_time - last_update_time
        local result = math.min(
          max_tokens,
          curr_tokens + time_difference_seconds * refill_rate
        )

        redis.call('SET', KEYS[1], result)
        redis.call('SET', KEYS[2], current_time)
        return time_difference_seconds
      LUA
      
      redis_transaction(lua_script, [TOKEN_KEY, LAST_UPDATE_TOKEN], [REFILL_RATE, MAX_TOKENS])
    end

    def consume_token
      lua_script = <<~LUA
        local current_value = tonumber(redis.call('GET', KEYS[1]))
        if current_value and current_value >= 1 then
          redis.call('INCRBYFLOAT', KEYS[1], -1)
          return true
        else
          return false
        end
      LUA
      
      redis_transaction(lua_script, [TOKEN_KEY], [1])
    end


    def redis_transaction(lua_script, keys, args)
      @redis.watch(keys[0])
      @redis.eval(lua_script, keys, args)
    rescue Redis::CommandError => e
      puts e, "Another client modified the value during the transaction. Retry if needed."
    ensure
      @redis.unwatch
    end
  end
end