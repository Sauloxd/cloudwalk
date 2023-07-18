# frozen_string_literal: true
require "pry"

module App
  module Actions
    module Frauds
      class Check < ::App::Action
        def handle(*, response)
          authorize!(*)

          response.body = self.class.name
        end
      end
    end
  end
end
