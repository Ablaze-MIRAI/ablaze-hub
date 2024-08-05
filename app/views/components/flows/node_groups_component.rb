# frozen_string_literal: true

module Flows
  class NodeGroupsComponent < ApplicationComponent
    include FlowsHelper

    attr_reader :nodes, :options

    def initialize(nodes:, **options)
      @options = options
      @options[:tag] ||= :div
      @options[:id] = @options[:group] if @options[:group]
      @hide_back = options.delete(:hide_back) || false
      @method = @options[:method] || "post"
      @submit = @options[:submit] || nil

      @options[:action] = @options.delete(:submit) || @action
      @nodes = []
      nodes.each do |n|
        if is_back_node?(n) && @hide_back
          next
        end
        node = UiNodeComponent.new(n)
        @nodes << node
      end
    end
  end
end
