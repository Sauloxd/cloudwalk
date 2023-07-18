# frozen_string_literal: true

module App
  module Policies
    class Policy
      class UnauthorizedError < StandardError; end

      def self.authorize!(*)
        reject_reasons = call(*)
        unless reject_reasons.empty?
          raise UnauthorizedError, reject_reasons
        end
      end
    end
  end
end
