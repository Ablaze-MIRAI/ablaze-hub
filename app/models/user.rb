class User < ApplicationRecord
  has_one_attached :avatar

  def self.find(identity)

  end
end
