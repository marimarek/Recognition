class User < ActiveRecord::Base
  has_many :digits, dependent: :destroy

  before_save { name.downcase! }

  validates :name, presence: true, length: { minimum: 3, maximum: 20 }, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }

  has_secure_password
end
