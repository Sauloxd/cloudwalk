# frozen_string_literal: true

module App
  module Policies
    class Policy
      class UnauthorizedError < StandardError; end
      
      def self.authorize(*)
        call(*)
      end
    end
  end
end
