# frozen_string_literal: true

class SubheadComponent < ApplicationComponent
  renders_one :header, -> (**options) do
    options[:tag] ||= :h2
    options[:classes] = class_names("text-2xl font-bold", options[:classes])
    ApplicationComponent.new(**options)
  end

  renders_one :description

  def initialize(**options)
    @options = options

    @options[:tag] ||= :div
    @options[:classes] = class_names("mb-4", @options[:classes])
  end

end
