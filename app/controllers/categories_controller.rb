# frozen_string_literal: true

class CategoriesController < ApplicationController
  before_action :set_category, only: [:edit, :update, :destroy, :show]
  before_action :require_admin, except: [:show]

  def show
    if @category.category_type != "News"
      redirect_to root_path
    end

    @recents = @category.articles.active_source.includes(:source, :categories, :states).
                        order("created_at DESC").paginate(page: params[:page], per_page: 24)

    @mostviews = @category.articles.active_source.includes(:source, :categories, :states).
                            order("num_views DESC").paginate(page: params[:page], per_page: 24)
  end

    private

      def require_admin
        if !logged_in? || (logged_in? && !current_user.admin?)
          redirect_to root_path
        end
      end

      def set_category
        if marshal_load($redis.get("category_#{params[:id]}")).blank?
          @category = Category.friendly.find(params[:id])
          set_into_redis
        else
          get_from_redis
        end
        if @category.blank?
          redirect_to root_path
        end
      end

      def set_into_redis
        if $redis.info["used_memory_human"].to_f < $redis.info["maxmemory_human"].to_f
          $redis.set("category_#{params[:id]}", marshal_dump(@category))
        end
      end

      def get_from_redis
        @category = marshal_load($redis.get("category_#{params[:id]}"))
      end
end
