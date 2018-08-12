# frozen_string_literal: true

class Author < ActiveRecord::Base
  # validations
  validates :name, presence: true, length: { minimum: 3, maximum: 300 }
  validates_uniqueness_of :name

  # relations
  has_many :blog

  # friendly url
  extend FriendlyId
  friendly_id :name, use: :slugged
end
