class PotguideScraperHelper

	attr_reader :state_name, :city_range
	
	def initialize(state_name, city_range)
		@state_name = state_name
		@city_range = city_range
	end  
	
	def scrapePotguide()
		
		require "json"
		require 'open-uri'
		
		#GLOBAL VARIABLES
		@source = Source.where(name: 'PotGuide').first #source we are scraping
		@state = State.where(name: @state_name).first #state we are scraping from the source
		
		#query the dispensarysources from this source and this state that have a dispensary lookup
		@dispensary_sources = DispensarySource.where(state_id: @state.id).where(source_id: @source.id).
								includes(:dispensary, :products => [:vendors, :vendor, :category], :dispensary_source_products => :dsp_prices)
		
		#the actual dispensaries that we will really display
		@real_dispensaries = Dispensary.where(state_id: @state.id)

		#quantity map
		@quantity_to_quantity = {
			'.5 gr' => 'Half Gram',
			'gr' => 'Gram',	
			# 'two_grams' => '2 Grams',	
			'1/8' => 'Eighth',	
			'1/4' => 'Quarter Ounce',
			'1/2' => 'Half Ounce',
			'oz' => 'Ounce',
			'ea' => 'Each'
		}
		
		output = IO.popen(["python", "#{Rails.root}/app/scrapers/potGuide_disp_scraper.py", @state_name, '-city='+ @city_range])
		contents = JSON.parse(output.read)
		
		puts 'content number: '
		puts contents[@state.name.downcase].size
		
		#LOOP THROUGH CONTENTS RETURNED (DISPENSARIES)
		contents[@state.name.downcase].each do |returned_dispensary_source|

			#check if the dispensary source already exists
			existing_dispensary_sources = @dispensary_sources.select { |dispensary_source| dispensary_source.name.casecmp(returned_dispensary_source['name']) == 0 }
			
			if existing_dispensary_sources.size > 0 #DISPENSARY SOURCE ALREADY EXISTS
				
				#trying to just update menu once
				@updated_menu = false

				#if exists, then I have to compare fields to see if any need to be updated
				compareAndUpdateDispensarySourceValues(returned_dispensary_source, existing_dispensary_sources[0])
				
				#loop through products and see if we need to create any or update any
				if returned_dispensary_source['menu'] != nil 
					analyzeReturnedDispensarySourceMenu(returned_dispensary_source['menu'], existing_dispensary_sources[0], false)
				end

				#update the last_menu_update of the dispensary_source
				if @updated_menu
					existing_dispensary_sources[0].update_attribute :last_menu_update, DateTime.now
				end	
				
			else #THE DISPENSARYSOURCE DOES NOT EXIST
				
				#check if the dispensary itself is in the system
				existing_real_dispensaries = @real_dispensaries.select { |dispensary| dispensary.name.casecmp(returned_dispensary_source['name']) == 0 }
				
				if existing_real_dispensaries.size > 0 #dispensary is in the system
					
					#just have to create a dispensary source and products
					createDispensaryAndDispensarySourceAndProducts(existing_real_dispensaries[0].id, returned_dispensary_source)
					
				else #dispensary is not in system
					
					#create dispensary, dispensary source, dispensary products, maybe even products 
					createDispensaryAndDispensarySourceAndProducts(nil, returned_dispensary_source)
				end
				
			end #end of if statement seeing if dispensary source exists or not
				
		end #end of contents loop 
		
	end #end main scraper method


	#BEGIN HELPER METHODS
	
	
	#method to loop through the dispensary products (items) and determine the correct course of action 
	def analyzeReturnedDispensarySourceMenu(returned_json_menu, existing_dispensary_source, is_new_dispensary)
	
		returned_json_menu.keys.each do |category_key|
			
			#get the category products
			@category_products = nil
			
			if ['Indica', 'Hybrid', 'Sativa', 'Flower'].include? category_key
				@category_products = Category.where(name: 'Flower').first.products.includes(:vendors, :vendor)
			elsif category_key == 'Edibles'
				@category_products = Category.where(name: 'Edibles').first.products.includes(:vendors, :vendor)
			elsif category_key == 'Concentrate'
				@category_products = Category.where(name: 'Concentrates').first.products.includes(:vendors, :vendor)
			elsif category_key == 'Drinks'
				@category_products = Category.where(name: 'Beverage').first.products.includes(:vendors, :vendor)
			elsif category_key == 'Tincture'
				@category_products = Category.where(name: 'Tincture & Sublingual').first.products.includes(:vendors, :vendor)
			elsif category_key == 'Pre-Rolls'
				@category_products = Category.where(name: 'Pre-Rolls').first.products.includes(:vendors, :vendor)
			elsif category_key == 'Topicals'
				@category_products = Category.where(name: 'Topical').first.products.includes(:vendors, :vendor)
			end

			if @category_products != nil
				#loop through the different menu sections (separated by title - category)
				returned_json_menu[category_key].each do |returned_dispensary_source_product|
				
					#check if dispensary source already has this product
					existing_dispensary_source_products = []
					
					#if its not a new dispensary, we will check if the dispensary source already has the product
					if is_new_dispensary == false
						existing_dispensary_source_products = existing_dispensary_source.products.select { |product| 
																product.name.casecmp(returned_dispensary_source_product['name']) == 0 }
					
						#try alternate names or combine with vendors
						if existing_dispensary_source_products.size == 0
							existing_dispensary_source.products.each do |product|
								
								#check alternate names for a match
								if product.alternate_names.present? 
									product.alternate_names.split(',').each do |alt|
										if alt.casecmp(returned_dispensary_source_product['name']) == 0
											existing_dispensary_source_products.push(product)
											break
										end
									end
								end
	
								if existing_dispensary_source_products.size == 0
	
									#check products with vendor name
									if product.vendors.any?
										product.vendors.each do |vendor|
											combined = []
											combined.push("#{product.name} - #{vendor.name}")
											combined.push("#{vendor.name} - #{product.name}")
											combined.push("#{product.name} by #{vendor.name}")
											combined.push("#{product.name} : #{vendor.name}")
											combined.push("#{vendor.name} : #{product.name}")
											combined.push("#{product.name} (#{vendor.name})")
											combined.push("#{product.name} by #{vendor.name} of " + @state.name)
	
											product_vendor_matches = combined.select { |product_vendor| 
														product_vendor.casecmp(returned_dispensary_source_product['name']) == 0 }
	
											if product_vendor_matches.size > 0
												existing_dispensary_source_products.push(product)
												break
											end
										end
									elsif product.vendor.present?
										combined = []
										combined.push("#{product.name} - #{product.vendor.name}")
										combined.push("#{product.vendor.name} - #{product.name}")
										combined.push("#{product.name} by #{product.vendor.name}")
										combined.push("#{product.name} : #{product.vendor.name}")
										combined.push("#{product.vendor.name} : #{product.name}")
										combined.push("#{product.name} (#{product.vendor.name})")
										combined.push("#{product.name} by #{product.vendor.name} of " + @state.name)

										product_vendor_matches = combined.select { |product_vendor| 
													product_vendor.casecmp(returned_dispensary_source_product['name']) == 0 }

										if product_vendor_matches.size > 0
											existing_dispensary_source_products.push(product)
											break
										end	
									end
								end
							end
						end
					end #end of is_new_dispensary = false if statement
					
					if existing_dispensary_source_products.size > 0 #dispensary source has the product
						
						#if product already exists, check to see if any prices have changed
						compareAndUpdateDispensarySourceProduct(returned_dispensary_source_product, DispensarySourceProduct.
															where(product: existing_dispensary_source_products[0]).
															where(dispensary_source: existing_dispensary_source).first, existing_dispensary_source)
					
					else #dispensary source does not have the product / it is a new dispensary source
						
						#first check if product is in the system - used to be all_products
						existing_products = @category_products.select { |product| product.name.casecmp(returned_dispensary_source_product['name']) == 0 }
						
						if existing_products.size > 0 #product is in the system
							
							#just create a dispensary source product
							createProductAndDispensarySourceProduct(existing_products[0], 
								existing_dispensary_source.id, returned_dispensary_source_product)
			
							#existing_dispensary_source.update_attribute :last_menu_update, DateTime.now
						else
							#dive deeper for a match
							@category_products.each do |product|
	
								#check alternate names for a match
								if product.alternate_names.present? 
									product.alternate_names.split(',').each do |alt|
										if alt.casecmp(returned_dispensary_source_product['name']) == 0
											existing_products.push(product)
											break
										end
									end
								end
	
								if existing_products.size > 0 
									createProductAndDispensarySourceProduct(existing_products[0], 
											existing_dispensary_source.id, returned_dispensary_source_product)
									break
								
								else 
									#check products with vendor name
									if product.vendors.any?
										product.vendors.each do |vendor|
											combined = []
											combined.push("#{product.name} - #{vendor.name}")
											combined.push("#{vendor.name} - #{product.name}")
											combined.push("#{product.name} by #{vendor.name}")
											combined.push("#{product.name} : #{vendor.name}")
											combined.push("#{vendor.name} : #{product.name}")
											combined.push("#{product.name} (#{vendor.name})")
											combined.push("#{product.name} by #{vendor.name} of " + @state.name)
	
											product_vendor_matches = combined.select { |product_vendor| 
														product_vendor.casecmp(returned_dispensary_source_product['name']) == 0 }
	
											if product_vendor_matches.size > 0
												existing_products.push(product)
												break
											end
										end
									elsif product.vendor.present?
										combined = []
										combined.push("#{product.name} - #{product.vendor.name}")
										combined.push("#{product.vendor.name} - #{product.name}")
										combined.push("#{product.name} by #{product.vendor.name}")
										combined.push("#{product.name} : #{product.vendor.name}")
										combined.push("#{product.vendor.name} : #{product.name}")
										combined.push("#{product.name} (#{product.vendor.name})")
										combined.push("#{product.name} by #{product.vendor.name} of " + @state.name)

										product_vendor_matches = combined.select { |product_vendor| 
													product_vendor.casecmp(returned_dispensary_source_product['name']) == 0 }

										if product_vendor_matches.size > 0
											existing_products.push(product)
											break
										end	
									end
	
									if existing_products.size > 0 
										createProductAndDispensarySourceProduct(existing_products[0], 
												existing_dispensary_source.id, returned_dispensary_source_product)
										break
									end
								end 
	
							end
						end
						
						#either way I update the dispensarySource.last_menu_update
						#not sure why i was doing this
						#existing_dispensary_source.update_attribute :last_menu_update, DateTime.now
						
					end
				end #end loop of each section's products
			end
			
		end #end loop of each menu 'section' -> sections are broken down by type 'indica, sativa, etc'
	
	end #end analyzeReturnedDispensarySourceMenu method
	
	#method to create product (if necessary) and dispensary product
	def createProductAndDispensarySourceProduct(product, dispensary_source_id, returned_dispensary_source_product)

		#if our product has no image, lets take their image:
		if product.remote_image_url == nil && returned_dispensary_source_product['imageUrl'] && returned_dispensary_source_product['imageUrl'].length < 150
			product.update_attribute :remote_image_url, returned_dispensary_source_product['imageUrl']
		end

		#create dispensary source product & dsp_prices
		if returned_dispensary_source_product['prices'] != nil

			dsp = DispensarySourceProduct.create(
				:product_id => product.id, 
				:dispensary_source_id => dispensary_source_id
			)

			returned_dispensary_source_product['prices'].each do |price_quantity_pair|
				
				#not trying to send email if null
				if price_quantity_pair.keys.size > 0
				
					puts	'HERE ARE THE VARIABLES: '
					puts	price_quantity_pair 
					puts	price_quantity_pair.keys[0]
					puts	price_quantity_pair[price_quantity_pair.keys[0]].gsub(/[^\d\.]/, '').to_f
					puts	@quantity_to_quantity.has_key?(price_quantity_pair.keys[0])
	
					if @quantity_to_quantity.has_key?(price_quantity_pair.keys[0])
						dsp_price = DspPrice.new(
							:unit => @quantity_to_quantity[price_quantity_pair.keys[0]],
							:price => price_quantity_pair[price_quantity_pair.keys[0]].gsub(/[^\d\.]/, '').to_f
						)
						unless dsp_price.save
			        		puts "dsp_price Save Error: #{dsp_price.errors.messages}"
			        	end 
					elsif !@quantity_to_quantity.has_key?(price_quantity_pair.keys[0])
						UnitMissing.email('PotGuide', price_quantity_pair.keys[0], price_quantity_pair[price_quantity_pair.keys[0]].gsub(/[^\d\.]/, '').to_f).deliver_now
					end
				end
			end
		end
	end #end createProductAndDispensarySourceProduct method

	#method to compare returned dispensary product with one existing in system to see if prices need update
	def compareAndUpdateDispensarySourceProduct(returned_dispensary_source_product, existing_dispensary_source_product, dispensary_source)
		
		if  returned_dispensary_source_product['prices'] != nil
			#see if we need to update the last_menu_update for the dispensary source

			# [["dispensary_source_product_id", 9479], ["unit", "Ounce"]]

			returned_dispensary_source_product['prices'].each do |price_quantity_pair|
				
				price_quantity_pair.keys.size > 0

					puts	'HERE ARE THE VARIABLES: '
					put 	price_quantity_pair
					puts	price_quantity_pair.keys[0]
					puts	price_quantity_pair[price_quantity_pair.keys[0]].gsub(/[^\d\.]/, '').to_f
					puts	@quantity_to_quantity.has_key?(price_quantity_pair.keys[0])
	
					if @quantity_to_quantity.has_key?(price_quantity_pair.keys[0]) 
	
						#see if we have any dsp prices with this quantity
						if existing_dispensary_source_product.dsp_prices.where(unit: @quantity_to_quantity[price_quantity_pair.keys[0]]).any?
	
							#compare the price - if its different we update
							if existing_dispensary_source_product.dsp_prices.where(unit: @quantity_to_quantity[price_quantity_pair.keys[0]]).first.price != price_quantity_pair[price_quantity_pair.keys[0]].gsub(/[^\d\.]/, '').to_f
								
								existing_dispensary_source_product.dsp_prices.
									where(unit: @quantity_to_quantity[price_quantity_pair.keys[0]]).first.update_attribute :price, price_quantity_pair[price_quantity_pair.keys[0]].gsub(/[^\d\.]/, '').to_f
								
								@updated_menu = true
							end
						else
	
							#create new dsp price
							dsp_price =  DspPrice.new(
								:dispensary_source_product_id => existing_dispensary_source_product.id,
								:unit => @quantity_to_quantity[price_quantity_pair.keys[0]],
								:price => price_quantity_pair[price_quantity_pair.keys[0]].gsub(/[^\d\.]/, '').to_f
							)
							unless dsp_price.save
				        		puts "dsp_price Save Error: #{dsp_price.errors.messages}"
				        	end 
							@updated_menu = true
						end
					elsif !@quantity_to_quantity.has_key?(price_quantity_pair.keys[0])
						UnitMissing.email('PotGuide', price_quantity_pair.keys[0], price_quantity_pair[price_quantity_pair.keys[0]].gsub(/[^\d\.]/, '').to_f).deliver_now
					end
				# end
			end		
			
		end #end of check to see if returned_dispensary_product['prices'] != nil
	end
	
	#method to create a dispensary (maybe) and dispensarySource record and its products (definitely)
	def createDispensaryAndDispensarySourceAndProducts(dispensary_id, returned_dispensary_source)
	
		if dispensary_id == nil
			
			#image
			image_url = ''
			if returned_dispensary_source['contact'].present? && returned_dispensary_source['contact']['logo'].present?
				image_url = returned_dispensary_source['contact']['logo']		
			end
			
			#create dispensary
			dispensary = Dispensary.create(
				:name => returned_dispensary_source['name'], 
				:state_id => @state.id, 
				:remote_image_url => image_url
			)
			dispensary_id = dispensary.id
		end
		
		dispensary_source = DispensarySource.new(
			:dispensary_id => dispensary_id, :source_id => @source.id, 
			:state_id => @state.id, :last_menu_update => DateTime.now,
			:name => returned_dispensary_source["name"],
			:source_url => returned_dispensary_source['url']
		)
		
		if returned_dispensary_source['contact'].present?
			dispensary_source.remote_image_url = returned_dispensary_source['contact']['logo']
			dispensary_source.street = returned_dispensary_source['contact']['address']
			dispensary_source.city = returned_dispensary_source['contact']['city']
			dispensary_source.zip_code = returned_dispensary_source['contact']['zip']
			dispensary_source.phone = returned_dispensary_source['contact']['phone']
			
			#for the website i gotta remove the url params
			dispensary_source.website = returned_dispensary_source['contact']['website']
		end
			
		unless dispensary_source.save
    		puts "dispensary_source Save Error: #{dispensary_source.errors.messages}"
    	end  

		#hours
		if returned_dispensary_source['hours'] != nil
			
			#monday
			if returned_dispensary_source['hours']['monday'].include? '-'
				dispensary_source.update_attribute :monday_open_time, 
					returned_dispensary_source['hours']['monday'].partition('-').first.strip.to_time
				dispensary_source.update_attribute :monday_close_time,
					returned_dispensary_source['hours']['monday'].partition('-').last.strip.to_time
			end

			#tuesday
			if returned_dispensary_source['hours']['tuesday'].include? '-'
				dispensary_source.update_attribute :tuesday_open_time, 
					returned_dispensary_source['hours']['tuesday'].partition('-').first.strip.to_time
				dispensary_source.update_attribute :tuesday_close_time,
					returned_dispensary_source['hours']['tuesday'].partition('-').last.strip.to_time
			end

			#wednesday
			if returned_dispensary_source['hours']['wednesday'].include? '-'
				dispensary_source.update_attribute :wednesday_open_time, 
					returned_dispensary_source['hours']['wednesday'].partition('-').first.strip.to_time
				dispensary_source.update_attribute :wednesday_close_time,
					returned_dispensary_source['hours']['wednesday'].partition('-').last.strip.to_time
			end

			#thursday
			if returned_dispensary_source['hours']['thursday'].include? '-'
				dispensary_source.update_attribute :thursday_open_time, 
					returned_dispensary_source['hours']['thursday'].partition('-').first.strip.to_time
				dispensary_source.update_attribute :thursday_close_time,
					returned_dispensary_source['hours']['thursday'].partition('-').last.strip.to_time
			end

			#friday
			if returned_dispensary_source['hours']['friday'].include? '-'
				dispensary_source.update_attribute :friday_open_time, 
					returned_dispensary_source['hours']['friday'].partition('-').first.strip.to_time
				dispensary_source.update_attribute :friday_close_time,
					returned_dispensary_source['hours']['friday'].partition('-').last.strip.to_time
			end

			#saturday
			if returned_dispensary_source['hours']['saturday'].include? '-'
				dispensary_source.update_attribute :saturday_open_time, 
					returned_dispensary_source['hours']['saturday'].partition('-').first.strip.to_time
				dispensary_source.update_attribute :saturday_close_time,
					returned_dispensary_source['hours']['saturday'].partition('-').last.strip.to_time
			end

			#sunday
			if returned_dispensary_source['hours']['sunday'].include? '-'
				dispensary_source.update_attribute :sunday_open_time, 
					returned_dispensary_source['hours']['sunday'].partition('-').first.strip.to_time
				dispensary_source.update_attribute :sunday_close_time,
					returned_dispensary_source['hours']['sunday'].partition('-').last.strip.to_time
			end

		end 
	
		#loop through products and see if we need to create any or update any
		if returned_dispensary_source['menu'] != nil
			analyzeReturnedDispensarySourceMenu(returned_dispensary_source['menu'], dispensary_source, true)
		end
	
	end #end createDispensaryAndDispensarySourceAndProducts method

	#method to compare new dispensary from scraper with dispensary in system to see if any fields need to be updated
	def compareAndUpdateDispensarySourceValues(returned_dispensary_source, existing_dispensary_source)
		
		#source url
		if existing_dispensary_source.source_url != returned_dispensary_source['url']
			existing_dispensary_source.update_attribute :source_url, returned_dispensary_source['url']
		end
	
		if returned_dispensary_source['contact'].present?
			#image
			if returned_dispensary_source['contact']['logo'].present?
				existing_dispensary_source.update_attribute :image, returned_dispensary_source['contact']['logo']
			end
	
			#street address
			if existing_dispensary_source.street != returned_dispensary_source['contact']['address']
				existing_dispensary_source.update_attribute :street, returned_dispensary_source['contact']['address']
			end
			
			#city
			if existing_dispensary_source.city != returned_dispensary_source['contact']['city']
				existing_dispensary_source.update_attribute :city, returned_dispensary_source['contact']['city']
			end
			
			#zip
			if existing_dispensary_source.zip_code != returned_dispensary_source['contact']['zip']
				existing_dispensary_source.update_attribute :zip_code, returned_dispensary_source['contact']['zip']
			end
			
			#phone
			if existing_dispensary_source.phone != returned_dispensary_source['contact']['phone']
				existing_dispensary_source.update_attribute :phone, returned_dispensary_source['contact']['phone']
			end
			
			#website
			if existing_dispensary_source.website != returned_dispensary_source['contact']['website']
				existing_dispensary_source.update_attribute :website, returned_dispensary_source['contact']['website']
			end
		end
		
		if returned_dispensary_source['social_media'].present?
			#facebook
			if existing_dispensary_source.facebook != returned_dispensary_source['social_media']['facebook']
				existing_dispensary_source.update_attribute :facebook, returned_dispensary_source['social_media']['facebook']
			end
			
			#instagram
			if existing_dispensary_source.instagram != returned_dispensary_source['social_media']['instagram']
				existing_dispensary_source.update_attribute :instagram, returned_dispensary_source['social_media']['instagram']
			end
			
			#twitter
			if existing_dispensary_source.twitter != returned_dispensary_source['social_media']['twitter']
				existing_dispensary_source.update_attribute :twitter, returned_dispensary_source['social_media']['twitter']
			end
				
		end
		
		if returned_dispensary_source['hours'].present?
			
		end
		
		
		#hours - need to break the strings
		if returned_dispensary_source['hours'] != nil
		
			#monday
			if returned_dispensary_source['hours']['monday'].include? '-'
				monday_open = returned_dispensary_source['hours']['monday'].partition('-').first.strip.to_time
				monday_close = returned_dispensary_source['hours']['monday'].partition('-').last.strip.to_time
				
				if existing_dispensary_source.monday_open_time != nil
					if existing_dispensary_source.monday_open_time.utc.strftime( "%H%M%S%N" ) != monday_open.utc.strftime( "%H%M%S%N" )
						existing_dispensary_source.update_attribute :monday_open_time, monday_open
					end
				else 
					existing_dispensary_source.update_attribute :monday_open_time, monday_open
				end
				
				
				if existing_dispensary_source.monday_close_time != nil
					if existing_dispensary_source.monday_close_time.utc.strftime( "%H%M%S%N" ) != monday_close.utc.strftime( "%H%M%S%N" )
						existing_dispensary_source.update_attribute :monday_close_time, monday_close
					end
				else 
					existing_dispensary_source.update_attribute :monday_close_time, monday_close
				end
			end

			#tuesday
			if returned_dispensary_source['hours']['tuesday'].include? '-'
				tuesday_open = returned_dispensary_source['hours']['tuesday'].partition('-').first.strip.to_time
				tuesday_close = returned_dispensary_source['hours']['tuesday'].partition('-').last.strip.to_time
				
				if existing_dispensary_source.tuesday_open_time != nil
					if existing_dispensary_source.tuesday_open_time.utc.strftime( "%H%M%S%N" ) != tuesday_open.utc.strftime( "%H%M%S%N" )
						existing_dispensary_source.update_attribute :tuesday_open_time, tuesday_open
					end
				else 
					existing_dispensary_source.update_attribute :tuesday_open_time, tuesday_open
				end
				
				
				if existing_dispensary_source.tuesday_close_time != nil
					if existing_dispensary_source.tuesday_close_time.utc.strftime( "%H%M%S%N" ) != tuesday_close.utc.strftime( "%H%M%S%N" )
						existing_dispensary_source.update_attribute :tuesday_close_time, tuesday_close
					end
				else 
					existing_dispensary_source.update_attribute :tuesday_close_time, tuesday_close
				end
			end

			#wednesday
			if returned_dispensary_source['hours']['wednesday'].include? '-'
				wednesday_open = returned_dispensary_source['hours']['wednesday'].partition('-').first.strip.to_time
				wednesday_close = returned_dispensary_source['hours']['wednesday'].partition('-').last.strip.to_time
				
				if existing_dispensary_source.wednesday_open_time != nil
					if existing_dispensary_source.wednesday_open_time.utc.strftime( "%H%M%S%N" ) != wednesday_open.utc.strftime( "%H%M%S%N" )
						existing_dispensary_source.update_attribute :wednesday_open_time, wednesday_open
					end
				else 
					existing_dispensary_source.update_attribute :wednesday_open_time, wednesday_open
				end
				
				
				if existing_dispensary_source.wednesday_close_time != nil
					if existing_dispensary_source.wednesday_close_time.utc.strftime( "%H%M%S%N" ) != wednesday_close.utc.strftime( "%H%M%S%N" )
						existing_dispensary_source.update_attribute :wednesday_close_time, wednesday_close
					end
				else 
					existing_dispensary_source.update_attribute :wednesday_close_time, wednesday_close
				end
			end

			#thursday
			if returned_dispensary_source['hours']['thursday'].include? '-'
				thursday_open = returned_dispensary_source['hours']['thursday'].partition('-').first.strip.to_time
				thursday_close = returned_dispensary_source['hours']['thursday'].partition('-').last.strip.to_time
				
				if existing_dispensary_source.thursday_open_time != nil
					if existing_dispensary_source.thursday_open_time.utc.strftime( "%H%M%S%N" ) != thursday_open.utc.strftime( "%H%M%S%N" )
						existing_dispensary_source.update_attribute :thursday_open_time, thursday_open
					end
				else 
					existing_dispensary_source.update_attribute :thursday_open_time, thursday_open
				end
				
				
				if existing_dispensary_source.thursday_close_time != nil
					if existing_dispensary_source.thursday_close_time.utc.strftime( "%H%M%S%N" ) != thursday_close.utc.strftime( "%H%M%S%N" )
						existing_dispensary_source.update_attribute :thursday_close_time, thursday_close
					end
				else 
					existing_dispensary_source.update_attribute :thursday_close_time, thursday_close
				end
			end

			#friday
			if returned_dispensary_source['hours']['friday'].include? '-'
				friday_open = returned_dispensary_source['hours']['friday'].partition('-').first.strip.to_time
				friday_close = returned_dispensary_source['hours']['friday'].partition('-').last.strip.to_time
				
				if existing_dispensary_source.friday_open_time != nil
					if existing_dispensary_source.friday_open_time.utc.strftime( "%H%M%S%N" ) != friday_open.utc.strftime( "%H%M%S%N" )
						existing_dispensary_source.update_attribute :friday_open_time, friday_open
					end
				else 
					existing_dispensary_source.update_attribute :friday_open_time, friday_open
				end
				
				
				if existing_dispensary_source.friday_close_time != nil
					if existing_dispensary_source.friday_close_time.utc.strftime( "%H%M%S%N" ) != friday_close.utc.strftime( "%H%M%S%N" )
						existing_dispensary_source.update_attribute :friday_close_time, friday_close
					end
				else 
					existing_dispensary_source.update_attribute :friday_close_time, friday_close
				end
			end

			#saturday
			if returned_dispensary_source['hours']['saturday'].include? '-'
				saturday_open = returned_dispensary_source['hours']['saturday'].partition('-').first.strip.to_time
				saturday_close = returned_dispensary_source['hours']['saturday'].partition('-').last.strip.to_time
				
				if existing_dispensary_source.saturday_open_time != nil
					if existing_dispensary_source.saturday_open_time.utc.strftime( "%H%M%S%N" ) != saturday_open.utc.strftime( "%H%M%S%N" )
						existing_dispensary_source.update_attribute :saturday_open_time, saturday_open
					end
				else 
					existing_dispensary_source.update_attribute :saturday_open_time, saturday_open
				end
				
				
				if existing_dispensary_source.saturday_close_time != nil
					if existing_dispensary_source.saturday_close_time.utc.strftime( "%H%M%S%N" ) != saturday_close.utc.strftime( "%H%M%S%N" )
						existing_dispensary_source.update_attribute :saturday_close_time, saturday_close
					end
				else 
					existing_dispensary_source.update_attribute :saturday_close_time, saturday_close
				end
			end

			#sunday
			if returned_dispensary_source['hours']['sunday'].include? '-'
				sunday_open = returned_dispensary_source['hours']['sunday'].partition('-').first.strip.to_time
				sunday_close = returned_dispensary_source['hours']['sunday'].partition('-').last.strip.to_time
				
				if existing_dispensary_source.sunday_open_time != nil
					if existing_dispensary_source.sunday_open_time.utc.strftime( "%H%M%S%N" ) != sunday_open.utc.strftime( "%H%M%S%N" )
						existing_dispensary_source.update_attribute :sunday_open_time, sunday_open
					end
				else 
					existing_dispensary_source.update_attribute :sunday_open_time, sunday_open
				end
				
				
				if existing_dispensary_source.sunday_close_time != nil
					if existing_dispensary_source.sunday_close_time.utc.strftime( "%H%M%S%N" ) != sunday_close.utc.strftime( "%H%M%S%N" )
						existing_dispensary_source.update_attribute :sunday_close_time, sunday_close
					end
				else 
					existing_dispensary_source.update_attribute :sunday_close_time, sunday_close
				end
			end
		end #end of hours 

	end #end compareAndUpdateDispensarySourceValues method
end