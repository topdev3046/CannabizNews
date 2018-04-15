class ArticlesController < ApplicationController
    before_action :set_article, only: [:edit, :update, :destroy, :show, :tweet, :send_tweet]
    before_action :require_admin, except: [:index, :show]
    skip_before_action :verify_authenticity_token #for saving article via ajax

    #--------ADMIN PAGE-------------------------
    def admin
        @articles = Article.order(sort_column + " " + sort_direction)
                        .paginate(page: params[:page], per_page: 100)
    
        #for csv downloader
        respond_to do |format|
            format.html
            format.csv {render text: @articles.to_csv }
        end
    end
    
    #method is used for csv file upload
    def import
        Article.import(params[:file])
        flash[:success] = 'Articles were successfully imported'
        redirect_to article_admin_path 
    end
    
    def search
        @q = "%#{params[:query]}%"
        @articles = Article.where("title LIKE ? or abstract LIKE ?", @q, @q)
                            .order(sort_column + " " + sort_direction)
                            .paginate(page: params[:page], per_page: 24)
        render 'admin'
    end
    
    def tweet
        #not on admin page but admin functionality
        
        require 'open-uri'
        #this will be the link when live
	    #link = u"http://cannabiznetwork.com/articles/#{@article.id}"
	    
	    #testing link
	    link = URI::encode("http://cannabiz-news.herokuapp.com/articles/#{@article.id}")
	    
	   	bitlyResponse = HTTParty.get("https://api-ssl.bitly.com/v3/shorten?" + 
	   	                "access_token=6a88d948272321a232f973370fd36ebafce5d121&longUrl=#{link}")
	   	
	   	@bitlyLink = ''
	   	
	   	if bitlyResponse["data"] != nil && bitlyResponse["data"]["url"] != nil
	   		@bitlyLink = bitlyResponse["data"]["url"]		
	   	end
    end
    
    #method saves an external click of an article link (goes to external page)
    def save_visit

        if params[:id].present?
            
           #query for article
           @article = Article.find(params[:id])
           @article.increment(:external_visits, by = 1)
           @article.save
        
           @source = @article.source
           @source.increment(:external_article_visits, by = 1)
           @source.save
        else
            redirect_to root_path     
        end
    end
    
    #user saves an article for later
    def user_article_save

        if !logged_in?
            redirect_to login_path
        end 
        if params[:id].present?
            
            #if a user has already saved or viewed this article, just use the same record
            if UserArticle.where(:article_id => params[:id], :user_id => current_user.id).any?
                @current_user_article = UserArticle.where(:article_id => params[:id], :user_id => current_user.id)
                if (@current_user_article[0].saved == true) 
                    @current_user_article[0].update_attribute :saved, false
                else 
                    @current_user_article[0].update_attribute :saved, true
                end
            else 
                UserArticle.create(user_id: current_user.id, article_id: params[:id], saved: true)
            end

            
        end
    end     
    
    def send_tweet
        
       	require 'rubygems'
		require 'oauth'
		require 'json'
		
		if params[:tweet_body].present?
		    
            client = Twitter::REST::Client.new do |config|
                config.consumer_key    = "PeKIPXsMPl80fKm6SipbqrRVL"
                config.consumer_secret = "EzcwBZ1lBd8RlnhbuDyxt3URqPyhrBpDq00Z6n4btsnaPF7VpO"
                config.access_token    = "418377285-HfXt8G0KxvBhNXQJRnnysTvt7yGAM0jWyfaIKSIU"
                config.access_token_secret = "3QF4wvh1ESmSuKqWztD8LibyVJHhYNMcc93YlTWdrPqez"
            end
            
            if @article.image.present?
                data = open(@article.image.to_s) #when I didnt store image, i didnt have to do to_s
                client.update_with_media(params[:tweet_body], File.new(data))
            else 
                client.update(params[:tweet_body])
            end
            
            flash[:success] = 'Tweet Sent'
            redirect_to root_path
            
        else
            flash[:danger] = 'No Tweet Sent'
            redirect_to root_path
        end
    end
    
    
    #not on admin page but admin functionality
    def digest
       @articles = Article.where(include_in_digest: true)
    end
    
    def send_weekly_digest
        WeeklyDigestJob.perform_later()
        flash[:success] = 'Digest will be sent out soon'
        redirect_to admin_path
    end
    
    def update_states_categories
    end
    
    def update_article_tags
        SetArticlesJob.perform_later() 
        flash[:success] = 'Articles will continue to update in the background'
        redirect_to admin_path
    end
        
    
    #--------ADMIN PAGE-------------------------
    
    def index
        #only showing articles for active sources 
        @recents = Article.active_source.order("created_at DESC").paginate(:page => params[:page], :per_page => 24)
        @mostviews = Article.active_source.where("created_at >= ?", 1.month.ago.utc).
                        order("num_views DESC").
                        paginate(:page => params[:page], :per_page => 24)
        
        respond_to do |format|
          format.html
          format.js # add this line for your js template
        end
    end

    def new
      @article = Article.new
    end
    
    def create
        @article = Article.new(article_params)
        
        if @article.save
            flash[:success] = 'Article was successfully created'
            redirect_to article_admin_path
        else 
            render 'new'
        end
    end 
    #-----------------------------------
    
    def show
        
        # go back if source not active
        if @article.source.active == false
            redirect_to root_path
        end
        
        #related articles
        if @article.states.present?
            @related_articles = @article.states.sample.articles
        elsif @article.categories.present?
            @related_articles = @article.categories.sample.articles
        else
            @related_articles = Article.all
        end
        
        @related_articles = @related_articles.active_source.includes(:source, :states, :categories).
                                order("created_at DESC").limit(3).where.not(id: @article.id)
        
        
        #we will now show some top products instead of related articles
        # @top_products = Product.featured.joins(:dispensary_source_products, :average_prices).group("products.id").
        #                             having("count(dispensary_source_products.id)>4").
        #                             #having("count(average_prices.id)>0").
        #                             includes(:vendors, :category, :average_prices).
        #                             order("RANDOM()").limit(3)
                                    
        @top_products = Product.featured.joins(:dispensary_source_products).
                        group("products.id").
                        having("count(dispensary_source_products.id)>4").
                        includes(:vendors, :category, :average_prices).
                        order("RANDOM()").limit(3)
        
        logger.info 'size of list ' +  @top_products.length.to_s
        logger.info @top_products.length
        
        
        
        
        #SAME SOURCE ARTICLES
        @same_source_articles = Article.where(source_id: @article.source).order("created_at DESC").
                                    limit(3).where.not(id: @article.id).
                                    includes(:source, :states ,:categories)
        
        #add view to article for sorting
        @article.increment(:num_views, by = 1)
        @article.save
        
        #add userView record
        # if current_user
        #     #the table isn't created yet
        # end
    end
    
    
    #-----------------------------------
    def edit
    end   
    def update
        if @article.update(article_params)
            flash[:success] = 'Article was successfully updated'
            redirect_to article_admin_path
        else 
            render 'edit'
        end
    end 
    #-----------------------------------
   
    def destroy
        @article.destroy
        flash[:success] = 'Article was successfully deleted'
        redirect_to article_admin_path
    end 
   
    def destroy_multiple
      Article.destroy(params[:articles])
      flash[:success] = 'Articles were successfully deleted'
      redirect_to article_admin_path        
    end   
    
    private 
        def require_admin
            if !logged_in? || (logged_in? and !current_user.admin?)
                redirect_to root_path
            end
        end
        
        def set_article
            @article = Article.friendly.find(params[:id])
            if @article.blank?
                redirect_to root_path 
            end
        end
        def article_params
            params.require(:article).permit(:title, :abstract, :body, :date, :image, :remote_image_url, :web_url,
                                    :source_id, :include_in_digest, state_ids: [], category_ids: [])
        end
      
        def sort_column
            params[:sort] || "date"
        end
        def sort_direction
            params[:direction] || 'desc'
        end
          
end