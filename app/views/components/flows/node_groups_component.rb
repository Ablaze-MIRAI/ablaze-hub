# frozen_string_literal: true

class Flows::NodeGroupsComponent < ViewComponent::Base
  renders_many :nodes, "node"
  renders_one :title
  def initialize(
    nodes,
    method,
    action_url,
    submit_path: nil,
    classes: nil,
    title: nil
  )
    @nodes = nodes
    @submit_path = submit_path
    @method = method
    @action_url = action_url
    @classes = classes
    @title = title
  end
end
