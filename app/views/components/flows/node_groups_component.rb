# frozen_string_literal: true

module Flows
  class NodeGroupsComponent < ApplicationComponent
    attr_reader :nodes, :options

    def initialize(nodes:, **options)
      @options = options
      @options[:tag] ||= :form
      @method = @options[:method] || "post"
      @submit = @options[:submit] || nil
      @action = @options[:action] || nil
      if @action == nil
        raise "The action attribute is required for the NodeGroupsComponent"
      end

      if @submit != @action
        @action_url = ApplicationComponent.new(tag: :input, type: :hidden, name: :action_url, value: @action)
      end

      @options[:action] = @options.delete(:submit) || @action
      @nodes = []
      nodes.each do |n|
        node = UiNodeComponent.new(n)
        @nodes << node
      end
    end
  end
end
