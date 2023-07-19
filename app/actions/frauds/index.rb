# frozen_string_literal: true
require "pry"

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
