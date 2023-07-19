# auto_register: false
# frozen_string_literal: true

require "hanami/action"

module App
  class Action < Hanami::Action
    def authorize(args)
      policy_name = "::#{self.class.name.gsub("Actions", "Policies")}::Policy"
      policy_class = Object.const_get(policy_name)
      policy_class.authorize(args)
    end
  end
end
