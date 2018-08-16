# frozen_string_literal: true

class ArticleCategory < ActiveRecord::Base
  belongs_to :article
  belongs_to :category

  validates :article_id, presence: true
end
