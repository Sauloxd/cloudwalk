# frozen_string_literal: true

module App
  module Scopes
    module Transaction
      def chargeback_count_for(user_id:)
        $REDIS.get("chargebacks:#{user_id}")
      end

      def last_user_transaction_at(user_id:)
        $REDIS.get("last_user_transaction_at:#{user_id}")
      end
    end
  end
end
