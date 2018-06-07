class ProductHelper

	def initialize(product, state)
		@product = product
		@state = state
	end
	
# 	def findProductsPriceAndDistance()
		
# 		#hash returned
# 		@product_to_distance = Hash.new
# 		@product_to_closest_disp = Hash.new
		
# 		@products.each do |product|
			
# 			#distance
# 			if @ip_address != nil
# 				closest_distance = nil
# 				closest_dispensary = nil
				
# 				product.dispensary_sources.each do |dispSource|
					
# 					if closest_distance == nil || dispSource.distance_to(@ip_address) < closest_distance
# 						closest_distance = dispSource.distance_to(@ip_address).round(2)	
# 						closest_dispensary = dispSource.dispensary
# 					end
# 				end
				
# 				@product_to_distance.store(product, closest_distance)
# 				@product_to_closest_disp.store(product, closest_dispensary)
# 			end
# 		end
		
# 		#return
# 		[@product_to_distance, @product_to_closest_disp]
# 	end
	
	def buildProductDisplay()

	    #similar products - include is_dom and sub_category as well
	    if @product.category.present?

	        @similar_products = @product.category.products.featured.where.not(id: @product.id)
	        
	        if @product.is_dom.present?
	        
	            @similar_products = @similar_products.where(is_dom: @product.is_dom).order("Random()").limit(4)
	            
	        elsif @product.sub_category.present?
	        
	            @similar_products = @similar_products.where(sub_category: @product.sub_category).order("Random()").limit(4)
	        else
	            @similar_products = @similar_products.order("Random()").limit(4)    
	        end
	        
	    else
            @similar_products = Product.featured.order("Random()").limit(4)  
	    end
	    
	    dispensary_sources = @product.dispensary_sources.where(state_id: @state.id).
                        includes(:dispensary, :state, :dispensary_source_products => :dsp_prices).
                        order('last_menu_update DESC').order("name ASC")
        
        #table headers
        header_options =  @product.dispensary_source_products.map{|dispensary_source| dispensary_source.dsp_prices.map(&:unit)}.flatten.uniq unless  @product.dispensary_source_products.blank?
        if header_options != nil
            @table_header_options = DspPrice::DISPLAYS.sort_by {|key, value| value}.to_h.select{|k, v| k if header_options.include?(k)}.keys
        else 
            @table_header_options = nil
        end
        
        #need a map of dispensary to dispensary source product
        @dispensary_to_product = Hash.new
        dispensary_sources.each do |dispSource|
            
            #dispensary products
            if !@dispensary_to_product.has_key?(dispSource)
                
                dsps = dispSource.dispensary_source_products.select { |dsp| dsp.product_id == @product.id}
                
                if dsps.size > 0
                    @dispensary_to_product.store(dispSource, dsps[0])
                end
            end
        end
        
        [@similar_products, @dispensary_to_product, @table_header_options]
		
	end
	
end