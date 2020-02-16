class User < ApplicationRecord
  validates :push_token, presence: true 
end
