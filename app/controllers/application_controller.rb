# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # these methods will be called before every action
  before_action :populate_lists, :skip_for_admin?, :site_visitor_location

  helper_method :current_user, :logged_in?

  def skip_for_admin?
    current_admin_user.blank?
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !!current_user
  end

  def require_user
    if !logged_in?
      flash[:danger] = "You must be logged in to perform that action"
      redirect_to root_path
    end
  end

  def require_admin
    if !logged_in? || (logged_in? && !current_user.admin?)
      redirect_to root_path
    end
  end

  def site_visitor_location
    # comment
    begin

      if request.remote_ip.present? && GeoIP.new("GeoLiteCity.dat").city(request.remote_ip).try(:real_region_name).present?

        name = GeoIP.new('GeoLiteCity.dat').city(request.remote_ip).try(:real_region_name)
        if name.present? && @site_visitor_state = State.find_by(name: name.strip)
          puts "i got a state from first one"
        else
          if request.safe_location && request.safe_location.state.present?
            @site_visitor_state = State.where(name: request.safe_location.state.strip).first
            puts "i got a state from second one"
          else
            default_visitor_location
          end
        end
      elsif request.safe_location && request.safe_location.state.present?
        @site_visitor_state = State.where(name: request.safe_location.state.strip).first
        puts "i got a state from second one"
      else
        default_visitor_location
      end

      if @site_visitor_state.blank?
        default_visitor_location
      end
    rescue => ex
      ErrorFound.email("Site Visitor Location", ex.inspect, ex.message, ex.backtrace.join("\n")).deliver_now
      default_visitor_location
    end
  end

  def default_visitor_location
    @site_visitor_state = State.where(name: "Washington").first
    @site_visitor_city = "Seattle"
    @site_visitor_zip = "98101"
    @site_visitor_ip = "75.172.101.74"
  end

  def populate_lists
    require "will_paginate/array"

    @news_categories = Category.news.active.order("name ASC")
    @product_categories = Category.products.active.order("name ASC")
    @all_states = State.all.order("name ASC")
    @states_with_products = @all_states.where(product_state: true)
    @active_sources = Source.where(active: true).order("name ASC")

    @az_values = ["#", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
                        "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
  end

  # redirect to homepage on error
  rescue_from ActionView::MissingTemplate, with: :handle_error
  rescue_from ActionView::Template::Error, with: :handle_error
  rescue_from ActiveRecord::RecordNotFound, with: :handle_error
  rescue_from ActiveRecord::StatementInvalid, with: :handle_error
  rescue_from ActionController::RoutingError, with: :handle_error

    private

      def handle_error(exception)
        if Rails.env.production?
          # ErrorFound.email("There is an error:", 'Application Controller', '', exception).deliver_now
          redirect_to root_path
        end
      end

      def marshal_dump(object)
        data = Marshal.dump(object)
        data
      end

      def marshal_load(data)
        object = Marshal.load(data) rescue nil
        object
      end
end
