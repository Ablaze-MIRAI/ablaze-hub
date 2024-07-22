# frozen_string_literal: true

class ButtonComponent < ApplicationComponent

  def initialize(button_text, **options)
    @button_text = button_text
    @options = options
    @options[:tag] ||= :button
    @options[:classes] = class_names("btn-primary", @options[:classes])
  end

  def call
    content_tag @options[:tag], @button_text, class: @options[:classes]
  end

end
