# Example JSON node object:
#{
#  "type": "input",
#  "group": "default",
#  "attributes": {
#    "name": "traits.email",
#    "type": "email",
#    "required": true,
#    "autocomplete": "email",
#    "disabled": false,
#    "node_type": "input"
#  },
#  "messages": [
#
#  ],
#  "meta": {
#    "label": {
#      "id": 1070002,
#      "text": "E-Mail",
#      "type": "info",
#      "context": {
#        "title": "E-Mail"
#      }
#    }
#  }
#}

module FlowsHelper
  ##
  # Generates the HTML for a flow node.
  # +node+:: The json node object.
  def get_input_node(node)
    meta = node["meta"]
    attributes = node["attributes"]
    name = attributes["name"]
    type = attributes["type"]
    required = attributes["required"]
    autocomplete = attributes["autocomplete"]
    disabled = attributes["disabled"]
    value = if attributes["value"] then attributes["value"] else nil end

    messages = node["messages"]

    html = ""
    html += "<div>" if messages.length > 0
    messages.each do |message|
      html += "<p>#{message["text"]}</p>"
    end
    html += "</div>" if messages.length > 0
    html += "<label for='#{name}'>#{meta["label"]["text"]}</label>" if meta["label"]
    html += "<input type='#{type}' name='#{name}' id='#{name}'"
    html += " required" if required
    html += " autocomplete='#{autocomplete}'" if autocomplete
    html += " disabled" if disabled
    html += " value='#{value}'" if value
    html += ">"

    html.html_safe
  end
end
