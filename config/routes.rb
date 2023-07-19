# frozen_string_literal: true

module App
  class Routes < Hanami::Routes
    root to: "frauds.index"
    post "/frauds/check", to: "frauds.check"
  end
end
