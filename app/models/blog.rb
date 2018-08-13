# frozen_string_literal: true

class Blog < ActiveRecord::Base
  self.table_name = "blog"

  # scopes
  scope :published_blogs, -> { where(published: true) }

  # validations
  validates :title, presence: true, length: { minimum: 3, maximum: 300 }
  validates_uniqueness_of :title
  validates :body, presence: true
  validates_length_of :body, minimum: 300

  # relations
  belongs_to :author

  # friendly url
  extend FriendlyId
  friendly_id :title, use: :slugged

  # photo aws storage
  mount_uploader :image, PhotoUploader

  # import CSV file
  def self.import_from_csv(file)
    CSV.foreach(file.path, headers: true, skip_blanks: true) do |row|

      # change to update record if id matches
      blog_hash = row.to_hash
      blog = self.where(id: blog_hash["id"])

      if blog.present?
        blog.first.update_attributes(blog_hash)
      else
        Blog.create! blog_hash
      end
    end
  end
end
