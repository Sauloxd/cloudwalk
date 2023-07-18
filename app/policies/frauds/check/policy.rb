# frozen_string_literal: true

module App
  module Policies
    module Frauds
      module Check 
        class Policy < ::App::Policies::Policy
          def self.call(*)
            [
              RejectOnGivenPeriodValue,
              RejectOnPredefinedHeuristics,
              RejectOnRepeatedChargebacks
            ].map { |predicate| predicate.call(*) }.compact
          end
        end
      end
    end
  end
end
