class DispensariesController < ApplicationController
    before_action :set_dispensary, only: [:edit, :update, :destroy, :show, :all_products]
    before_action :require_admin, only: [:admin, :edit, :update, :destroy]
    
    def index
        
        if @site_visitor_state != nil
            @dispensaries = Dispensary.where(state: @site_visitor_state).
                                order("name ASC").paginate(page: params[:page], per_page: 16)
            @search_string = @site_visitor_state.name
        else
            @dispensaries = Dispensary.order("name ASC").paginate(page: params[:page], per_page: 16)
        end
        
        #az-list
        
        
    end
    
    def refine_index
        
        result = DispensaryFinder.new(params).build
        
        #parse returns
        @dispensaries, @search_string, @searched_name, @az_letter, 
            @searched_location, @searched_state = 
                result[0], result[1], result[2], result[3], result[4], result[5]
        
        
        @dispensaries = @dispensaries.paginate(page: params[:page], per_page: 16)
        
        render 'index'
    end
    
    #---------

    def show
        
        require 'uri' #google map / facebook
        
        @dispensary_source = @dispensary.dispensary_sources.order('last_menu_update DESC').first
        @dispensary_source_products = @dispensary_source.dispensary_source_products.
                    includes(:dsp_prices, product: [:category, :vendors, :vendor])
        
        @category_to_products = Hash.new
        
        @dispensary_source_products.each do |dsp|
            
            if dsp.product.present? && dsp.product.featured_product && dsp.product.category.present?
                if @category_to_products.has_key?(dsp.product.category.name)
                    @category_to_products[dsp.product.category.name].push(dsp)
                else
                    @category_to_products.store(dsp.product.category.name, [dsp])
                end
            end
            
        end
        
    end
    
    #-------------------------------------    
    def edit
    end   
    def update
        if @dispensary.update(dispensary_params)
            flash[:success] = 'Dispensary was successfully updated'
            redirect_to dispensary_admin_path
        else 
            render 'edit'
        end
    end
    #-------------------------------------
   
    def destroy
        @dispensary.destroy
        flash[:success] = 'Dispensary was successfully deleted'
        redirect_to dispensary_admin_path
    end  
    
    def destroy_multiple
      Dispensary.destroy(params[:dispensaries])
      flash[:success] = 'Dispensaries were successfully deleted'
      redirect_to dispensary_admin_path        
    end 
    
    #-------------------------------------
    private 
        
        def require_admin
            if !logged_in? || (logged_in? and !current_user.admin?)
                #flash[:danger] = 'Only administrators can visit that page'
                redirect_to root_path
            end
        end
        def set_dispensary
            @dispensary = Dispensary.friendly.find(params[:id])
        end
        def dispensary_params
            params.require(:dispensary).permit(:name, :image, :location, :city, :state_id, :has_hypur, :has_payqwick)
        end
end