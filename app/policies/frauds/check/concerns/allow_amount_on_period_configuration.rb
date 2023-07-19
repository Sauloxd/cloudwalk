# frozen_string_literal: true

module AllowAmountOnPeriodConfiguration
  def allow(*args)
    @@config ||= []
    @@config.push(*args)
  end

  def validate_with_error(amount:, timestamp:)
    # All timestamps are set to UTC, that way we avoid comparing different timezones by mistake
    time = Time.parse(timestamp)
    invalid_rule = @@config.find do |rule|
      from = Time.parse(rule[:from], time)
      to = Time.parse(rule[:to], time)

      in_time_range = begin
        if from > to
          time > from || time < to
        else
          time.between? from, to
        end
      end

      in_time_range && amount.to_f >= rule[:max_amount]
    end

    format_error(invalid_rule, amount, timestamp) unless invalid_rule.nil?
  end

  private

  def format_error(rule, amount, timestamp)
    "Invalid due to transaction amount #{amount} above threshold #{rule[:max_amount]} for this time period - from #{rule[:from]}, to #{rule[:to]}, timestamp: #{timestamp}"
  end
end