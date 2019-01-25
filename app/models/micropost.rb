class Micropost < ApplicationRecord
  include Elasticsearch::Model::Callbacks
  include Searchable

  settings index: { number_of_shards: 1 } do
    mappings dynamic: 'false' do
      indexes :content, type: 'text', analyzer: 'ngram_analyzer',
              search_analyzer: 'whitespace_analyzer'
      indexes :user_id, type: 'text', analyzer: 'ngram_analyzer',
              search_analyzer: 'whitespace_analyzer'
    end
  end

  belongs_to :user
  default_scope -> {order(created_at: :desc)}
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: {maximum: 140}
  validate :picture_size

  # def Micropost.search_posts(query)
  #   self.search(
  #       query: {
  #           match: {
  #               "content": query.to_s
  #           }
  #       },
  #       highlight:{
  #           fields:{
  #               "content": {}
  #           }
  #       }
  #   )
  # end

  private

  # Validates the size of an uploaded picture.
  def picture_size
    if picture.size > 5.megabytes
      errors.add(:picture, "should be less than 5MB")
    end
  end
end 