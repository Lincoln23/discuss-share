class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save :downcase_email
  before_create :create_activation_digest
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  # before_save {self.email = email.downcase} # Don't need self keyword on the RHS

  validates :name, presence: true, length: {maximum: 50}
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

  def follow(other_user)
    following << other_user #append to the end of an array
  end
  def unfollow(other_user)
    following.delete(other_user)
  end
  def following?(other_user)
    following.include?(other_user)
  end
  def remember
    self.remember_token = User.new_token
    # self.remember_digest = User.digest(remember_token) doesn't work b/c of validation
    # self.save
    update_attribute(:remember_digest, User.digest(remember_token)) # update_attribute bypasses validation b/c no access to user's password
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest") # b/c in model don't need the self keyword in self.send
    return false if digest.nil? # line 39 will return an error if it is nil
    BCrypt::Password.new(digest).is_password?(token)
  end

  def activate
    update_attribute(:activated, true)
    update_attribute(:activated_at, Time.zone.now)
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest, User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago #read as earlier than, password sent earlier than 2 hours ago  12pm sent at < 17-2
  end

  def feed
    # Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)
    # following_ids === User.first.following.map(&:id)
    #
    # More efficent way of doing this
        following_ids = "SELECT followed_id FROM relationships
                         WHERE  follower_id = :user_id"
        Micropost.where("user_id IN (#{following_ids})
                         OR user_id = :user_id", user_id: id)
  end

  private

  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
