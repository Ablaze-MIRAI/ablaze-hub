class User < ApplicationRecord
  has_one_attached :avatar

  def self.find_or_create(identity)
    user = User.find_by(ory_id: identity["id"])
    if user.nil?
      user = User.create(
        ory_id: identity["id"],
      )
    end
    user
  end
end
