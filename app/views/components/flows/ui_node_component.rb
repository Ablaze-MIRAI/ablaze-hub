# frozen_string_literal: true

class Flows::UiNodeComponent < ViewComponent::Base
  def initialize(node:)
    @node = node
    @meta = node["meta"]
    attributes = node["attributes"]
    @name = attributes["name"]
    @type = attributes["type"]
    @required = attributes["required"]
    @autocomplete = attributes["autocomplete"]
    @disabled = attributes["disabled"]
    @value = if attributes["value"] then attributes["value"] else nil end

    @messages = node["messages"]
  end

end
