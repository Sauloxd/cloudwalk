# frozen_string_literal: true
require_relative './concerns/allow_amount_on_period_configuration'

module App
  module Policies
    module Frauds
      module Check 
        # Reject transactions above a certain amount in a given period;

        class RejectOnGivenPeriodValue
          extend AllowAmountOnPeriodConfiguration

          allow from: '22:00', to: '03:00', max_amount: 570.43
          allow from: '19:00', to: '22:00', max_amount: 1366.69

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