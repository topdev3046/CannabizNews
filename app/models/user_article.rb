# frozen_string_literal: true

class UserArticle < ActiveRecord::Base
  belongs_to :user
  belongs_to :article
end
