# frozen_string_literal: true

class SitemapsController < ApplicationController
  def index
    @static_pages = [root_url]
    @products = Product.featured
    @blogs = Blog.published_blogs.order("published_date DESC")
    @vendors = Vendor.all
    @dispensaries = Dispensary.all
    # @articles = Article.all


    respond_to do |format|
      format.xml
    end
  end
end
