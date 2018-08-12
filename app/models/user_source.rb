# frozen_string_literal: true

class UserSource < ActiveRecord::Base
  belongs_to :user
  belongs_to :source
end
