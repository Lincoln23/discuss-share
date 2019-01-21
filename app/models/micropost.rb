class Micropost < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  mapping do
    indexes :content, type: :text, analyzer: :english
    indexes :user_id, type: :integer
  end

  belongs_to :user
  default_scope -> {order(created_at: :desc)}
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: {maximum: 140}
  validate :picture_size

  def Micropost.search_posts(query)
    self.search(
        query: {
            match: {
                "content": query.to_s
            }
        }
    )
  end

  private

  # Validates the size of an uploaded picture.
  def picture_size
    if picture.size > 5.megabytes
      errors.add(:picture, "should be less than 5MB")
    end
  end
end 