# frozen_string_literal: true

class Flows::FlowComponent < ViewComponent::Base
  attr_reader :is_active, :action, :method, :nodes, :submit_path, :ui_messages

  def initialize(flow:, submit_path: nil)
    @is_active = validate_flow(flow)

    unless @is_active
      return
    end

    @action = flow["ui"]["action"]
    @method = flow["ui"]["method"]
    @submit_path = submit_path || @action
    @ui_messages = []
    if flow["ui"]["messages"]
      @ui_messages = flow["ui"]["messages"].map do |message|
        Message.new(message)
      end
    end

    @nodes = flow["ui"]["nodes"].map do |node|
      Flows::UiNodeComponent.new(node)
    end
  end

  ##
  # Return only the groups that have nodes matching the given type
  # @param [Array] groups - Array of strings representing the group names
  # @return [Array] - Array of Node objects
  def filter_only(groups)
    @nodes.select do |node|
      groups.include?(node.group)
    end
  end

  ##
  # Return only the groups that do not have nodes matching the given type
  # @param [Array] groups - Array of strings representing the group names
  # @return [Array] - Array of Node objects
  def filter_out(groups)
    @nodes.reject do |node|
      groups.include?(node.group)
    end
  end

  def get_group(nodes, classes: nil, title: nil)
    Flows::NodeGroupsComponent.new(
      nodes,
      @method,
      @action,
      submit_path: @submit_path,
      classes: classes,
      title: title
    )
  end

  private

  def validate_flow(flow)
    if flow.nil?
      false
    end

    if flow["ui"].nil?
      false
    end

    if flow["ui"]["nodes"].nil?
      false
    end
    true
  end
end
