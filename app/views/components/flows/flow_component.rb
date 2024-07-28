# frozen_string_literal: true

module Flows
  class FlowComponent < ApplicationComponent
    attr_reader :ui_messages, :options

    renders_many :items, types: {
      group: {
        renders: ->(**options) { build_group(**options) },
        as: :group
      },
      back: {
        renders: ->(**options) {
          node = helpers.get_back_node(@flow)
          unless node.present?
            return
          end

          default_nodes = filter_only(["default"], @nodes)
          all_nodes = [node] + default_nodes
          build_group(@flow, nodes: all_nodes, **options)
        },
        as: :back
      },
      divider: {
        renders: ->(**options) {
          if options[:show_condition] == false
            return
          end
          FormSeparatorComponent.new(**options)
        },
        as: :divider
      }
    }

    renders_many :messages

    def initialize(flow:, submit_path: nil, **options)
      @flow = flow
      @submit_path = submit_path
      @nodes = flow["ui"]["nodes"]
      @options = options
      @options[:tag] ||= :div
      @options[:classes] = class_names("border border-gray-300 dark:border-gray-700 p-4 min-w-96 rounded-md", @options[:classes])
      @show = options[:show_condition] || true
      @ui_messages = []
    end

    def build_group(nodes = nil, **options)
      action = @flow["ui"]["action"]
      method = @flow["ui"]["method"]
      submit_path = @submit_path || action
      show_back = options.delete(:show_back) || false
      _options = options.dup
      _options[:action] = action
      _options[:method] = method
      _options[:submit] = submit_path
      _options[:show_back] = show_back

      if nodes.present?
        return NodeGroupsComponent.new(nodes: nodes, hide_back: !show_back, **_options)
      end

      _nodes = @nodes.dup
      if _nodes.nil? || _nodes.empty?
        return
      end

      _filter_only = options.delete(:filter_only)
      _filter_out = options.delete(:filter_out)

      if _filter_only
        _nodes = filter_only(_filter_only, _nodes)
      end

      if _filter_out
        _nodes = filter_out(_filter_out, _nodes)
      end

      # TODO: submit might missing
      NodeGroupsComponent.new(nodes: _nodes, hide_back: !show_back, **_options)
    end

    def has_back_node?
      helpers.has_back_node?(@flow)
    end

    ##
    # Return only the groups that have nodes matching the given type
    # It will include the 'default' group by default
    # @param [Array] groups Array of strings representing the group names
    # @return [Array] Array of Node objects
    def filter_only(groups, nodes)
      has_node = false
      nodes.select do |node|
        has_node = groups.include?(node["group"])
        if has_node || node["group"] == "default"
          true
        end
      end

      unless has_node
        []
      end
    end

    ##
    # Return only the groups that do not have nodes matching the given type
    # It will include the 'default' group by default
    # @param [Array] groups Array of strings representing the group names
    # @return [Array] Array of Node objects
    def filter_out(groups, nodes)
      has_node = false
      nodes.select do |node|
        has_node = groups.include?(node["group"])
        if !has_node || node["group"] == "default"
          true
        end
      end

      if has_node
        []
      end
    end

    def has_groups(groups)
      filter_only(groups, @nodes).any?
    end
  end
end
