# frozen_string_literal: true

module App
  module Policies
    module Frauds
      module Check 
        # Objective from question: Reject transaction if a user had a chargeback before
        # (note that this information does not comes on the payload. The chargeback data is received days after the transaction was approved)

        class RejectOnRepeatedChargebacks
          def self.call(transaction)
            user_id = transaction.user_id
            chargebacks = ::App::Models::Transaction.chargeback_count_for(user_id: user_id)

            unless chargebacks.nil?
              "Invalid due to repeated chargebacks. User #{user_id} already has #{chargebacks} chargebacks"
            end
          end
        end
      end
    end
  end
end

