class Dsptimestamps < ActiveRecord::Migration
  def change
    add_timestamps :dsp_prices, default: DateTime.now
  end
end
