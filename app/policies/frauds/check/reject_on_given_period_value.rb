# frozen_string_literal: true
require_relative './concerns/allow_amount_on_period_configuration'

module App
  module Policies
    module Frauds
      module Check 
        # Reject transactions above a certain amount in a given period;

        class RejectOnGivenPeriodValue
          extend AllowAmountOnPeriodConfiguration

          allow from: '22:00', to: '06:00', max_amount: 2000
          allow from: '06:00', to: '09:00', max_amount: 10000
          allow from: '09:00', to: '18:00', max_amount: 50000
          allow from: '18:00', to: '22:00', max_amount: 10000

          def self.call(transaction)
            amount = transaction.transaction_amount
            timestamp = transaction.transaction_date

            validate_with_error(amount: amount, timestamp: timestamp)
          end
        end
      end
    end
  end
end