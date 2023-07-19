# frozen_string_literal: true

module App
  module Policies
    module Frauds
      module Check 
        class RejectOnRepeatedTransactions
          def self.call(*)
            "Invalid due to reasons"
            nil
          end
        end
      end
    end
  end
end
