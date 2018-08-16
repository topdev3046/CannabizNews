ActiveAdmin.register Vendor do
	menu :if => proc{ current_admin_user.admin? || current_admin_user.read_only_admin? }
	
	permit_params :name, :description, :image, :tier, :vendor_type, 
	                :address, :total_sales, :license_number, :ubi_number, :dba, :month_inc, 
	                :year_inc, :month_inc_num
	
	index do
		selectable_column
		id_column
		column :name
		column "Description", :sortable=>:"vendors.description" do |vendor|
			truncate(vendor.description, omision: "...", length: 50) if vendor.description
        end
        column "Image", :sortable=>:"vendors.image" do |vendor|
			truncate(vendor.image_url, omision: "...", length: 50) if vendor.image_url
        end
		column :created_at
		column :updated_at
		actions
	end
end