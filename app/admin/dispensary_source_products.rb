ActiveAdmin.register DispensarySourceProduct, as: "Dispensary Products" do
  
    menu priority: 5
    
    permit_params :dispensary_source_id, :product_id, dsp_prices_attributes: [:id, :price, :unit, :_destroy]
    
    #scopes
    scope :all, default: true
    scope :for_featured
    
    #filters
    filter :"dispensary_source_id" , :as => :select, :collection => DispensarySource.order("name ASC").map{|u| [u.name , u.id]}
    filter :"product_id" , :as => :select, :collection => Product.order("name ASC").map{|u| [u.name , u.id]}
    
    #save queries
    includes :dispensary_source, :product => :category
  
    index do
        selectable_column
        column :id
        column "Dispensary Source", :sortable=>:"dispensary_sources.name" do |dsp|
            if dsp.dispensary_source.present? && dsp.dispensary_source.source.present?
                link_to "#{dsp.dispensary_source.name} - #{dsp.dispensary_source.source.name}", admin_dispensary_source_path(dsp.dispensary_source)
            end
        end
        column "Product", :sortable=>:"products.name" do |dsp|
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


