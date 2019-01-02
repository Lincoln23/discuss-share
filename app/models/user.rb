class User < ApplicationRecord
  attr_accessor :remember_token
  # before_save {self.email = email.downcase} # Don't need self keyword on the RHS
  before_save {email.downcase!}
  validates :name, presence: true, length: {maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: 255}, format: VALID_EMAIL_REGEX, uniqueness: {case_sensitive: false}

  has_secure_password
  validates :password, presence: true, length: {minimum: 6} #:password comes from has_secure_password, it is a virtual attribute

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : #uses the minimum cost parameter in tests and a normal (high) cost parameter in production
               BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost) #string is to be hashed and cost is the parameter that determines the computational cost to calculate the hash
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end
  def remember
    self.remember_token = User.new_token
    # self.remember_digest = User.digest(remember_token) doesn't work b/c of line 10
    # self.save
    update_attribute(:remember_digest, User.digest(remember_token)) # update_attribute bypasses validation b/c no access to user's password
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(self.remember_digest).is_password?(remember_token)
  end

end
