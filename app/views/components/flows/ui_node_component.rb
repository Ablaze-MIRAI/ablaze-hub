# frozen_string_literal: true

class Flows::UiNodeComponent < ViewComponent::Base
  def initialize(node)
    @messages = node.messages
    @meta = node.meta
    @node_type = node.node_type
    @name = node.name
    @type = node.type
    @required = node.required
    @autocomplete = node.autocomplete
    @disabled = node.disabled
    @value = node.value
    @group = node.group
  end
end
