# frozen_string_literal: true

module Flows
  class FlowComponent < ApplicationComponent
    attr_reader :ui_messages, :options

    renders_many :items, types: {
      group: {
        renders: ->(flow, **options) { build_group(flow, **options) },
        as: :group
      },
      back: {
        renders: ->(flow, **options) {
          if flow["ui"]["action"].nil?
            return
          end
          node = helpers.get_back_node(flow)

          unless node.present?
            return
          end

          UiNodeComponent.new(node, **options)
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

    def initialize(**options)
      @options = options
      @options[:tag] ||= :div
      @options[:classes] = class_names("border border-gray-300 dark:border-gray-700 p-4 min-w-96 rounded-md", @options[:classes])
      @show = options[:show_condition] || true
      @ui_messages = []
    end

    def build_group(flow, **options)
      action = flow["ui"]["action"]
      method = flow["ui"]["method"]
      submit_path = options[:submit] || action
      nodes = flow["ui"]["nodes"]

      if nodes.nil? || nodes.empty?
        return
      end

      if options[:filter_only]
        nodes = filter_only(options[:filter_only], nodes)
      end

      if options[:filter_out]
        nodes = filter_out(options[:filter_out], nodes)
      end

      show_back = options[:show_back] || false

      # TODO: submit might missing
      NodeGroupsComponent.new(nodes: nodes, action: action, submit: submit_path, method: method, hide_back: !show_back, **options)
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
      nodes.reject do |node|
        groups.include?(node["group"])
      end
    end
  end
end
