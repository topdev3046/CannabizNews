ActiveAdmin.register DispensarySourceProduct, as: "Dispensary Products" do
  
  menu priority: 5
  
  permit_params :dispensary_source_id, :product_id, dsp_prices_attributes: [:id, :price, :unit, :_destroy]
   
  #scopes
	scope :all, default: true
	scope :for_featured
	
  #save queries
  includes :dispensary_source, :product => :category
  
  index do
    selectable_column
    column :id
    column "Dispensary Source" do |dsp|
      if dsp.dispensary_source.present? && dsp.dispensary_source.source.present?
        link_to "#{dsp.dispensary_source.name} - #{dsp.dispensary_source.source.name}", admin_dispensary_source_path(dsp.dispensary_source)
      end
    end
    column "Product" do |dsp|
      if dsp.product.present?
        link_to dsp.product.name , admin_product_path(dsp.product)
      end
    end
    column "Product Category" do |dsp|
      if dsp.product.present? && dsp.product.category.present? 
        link_to dsp.product.category.name , admin_category_path(dsp.product.category)
      end
    end
    column :created_at
    column :updated_at
    actions
  end

end


