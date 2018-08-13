class HeadsetResetCountHelper
  
  def initialize(state_string)
    @state_string = state_string
    @state_names = @state_string.split(/\W+/)
  end

  def daily
   
    @state_names.each do |name|
      state = State.where('lower(name) =?', name.to_s.downcase).first
      if state.present?
        product_states = state.product_states
        products = state.products
        product_states.update_all(headset_daily_count: 0)
        products.update_all(headset_daily_count: 0)
      end
    end
  end
  
  def weekly
    @state_names.each do |name|
      state = State.where('lower(name) =?', name.to_s.downcase).first
      if state.present?
        product_states = state.product_states
        products = state.products
        product_states.update_all(headset_weekly_count: 0)
        products.update_all(headset_weekly_count: 0)
      end
    end
  end

  def monthly
    @state_names.each do |name|
      state = State.where('lower(name) =?', name.to_s.downcase).first
      if state.present?
        product_states = state.product_states
        products = state.products
        product_states.update_all(headset_monthly_count: 0)
        products.update_all(headset_monthly_count: 0)
      end
    end
  end

end