class VendorsController < ApplicationController
    
    before_action :set_vendor, only: [:edit, :update, :destroy, :show]
    before_action :require_admin, except: [:show, :index]
    
    def index
        if @site_visitor_state.product_state?
            @vendors = Vendor.where(state_id: @site_visitor_state.id).order("RANDOM()").paginate(page: params[:page], per_page: 16)
        else
            @vendors = Vendor.order("RANDOM()").paginate(page: params[:page], per_page: 16)
        end
    end
    
    def refine_index
        
        result = VendorFinder.new(params).build
        
        #parse returns
        @vendors, @search_string, @searched_name, @az_letter =
                result[0], result[1], result[2], result[3]
        
        @vendors = @vendors.paginate(page: params[:page], per_page: 16)
        
        render 'index'
    end
    
    #-------------------------------------------

    def show
        @vendor_products = @vendor.products.featured.includes(:average_prices, :vendors, :category).
                                paginate(:page => params[:page], :per_page => 8)
    end
  
    private
    
        def require_admin
            if !logged_in? || (logged_in? and !current_user.admin?)
                #flash[:danger] = 'Only administrators can visit that page'
                redirect_to root_path
            end
        end

        def set_vendor
            @vendor = Vendor.friendly.find(params[:id])
        end
        
end