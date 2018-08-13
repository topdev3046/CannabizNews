# frozen_string_literal: true

class VendorProduct < ActiveRecord::Base
  belongs_to :vendor
  belongs_to :product
end
