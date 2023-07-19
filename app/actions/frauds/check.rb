# frozen_string_literal: true

module App
  module Actions
    module Frauds
      class Check < ::App::Action
        def handle(request, response)
          params = {
            transaction_id: request.params[:transaction_id],
            merchant_id: request.params[:merchant_id],
            user_id: request.params[:user_id],
            card_number: request.params[:card_number],
            transaction_date: request.params[:transaction_date],
            transaction_amount: request.params[:transaction_amount],
            device_id: request.params[:device_id],
            has_cbk: request.params[:has_cbk],
          }

          transaction = ::App::Models::Transaction.new(**params)

          if transaction.save
            response.body = {
              transaction_id: transaction.transaction_id,
              recommendation: transaction.recomendation,
              reasons: transaction.reject_reasons
            }.to_json
          end
        end
      end
    end
  end
end
