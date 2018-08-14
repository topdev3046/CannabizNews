# frozen_string_literal: true

class StatesController < ApplicationController
  before_action :set_state, only: [:edit, :update, :destroy, :show]
  before_action :require_admin, only: [:edit, :update, :destroy, :admin]

  def show
    @recents = @state.articles.active_source.includes(:source, :categories, :states).
                        order("created_at DESC").paginate(page: params[:page], per_page: 24)

    @mostviews = @state.articles.active_source.includes(:source, :categories, :states).
                            order("num_views DESC").paginate(page: params[:page], per_page: 24)
  end

    private

      def set_state
        if marshal_load($redis.get("state_#{params[:id]}")).blank?
          @state = State.friendly.find(params[:id])
          set_into_redis
        else
          get_from_redis
        end
        if @state.blank?
          redirect_to root_path
        end
      end

      def set_into_redis
        if $redis.info["used_memory_human"].to_f < $redis.info["maxmemory_human"].to_f
          $redis.set("state_#{params[:id]}", marshal_dump(@state))
        end
      end

      def get_from_redis
        @state = marshal_load($redis.get("state_#{params[:id]}"))
      end
end
