# frozen_string_literal: true

module Flows
  class UiNodeComponent < ApplicationComponent
    include FlowsHelper

    BOOLEAN_ATTRIBUTES = %w[disabled readonly multiple checked required autofocus].freeze

    attr_reader :group, :id

    class Message
      attr_reader :id, :text, :type

      def initialize(message)
        @id = message["id"]
        @text = message["text"]
        @type = message["type"]
        @context = message["context"]
      end
    end

    def initialize(node, **options)
      @id = get_random_id
      @meta = node["meta"]
      @group = node["group"]
      @attributes = node["attributes"]
      is_back_button = is_back_node?(node)

      @messages = node["messages"].map do |message|
        Message.new(message)
      end

      @options = options
      @tag = get_tag
      @options[:tag] ||= @tag
      @options[:name] = get_name
      @options[:id] = @id
      @options[:formnovalidate] = true if is_back_button
      @options[:classes] = class_names(get_classes, "my-2", @options[:classes])
      @attributes.each do |key, value|
        if key == "node_type"
          next
        end
        @options[key.to_sym] = value
      end
      @label = get_label
    end

    def has_messages?
      @messages.length > 0
    end

    def get_name
      @attributes["name"] || @id
    end

    def get_tag
      _type = @type || @attributes["node_type"]
      if @attributes["type"].present? && @attributes["type"] == "submit" || @attributes["type"] == "button"
        return :button
      end
      _type
    end

    def get_classes
      case @tag
      when :button
        return "btn primary w-full"
      when "input"
      when "textarea"
      when "select"
      else
        return ""
      end
    end

    def get_label(**options)
      unless @meta.present? && @meta["label"].present?
        return
      end

      unless self_closing?
        return @meta["label"]["text"]
      end

      options[:tag] ||= :p
      options[:classes] = class_names("text-sm font-bold", options[:classes])
      ApplicationComponent.new(string: @meta["label"]["text"], **options)
    end
  end
end

def is_b?(obj)
  true?(obj) || false?(obj)
end

def true?(obj)
  obj == true || obj.to_s.downcase == "true"
end

def false?(obj)
  obj == false || obj.to_s.downcase == "false"
end

##
# Generates a random id.
# Returns:: An 8 character long random id.
def get_random_id
  (0...8).map { (65 + rand(26)).chr }.join
end
