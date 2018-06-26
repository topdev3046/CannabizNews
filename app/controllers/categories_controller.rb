class CategoriesController < ApplicationController
    
    before_action :set_category, only: [:edit, :update, :destroy, :show]
    before_action :require_admin, except: [:show]
    
    def show
        
        if @category.category_type != 'News'
            redirect_to root_path 
        end
        
        @recents = @category.articles.active_source.includes(:source, :categories, :states).
                            order("created_at DESC").paginate(:page => params[:page], :per_page => 24)
                            
        @mostviews = @category.articles.active_source.includes(:source, :categories, :states).
                                order("num_views DESC").paginate(:page => params[:page], :per_page => 24)
    end
  
    private
    
        def require_admin
            if !logged_in? || (logged_in? and !current_user.admin?)
                redirect_to root_path
            end
        end
        
        def set_category
            @category = Category.friendly.find(params[:id])
        end
end