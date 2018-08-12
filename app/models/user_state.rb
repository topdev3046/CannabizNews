# frozen_string_literal: true

class UserState < ActiveRecord::Base
  belongs_to :user
  belongs_to :state
end
