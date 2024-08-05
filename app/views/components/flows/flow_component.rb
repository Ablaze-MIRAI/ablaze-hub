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

          build_group(@flow, nodes: [node], show_back: true, **options)
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

    def initialize(flow:, submit_path: nil, **options)
      @flow = flow
      @nodes = flow["ui"]["nodes"]
      @action = flow["ui"]["action"]
      @submit = submit_path || @action

      @options = options
      @options[:tag] ||= :form
      @options[:method] ||= flow["ui"]["method"] || "post"
      @options[:classes] = class_names("border border-gray-300 dark:border-gray-700 p-4 min-w-96 rounded-md", @options[:classes])
      @show = options[:show_condition] || true
      @ui_messages = []

      if @action == nil
        raise "The action attribute is required for the NodeGroupsComponent"
      end

      if @submit != @action
        @action_url = ApplicationComponent.new(tag: :input, type: :hidden, name: :action_url, value: @action)
      else
        @action_url = nil
      end
    end

    def build_group(nodes = nil, **options)
      show_back = options.delete(:show_back) || false
      _options = options.dup

      if nodes.present?
        return NodeGroupsComponent.new(nodes: nodes, hide_back: !show_back, **_options)
      end

      _nodes = @nodes.dup
      if _nodes.nil? || _nodes.empty?
        return
      end

      _filter_only = _options.delete(:filter_only)
      _filter_out = _options.delete(:filter_out)

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
    # @param [Array] groups Array of strings representing the group names
    # @return [Array] Array of Node objects
    def filter_only(groups, nodes)
      nodes.select do |node|
        groups.include?(node["group"])
      end
    end

    ##
    # Return only the groups that do not have nodes matching the given type
    # @param [Array] groups Array of strings representing the group names
    # @return [Array] Array of Node objects
    def filter_out(groups, nodes)
      nodes.select do |node|
        !groups.include?(node["group"])
      end
    end

    def has_groups(groups)
      filter_only(groups, @nodes).any?
    end
  end
end
