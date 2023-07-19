# frozen_string_literal: true

module App
  module Models
    class Transaction
      attr_reader :transaction_id, :transaction_amount, :transaction_date, :user_id
      
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
        true
      end

      def recomendation
        @recomendation ||= reject_reasons.empty? ? :approve : :deny
      end

      def reject_reasons
        @reject_reasons ||= ::App::Policies::Frauds::Check::Policy.call(self)
      end
    end
  end
end
