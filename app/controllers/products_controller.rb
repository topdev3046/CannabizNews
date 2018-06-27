class ProductsController < ApplicationController  
    before_action :set_product, only: [:edit, :update, :destroy, :show, :change_state]
    before_action :require_admin, only: [:admin, :edit, :update, :delete]
    
    def index
        
        if params[:format].present?
            
            @searched_category = @product_categories.find_by(name: params[:format])
            
            if !@searched_category.present?
                if params[:format] == 'Hybrid-Indica'
                    @searched_is_dom = 'Indica'
                elsif params[:format] == 'Hybrid-Sativa'
                    @searched_is_dom = 'Sativa'
                else
                    @searched_sub_category = params[:format] 
                end
            end
        end
        
        @products = Product.featured.left_join(:dispensary_source_products).group(:id).
                    order('COUNT(dispensary_source_products.id) DESC').
                    includes(:vendors, :category, :average_prices)

        if @searched_category.present?
            
            @products = @products.where(category_id: @searched_category.id)
            @search_string = "#{@searched_category.name}"
        
        elsif @searched_sub_category.present? 
        
            @products = @products.where(sub_category: @searched_sub_category).where(is_dom: nil)
            @search_string = "#{@searched_sub_category}"
        
        elsif @searched_is_dom.present?    
        
            @products = @products.where(is_dom: @searched_is_dom)
            @search_string = "Hybrid-#{@searched_is_dom}"

        end

        @products = @products.paginate(page: params[:page], per_page: 16)

    end
    
    def refine_index
        
        result = ProductFinder.new(params, @states_with_products).build
        
        #parse returns
        @products, @search_string, @searched_name, @az_letter, 
            @searched_category, @searched_location, @searched_state = 
                result[0], result[1], result[2], result[3], result[4], result[5], result[6]
        
        @products = @products.paginate(page: params[:page], per_page: 16)
        
        render 'index' 
    end
    
    #------------------------------------
    
    def show
        
        #only show featured product
        if @product.featured_product == false
            redirect_to root_path 
        end
        
        state_used = nil
        avg_price = nil
        
        if params[:average_price_id].present?
            if @average_price = AveragePrice.find_by(id: params[:average_price_id])
                avg_price = @average_price
            end
        end
        
        if params[:state_id].present?
            if @searched_state = State.find_by(id: params[:state_id])
                state_used = @searched_state
                @site_visitor_state = state_used
            else 
                state_used = @site_visitor_state
            end
        else 
            state_used = @site_visitor_state
        end
        
        #default state to washington
        if !state_used.product_state
           state_used = State.find_by(name: 'Washington')
           @searched_state = state_used
        end
        
        begin
            result = ProductHelper.new(@product, state_used, avg_price).buildSimilarProducts
            @similar_products = result[0]
        
            result = ProductHelper.new(@product, state_used, avg_price).buildProductDisplay
            @dispensary_to_product, @table_header_options = result[0], result[1]    
        rescue => ex
            puts 'here is the error: '
            puts ex.backtrace
            # redirect_to root_path              
        end 
    end
    
    def change_state
        
        puts 'here are the params'
        puts params 
        
        state_used = nil
        avg_price = nil
        
        #only show featured product
        if @product.featured_product == false
            redirect_to root_path 
        end
        
        if params[:average_price_id].present?
            if @average_price = AveragePrice.find_by(id: params[:average_price_id])
                avg_price = @average_price
            end
        end
        
        if params[:State].present?
            if @searched_state = State.find_by(name: params[:State])
                state_used = @searched_state
            else 
                state_used = @site_visitor_state
            end
        else 
            state_used = @site_visitor_state
        end
        
        #default washington
        if !state_used.product_state
            @searched_state = State.find_by(name: 'Washington')
            state_used = @searched_state
        end
        
        begin
            result = ProductHelper.new(@product, @searched_state, @average_price).buildSimilarProducts
            @similar_products = result[0]
            
            puts 'i am here 186'
        
            result = ProductHelper.new(@product, @searched_state, @average_price).buildProductDisplay
            @dispensary_to_product, @table_header_options = result[0], result[1] 
            
            puts 'i am here 191'
            
            render 'show'
        rescue => ex
            puts 'here is the error: '
            puts ex
            redirect_to root_path              
        end
        
    end

    def autocomplete_search
        query_term = params[:term]
        @products = Product.featured.where("lower(name) like (?)","%#{query_term.to_s.downcase}%")
        respond_to do |format|  
          format.html {redirect_to root_path }
          format.json { render :json => @products.to_json }
        end
    end

    private
    
        def require_admin
            if !logged_in? || (logged_in? and !current_user.admin?)
                #flash[:danger] = 'Only administrators can visit that page'
                redirect_to root_path
            end
        end
        
        def set_product
            if marshal_load($redis.get("product_#{params[:id]}")).blank?
                @product = Product.friendly.find(params[:id])
                set_into_redis
            else
                get_from_redis
            end
            if @product.blank?
                redirect_to root_path 
            end
        end
        
        def set_into_redis
            $redis.set("product_#{params[:id]}", marshal_dump(@product))
        end

        def get_from_redis
            @product = marshal_load($redis.get("product_#{params[:id]}")) 
        end
end