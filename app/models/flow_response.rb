# frozen_string_literal: true


class NodeGroup
  attr_reader :group, :nodes

  def initialize(group, nodes)
    @group = group
    @nodes = nodes
  end
end