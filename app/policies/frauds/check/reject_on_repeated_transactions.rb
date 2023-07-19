# frozen_string_literal: true

module App
  module Policies
    module Frauds
      module Check 
        # Reject transaction if user is trying too many transactions in a row

        class RejectOnRepeatedTransactions
          THRESHOLD_IN_SECONDS = 5 * 60 # 5 minutes

          def self.call(transaction)
            user_id = transaction.user_id
            last_transaction_at = ::App::Models::Transaction.last_user_transaction_at(user_id: user_id)

            return if last_transaction_at.nil?

            seconds_since_last_transaction = Time.now.to_i - Time.parse(last_transaction_at).to_i

            if seconds_since_last_transaction < THRESHOLD_IN_SECONDS
              "Invalid due to user #{user_id} transactioning too soon - last transaction was #{seconds_since_last_transaction} seconds ago."
            end
          end
        end
      end
    end
  end
end
