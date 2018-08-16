# frozen_string_literal: true

class UserCategory < ActiveRecord::Base
  belongs_to :user
  belongs_to :category
end
