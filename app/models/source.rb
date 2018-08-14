# frozen_string_literal: true

class Source < ActiveRecord::Base
  # scopes
  scope :active, -> { where(active: true) }

  # relationships
  has_many :articles
  has_many :user_sources
  has_many :users, through: :user_sources

  # validations
  validates :name, presence: true, length: { minimum: 3, maximum: 25 }
  validates_uniqueness_of :name

  # friendly url
  extend FriendlyId
  friendly_id :name, use: :slugged
end
