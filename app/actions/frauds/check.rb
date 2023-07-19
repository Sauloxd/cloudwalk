# frozen_string_literal: true
require "pry"

module App
  module Actions
    module Frauds
      class Check < ::App::Action
        def handle(request, response)
          errors = authorize(request)
          recomendation = errors.empty? ? "approve" : "deny"

          response.body = {
            transaction_id: request.params[:transaction_id],
            recommendation: recomendation,
            reasons: errors,  
          }.to_json
        end
      end
    end
  end
end
