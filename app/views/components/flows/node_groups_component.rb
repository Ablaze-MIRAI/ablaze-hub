# frozen_string_literal: true

class Flows::NodeGroupsComponent < ViewComponent::Base
  def initialize(flow:)
    @flow = flow
  end
end
