class User::CreateWithPushToken
  attr_reader :user, :push_token

  def initialize(push_token)
    @push_token = push_token
    @user = User.find_by(push_token: push_token)

    freeze
  end

  def create
    return user if user.present?
    
    User.create(push_token: push_token)
  end
end