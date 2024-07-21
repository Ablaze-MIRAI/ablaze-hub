# frozen_string_literal: true

class FormSeparatorComponent < ApplicationComponent
  def call
    content_tag(:div, class: "relative") do
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
    content_tag(:div, class: "relative flex justify-center text-xs uppercase") do
      content_tag(:span, "OR", class: "px-2 bg-background text-muted-foreground")
    end
  end
end