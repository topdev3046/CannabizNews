class ProductHelper

	def initialize(product, state, average_price)
		@product = product
		@state = state
		@average_price = average_price
	end
	
	def buildSimilarProducts()
	    #similar products - include is_dom and sub_category as well
        if @product.category.present?

            @similar_products = @product.category.products.featured.where.not(id: @product.id)
            
            if @product.is_dom.present?
            
                @similar_products = @similar_products.where(is_dom: @product.is_dom.strip).order("Random()").limit(4)
                similar_products_count = @similar_products.count
                if similar_products_count < 4
                    sub_category_products =  @similar_products.where(sub_category: @product.sub_category.strip).order("Random()").limit(4 - similar_products_count)
                    sub_category_products.each do |sub_cat_prod|
                       @similar_products << sub_cat_prod
                    end
                end
                
            elsif @product.sub_category.present?
                @similar_products = @similar_products.where(sub_category: @product.sub_category.strip).order("Random()").limit(4)
                similar_products_count = @similar_products.count
                if similar_products_count < 4
                    category_products =  @product.category.products.featured.where.not(id: @product.id).order("Random()").limit(4 - similar_products_count)
                    category_products.each do |cat_prod|
                       @similar_products << cat_prod
                    end
                end
            else
                @similar_products = @similar_products.order("Random()").limit(4)    
            end
            
        else
            @similar_products = Product.featured.order("Random()").limit(4)  
        end
        
        #return
        [@similar_products]
        
	end
	
	def buildProductDisplay()
	   
	    @dispensary_source_products = @product.dispensary_source_products.includes(:product, :dsp_prices, :dispensary_source => [:dispensary, :state]).
                where("dispensary_sources.state_id =?", @state.id).
                order('dispensary_sources.last_menu_update DESC').order("dispensary_sources.name ASC").
                references(:dispensary_sources)
	    
	    if @average_price.present?
                
            @table_header_options = [@average_price.average_price_unit]
	        
	    else 
            
            @header_options =  @dispensary_source_products.
                map{|dispensary_source_product| dispensary_source_product.dsp_prices.map(&:unit)}.flatten.uniq
                
            if @header_options != nil
                @table_header_options = DspPrice::DISPLAYS.sort_by {|key, value| value}.to_h.select{|k, v| k if @header_options.include?(k)}.keys
            else 
                @table_header_options = nil
            end
	    end

        #change to two maps
        @dispensary_to_dispensary_source = Hash.new
        @dispensary_to_dsp = Hash.new
        
        @dispensary_source_products.each do |dsp|
            
            #new maps
            if !@dispensary_to_dispensary_source.has_key?(dsp.dispensary_source.dispensary)
                
                if @average_price.present?
                
                    dsp.dsp_prices.each do |dsp_price|
                        if dsp_price.unit == @average_price.average_price_unit && dsp_price.price <= @average_price.average_price 
                            @dispensary_to_dispensary_source.store(dsp.dispensary_source.dispensary, dsp.dispensary_source)
                            @dispensary_to_dsp.store(dsp.dispensary_source.dispensary, dsp)  
                        end
                    end
                else
                    @dispensary_to_dispensary_source.store(dsp.dispensary_source.dispensary, dsp.dispensary_source)
                    @dispensary_to_dsp.store(dsp.dispensary_source.dispensary, dsp)
                end
                
                @dispensary_to_dispensary_source.store(dsp.dispensary_source.dispensary, dsp.dispensary_source)
                @dispensary_to_dsp.store(dsp.dispensary_source.dispensary, dsp)
            end
            
                
        end

        #return
        [@table_header_options, @dispensary_to_dispensary_source, @dispensary_to_dsp]
	end
end