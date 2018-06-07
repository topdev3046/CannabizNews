class RemoveDefaultTimestamp < ActiveRecord::Migration
  def change
    change_column_default(:dsp_prices, :created_at, nil)
    change_column_default(:dsp_prices, :updated_at, nil)
  end
end
