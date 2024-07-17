module FlowsHelper
  ##
  # Returns the style classes for a given type.
  def get_style_classes(type)
    case type
    when "submit"
      return "btn btn-primary"
    else
      return ""
    end
  end
end
