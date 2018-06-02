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
        
        @dispensary_source_products = DispensarySourceProduct.where(product: @product).joins(:dsp_prices)
        dispensary_source_ids = @dispensary_source_products.pluck(:dispensary_source_id)
        @dispensary_sources = DispensarySource.where(id: dispensary_source_ids).where(state_id: @state.id).
                                order('last_menu_update DESC').order("name ASC")
        
        #need a map of dispensary to dispensary source product
        @dispensary_to_product = Hash.new
        @state_to_dispensary = Hash.new
        
        @dispensary_sources.each do |dispSource|
            
            #state dispensaries
            if @state_to_dispensary.has_key?(dispSource.state.name)
                @state_to_dispensary[dispSource.state.name].push(dispSource)
            else
                dispensaries = []
                dispensaries.push(dispSource)
                @state_to_dispensary.store(dispSource.state.name, dispensaries) 
            end
            
            #dispensary products
            if !@dispensary_to_product.has_key?(dispSource.id)
               
                if @dispensary_source_products.where(dispensary_source_id: dispSource.id).any?
                    @dispensary_to_product.store(dispSource.id, 
                        @dispensary_source_products.where(dispensary_source_id: dispSource.id).first)
                end
            end
        end
        
        [@similar_products, @dispensary_to_product, @state_to_dispensary]
		
	end
	
end