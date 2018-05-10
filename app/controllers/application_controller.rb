class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  #set lists before all actions
  before_action :populate_lists
  
  helper_method :current_user, :logged_in?
  
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
  
  def site_visitor_state
    @site_visitor_state = State.where(name: 'Washington').first 
    
    #geocode user api
    #if request.location && request.location.state
    #    @site_visitor_state = State.where(name: request.location.state).first
    #end
  end
  
  def site_visitor_city
    #geocode user api
    @site_visitor_city = 'Seattle'
    #if request.location && request.location.city
    #    @site_visitor_city = request.location.city
    #end
  end
  
  def site_visitor_zip
    #geocode user api
    @site_visitor_zip = '98101'
    #if request.location && request.location.zip_code
    #    @site_visitor_zip = request.location.zip_code
    #end
  end
  
  def site_visitor_ip
    #geocode user api
    @site_visitor_ip = '75.172.101.74'
    #if request.location && request.location.ip
    #    @site_visitor_ip = request.location.ip
    #end
  end
  
  def populate_lists
    require 'will_paginate/array'
    @news_categories = Category.news.active.order("name ASC")
    @product_categories = Category.products.active.order("name ASC")
    @states = State.all.order("name ASC")
    @product_states = @states.where(product_state: true)
    @sources = Source.where(:active => true).order("name ASC")
    @az_values = ['#', 'A','B','C','D','E','F','G','H','I','J','K','L','M',
                        'N','O','P','Q','R','S','T','U','V','W','X','Y','Z']
  end
  
  #redirect to homepage on error
  rescue_from ActionView::MissingTemplate, :with => :handle_error
  rescue_from ActiveRecord::RecordNotFound, :with => :handle_error
  rescue_from ActiveRecord::StatementInvalid, :with => :handle_error
  rescue_from ActionController::RoutingError, :with => :handle_error

  private
  
    def handle_error
      if Rails.env.Production? 
        redirect_to root_path
      end
    end
end
