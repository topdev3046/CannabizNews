class BlogController < ApplicationController
    before_action :set_blog, only: [:show]
    
    def show
        
        # go back if not published
        if @blog.published
            
            #site visitor state
            if params[:state].present?
                if state = State.find_by(name: params[:state])
                    @site_visitor_state = state
                end
            end
        
            #product sidebar
            if @site_visitor_state.present? && @site_visitor_state.product_state
                
                if Rails.env.production? 
                    @top_products = @site_visitor_state.products.featured.joins(:dispensary_source_products).group("products.id").having("count(dispensary_source_products.id)>4").
                                        includes(:vendors, :category, :average_prices).
                                        order("RANDOM()").limit(3)
                else
                    @top_products = @site_visitor_state.products.featured.includes(:vendors, :category, :average_prices).
                                        order("RANDOM()").limit(3)
                end
            else 
                @top_products = Product.featured.joins(:dispensary_source_products).group("products.id").having("count(dispensary_source_products.id)>4").
                                        includes(:vendors, :category, :average_prices).
                                        order("RANDOM()").limit(3)
            end
    
            @other_blog_posts = Blog.where.not(id: @blog.id).order("RANDOM()").limit(3)
            
            #add view to post for sorting
            @blog.increment(:num_views, by = 1)
            @blog.save
        else
            redirect_to root_path
        end
        
    end
    
    def index
        
        begin 
            #site visitor state
            if params[:state].present?
                if state = State.find_by(name: params[:state])
                    @site_visitor_state = state
                end
            end
            
            @blogs = Blog.published.order("published_date DESC").paginate(:page => params[:page], :per_page => 8)
           
            #product sidebar
            if @site_visitor_state.present? && @site_visitor_state.product_state
                
                if Rails.env.production? 
                    @top_products = @site_visitor_state.products.featured.joins(:dispensary_source_products).group("products.id").having("count(dispensary_source_products.id)>4").
                                        includes(:vendors, :category, :average_prices).
                                        order("RANDOM()").limit(10)
                else
                    @top_products = @site_visitor_state.products.featured.includes(:vendors, :category, :average_prices).
                                        order("RANDOM()").limit(10)
                end
            else 
                @top_products = Product.featured.joins(:dispensary_source_products).group("products.id").having("count(dispensary_source_products.id)>4").
                                        includes(:vendors, :category, :average_prices).
                                        order("RANDOM()").limit(10)
            end
        rescue => ex
            puts 'HERE IS THE ERROR: '
            puts ex
            ErrorFound.email('Blog Index', ex.inspect, ex.message, ex.backtrace.join("\n")).deliver_now   
        end
    end

    private 
        
        def set_blog
            @blog = Blog.friendly.find(params[:id])
            if @blog.blank?
                redirect_to root_path 
            end
        end
end