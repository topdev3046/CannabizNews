# frozen_string_literal: true

class HeadsetScraperHelper
  attr_reader :state_string

  def initialize(state_string)
    @state_string = state_string
  end

  def scrapeHeadset
    @state_names = @state_string.split(/\W+/)
    @categories = Category.products.active
    @products = Product.all
    @vendors = Vendor.all

    require "json"
    require "open-uri"

    begin

     @state_names.each do |state_name|

            output = IO.popen(["python", "#{Rails.root}/app/scrapers/headset_disp_scraper.py", state_name])
            contents = JSON.parse(output.read)

            @state_record = State.where(name: state_name.titlecase).first

            if contents[state_name] != nil
              puts "HEADSET DID RETURN PRODUCTS FOR STATE: " + state_name
              parseProducts(contents[state_name])
            else
              puts "HEADSET DID NOT RETURN ANY PRODUCTS FOR STATE " + state_name
            end
          end
        rescue => ex
          puts "THERE WAS A HEADSET ERROR: "
          puts ex.message
   end
    end

  def parseProducts(state_products)
    state_products.each do |product_grouping|

      @categories.each do |category|

        if product_grouping[category.name] != nil

          product_grouping[category.name]["items"].each do |item|
            checkVendorAndProduct(item, category)
          end
        end
      end
    end
  end # end of parseProducts method


  # method to check if product and vendor are in system - if not create
  def checkVendorAndProduct(item, category)
    # check if the vendor itself is in the system
    existing_vendors = @vendors.select { |vendor| vendor.name.casecmp(item["brand_name"]) == 0 }
    vendor = nil
    if existing_vendors.size > 0
      # still need to check if vendor product
      vendor = existing_vendors[0]

      # check if vendor state exists
      if VendorState.where(vendor_id: vendor.id).where(state_id: @state_record.id).empty?
        vendor_state = VendorState.new(
          vendor_id: vendor.id,
           state_id: @state_record.id
            )
        unless vendor_state.save
          puts "vendor_state Save Error: #{vendor_state.errors.messages}"
        end
      end
    else
      # vendor not in system - create
      image_url = ""
      if item["brand_image"].index("?") != nil

        image_url = item["brand_image"][0, item["brand_image"].index("?")].strip

      else
        image_url = item["brand_image"]
      end

      puts image_url

      vendor = Vendor.new(
        name: item["brand_name"],
        remote_image_url: image_url
       )
      unless vendor.save
        puts "vendor Save Error: #{vendor.errors.messages}"
      end
      @vendors.push(vendor)

      # create vendor state
      vendor_state = VendorState.new(
        vendor_id: vendor.id,
        state_id: @state_record.id
      )
      unless vendor_state.save
        puts "vendor_state Save Error: #{vendor_state.errors.messages}"
      end
    end

    # check if the product itself is in the system
    product_name = ""
    average_price_unit = ""

    if item["product_name"].index("(") != nil
      product_name = item["product_name"][0, item["product_name"].index("(") - 1].strip

      average_price_unit = item["product_name"][(item["product_name"].index("(") + 1),
                    item["product_name"].length].chomp(")").strip

      if average_price_unit.downcase == "bulk"
        average_price_unit = "Gram"
      end
    else
      product_name = item["product_name"]
      average_price_unit = "Each"
    end

    existing_products = @products.select { |product| product.name.casecmp(product_name) == 0 }
    product = nil
    if existing_products.size > 0
      # still need to check if vendor product
      product = existing_products[0]
      product.increment_counters

      # check if product state exists
      if ProductState.where(product_id: product.id).where(state_id: @state_record.id).empty?
        product_state = ProductState.new(
          product_id: product.id,
           state_id: @state_record.id,
           headset_alltime_count: 1,
          headset_monthly_count: 1,
          headset_weekly_count: 1,
          headset_daily_count: 1,
            )
        unless product_state.save
          puts "product_state Save Error: #{product_state.errors.messages}"
        end
      else
        # increment product state headset counters
        ProductState.where(product_id: product.id).where(state_id: @state_record.id).first.increment_counters
      end
    else
      # product not in system - create
      product = Product.new(
        name: product_name,
         featured_product: false,
         category_id: category.id,
         headset_alltime_count: 1,
         headset_monthly_count: 1,
         headset_weekly_count: 1,
         headset_daily_count: 1
       )

      if category.name != "Flower"
        product.vendor_id = vendor.id
      end
      unless product.save
        puts "product Save Error: #{product.errors.messages}"
      end
      @products.push(product)

      # create product state
      product_state = ProductState.new(
        product_id: product.id,
        state_id: @state_record.id,
        headset_alltime_count: 1,
        headset_monthly_count: 1,
        headset_weekly_count: 1,
        headset_daily_count: 1,

      )
      unless product_state.save
        puts "product_state Save Error: #{product_state.errors.messages}"
      end
    end

    # check vendor product (if flower)
    if category.name == "Flower"
      existing_vp = VendorProduct.where(vendor_id: vendor.id).where(product_id: product.id)

      if (existing_vp.size == 0)
        vendor_product = VendorProduct.new(
          vendor_id: vendor.id,
           product_id: product.id
            )
        unless vendor_product.save
          puts "vendor_product Save Error: #{vendor_product.errors.messages}"
        end
      end
    end

    # #check average price - if exists, update price, if not create
    average_prices = AveragePrice.where(product_id: product.id).where(average_price_unit: average_price_unit)

    price = nil
    if item["product_price"].index("$") != nil
      price = item["product_price"].chomp("$").strip.to_f
    else
      price = item["product_price"].to_f
    end

    if (average_prices.size == 0)
      average = AveragePrice.new(
        product_id: product.id,
         average_price: price,
         average_price_unit: average_price_unit
       )
      unless average.save
        puts "average Save Error: #{average.errors.messages}"
      end
    else
      average_prices[0].update_attribute :average_price, price
    end
  end # end of checkVendorAndProduct method
end
