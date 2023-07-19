# frozen_string_literal: true

module App
  module Policies
    module Frauds
      module Check 
        class Policy
          def self.call(*)
            [
              RejectOnGivenPeriodValue,
              RejectOnRepeatedTransactions,
              RejectOnRepeatedChargebacks
            ].map { |predicate| predicate.call(*) }.compact
          end
        end
      end
    end
  end
end
