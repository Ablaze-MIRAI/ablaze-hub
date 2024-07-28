# frozen_string_literal: true

class FormSeparatorComponent < ApplicationComponent
  def initialize(text: "OR", **options)
    @text = text
    @only_line = options[:only_line] || false
    @text = "|" if @only_line
    @options = options
  end

  def call
    content_tag(:div, class: "relative my-2") do
      concat(separator_line)
      concat(separator_text)
    end
  end

  private

  def separator_line
    content_tag(:div, class: "absolute inset-0 flex items-center") do
      tag(:span, class: "w-full border-t", force_self_closing: true)
    end
  end

  def separator_text
    bg = @only_line ? "bg-transparent" : "bg-background"
    fg = @only_line ? "text-transparent" : "text-muted-foreground"
    content_tag(:div, class: "relative flex justify-center text-xs uppercase") do
      content_tag(:span, @text, class: "px-2 #{bg} #{fg}")
    end
  end
end