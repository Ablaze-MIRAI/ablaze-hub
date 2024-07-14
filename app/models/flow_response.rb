# frozen_string_literal: true

class Message
  attr_reader :id, :text, :type

  def initialize(message)
    @id = message["id"]
    @text = message["text"]
    @type = message["type"]
  end
end

class Node
  attr_reader :node, :meta, :name, :node_type, :type, :required, :autocomplete, :disabled, :value, :group, :messages, :label
  attr_writer :label

  def initialize(node)
    @node = node
    @meta = node["meta"]
    attributes = node["attributes"]
    @name = attributes["name"]
    @node_type = node["type"]
    @type = attributes["type"]
    @required = attributes["required"]
    @autocomplete = attributes["autocomplete"]
    @disabled = attributes["disabled"]
    @value = attributes["value"] if attributes["value"]
    @group = node["group"]
    @messages = node["messages"].map do |message|
      Message.new(message)
    end
  end

  private

  def set_label
    @label = @meta["label"] if @meta["label"]
  end
end

class NodeGroup
  attr_reader :group, :nodes

  def initialize(group, nodes)
    @group = group
    @nodes = nodes
  end
end

class FlowResponse
  attr_reader :is_active, :action, :method, :nodes, :node_groups, :submit_path, :ui_messages

  def initialize(flow, submit_path = nil)
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
      Node.new(node)
    end

    node_groups = {}
    @nodes.each do |node|
      group = node.group
      if group
        if group === "default" || group === "profile"
          group = "default"
        end
        node_groups[group] = [] unless node_groups[group]
        node_groups[group] << node
      end
    end

    @node_groups = convert_to_node_groups(node_groups)
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

  def convert_to_node_groups(node_groups)
    groups = []
    node_groups.each do |group, nodes|
      groups << NodeGroup.new(group, nodes)
    end
    groups
  end
end
