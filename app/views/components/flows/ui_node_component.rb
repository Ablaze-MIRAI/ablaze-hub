# frozen_string_literal: true

module Flows
  class UiNodeComponent < ApplicationComponent
    attr_reader :group, :id

    renders_one :node_label, -> (**options) do
      unless @meta.present? && @meta["label"].present?
        return
      end

      unless self_closing?
        return @meta["label"]["text"]
      end

      options[:tag] ||= :span
      options[:classes] = class_names("text-sm font-bold", options[:classes])
      ApplicationComponent.new(**options)
    end

    renders_many :messages

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

      @messages = node["messages"].map do |message|
        Message.new(message)
      end

      @options = options
      @tag = get_tag
      @options[:tag] ||= @tag
      @options[:name] = get_name
      @options[:id] = @id
      @options[:classes] = class_names(@options[:classes]) if @options[:classes].present?
      @attributes.each do |key, value|
        if key == "node_type"
          next
        end
        @options[key.to_sym] = value
      end
    end

    def has_label?
      @meta["label"].present?
    end

    def has_messages?
      @messages.length > 0
    end

    def get_name
      @attributes["name"] || @id
    end

    def get_tag
      @type || @attributes["node_type"]
    end

    ##
    # @param attribute - A key value pair
    def get_attr(attribute)
      key, value = attribute

      if is_b?(value)
        return true?(value) ? "#{key}" : nil
      end

      if value.nil? || value.empty?
        return nil
      end

      "#{key}=#{value}"
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
