# frozen_string_literal: true

ActiveAdmin.register AveragePrice do

	menu :if => proc{ current_admin_user.admin? || current_admin_user.read_only_admin? }
	
	permit_params :product_id, :average_price, :average_price_unit, :units_sold, :display_order
	
	#save queries
	includes :product
	
	#filters
	filter :"product_id" , :as => :select, :collection => Product.all.map{|u| [u.name , u.id]}
	filter :average_price
	filter :average_price_unit
	
	#import csv
	action_item only: :index do
		if current_admin_user.admin?
			link_to 'Import Average Prices', admin_average_prices_import_average_prices_path, class: 'import_csv'
		end
	end
	
	#export csv
	csv do
		column :product_id
		column "Product" do |ap|
			if ap.product.present?
				ap.product.name
			end
		end
		column :average_price
		column :average_price_unit
		column :units_sold
		column :display_order
	end
	
	index do
		selectable_column
		column "Product", :sortable=>:"products.name" do |ap|
			if ap.product.present?
				link_to ap.product.name, admin_product_path(ap.product)
			end
		end
		column :average_price
		column :average_price_unit
		column :units_sold
		column :display_order
		column :created_at
		column :updated_at
		actions
	end

  form do |f|
      f.input :product_id, label: "Product", as: :select,
          collection: Product.all.map { |u| ["#{u.name}", u.id] }
      f.input :average_price
      f.input :average_price_unit
      f.input :units_sold
      f.input :display_order
      f.actions
    end

end
