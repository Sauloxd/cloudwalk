# frozen_string_literal: true

module App
  module Models
    class Transaction
      extend ::App::Scopes::Transaction

      attr_reader :transaction_id,
                  :merchant_id,
                  :user_id,
                  :card_number,
                  :transaction_date,
                  :transaction_amount,
                  :device_id,
                  :has_cbk,
                  :recomendation,
                  :reject_reasons
      
      def initialize(
        transaction_id:,
        merchant_id:,
        user_id:,
        card_number:,
        transaction_date:,
        transaction_amount:,
        device_id:,
        has_cbk:
      )
        @transaction_id = transaction_id
        @merchant_id = merchant_id
        @user_id = user_id
        @card_number = card_number
        @transaction_date = transaction_date
        @transaction_amount = transaction_amount
        @device_id = device_id
        @has_cbk = has_cbk
      end

      def save
        if valid?
          $REDIS.set(transaction_id, serialized_json)
          $REDIS.set("last_user_transaction_at:#{user_id}", Time.now)
        else
          false
        end
      end

      private

      def valid?
        @reject_reasons = ::App::Policies::Frauds::Check::Policy.call(self)
        @recomendation = reject_reasons.empty? ? :approve : :deny
      end

      def serialized_json
        {
          transaction_id: transaction_id,
          merchant_id: merchant_id,
          user_id: user_id,
          card_number: card_number,
          transaction_date: transaction_date,
          transaction_amount: transaction_amount,
          device_id: device_id,
          has_cbk: has_cbk,
          reject_reasons: reject_reasons,
          recomendation: recomendation
        }.to_json
      end
    end
  end
end
