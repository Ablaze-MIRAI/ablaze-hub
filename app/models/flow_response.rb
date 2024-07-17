# frozen_string_literal: true

class Message
  attr_reader :id, :text, :type

  def initialize(message)
    @id = message["id"]
    @text = message["text"]
    @type = message["type"]
    @context = message["context"]
  end
end

class NodeGroup
  attr_reader :group, :nodes

  def initialize(group, nodes)
    @group = group
    @nodes = nodes
  end
end