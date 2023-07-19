# frozen_string_literal: true

module App
  module Actions
    module Frauds
      class Index < ::App::Action
        def handle(*, response)
          response.body = self.class.name
        end
      end
    end
  end
end
