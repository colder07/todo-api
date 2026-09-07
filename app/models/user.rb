class User < ApplicationRecord
  has_many :todos

  validates :email, presence: true, uniqueness: true
end
