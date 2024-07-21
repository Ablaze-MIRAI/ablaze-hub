# frozen_string_literal: true

class ApplicationComponent < ViewComponent::Base
  SELF_CLOSING_TAGS = [:area, :base, :br, :col, :embed, :hr, :img, :input, :link, :meta, :param, :source, :track, :wbr].freeze

  def initialize(tag: nil, classes: nil, **options)
    @tag = tag
    @classes = classes
    @options = options
  end

  def merge_attributes(*args)
    args = Array.new(2) { Hash.new } if args.compact.blank?
    hashed_args = args.map { |el| el.presence || {} }

    hashed_args.first.deep_merge(hashed_args.second) do |_key, val, other_val|
      val + " #{other_val}"
    end
  end

  def call
    if SELF_CLOSING_TAGS.include?(@tag)
      tag(@tag, merge_attributes(@options, class: @classes))
    else
      content_tag(@tag, content, merge_attributes(@options, class: @classes))
    end
  end
end
