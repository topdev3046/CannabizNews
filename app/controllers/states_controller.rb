class StatesController < ApplicationController
    
    before_action :set_state, only: [:edit, :update, :destroy, :show]
    before_action :require_admin, only: [:edit, :update, :destroy, :admin]

    def show
        @recents = @state.articles.active_source.includes(:source, :categories, :states).
                            order("created_at DESC").paginate(:page => params[:page], :per_page => 24)
                            
        @mostviews = @state.articles.active_source.includes(:source, :categories, :states).
                                order("num_views DESC").paginate(:page => params[:page], :per_page => 24)
    end
    
    private 
        
        def set_state
            @state = State.friendly.find(params[:id])
        end
end