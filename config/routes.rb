# frozen_string_literal: true

module App
  class Routes < Hanami::Routes
    root to: "frauds.check"
    post "/frauds/check", to: "frauds.check"
  end
end
