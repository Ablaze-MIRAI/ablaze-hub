module FlowsHelper
  ##
  # Generates a random id.
  # Returns:: An 8 character long random id.
  def get_random_id
    (0...8).map { (65 + rand(26)).chr }.join
  end

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
