class SitemapsController < ApplicationController
  def index
    @static_pages = [root_url]
    @products = Product.featured
    @vendors = Vendor.all
    @dispensaries = Dispensary.all
    @articles = Article.all
    @blogs = Blog.published.order("published_date DESC")

    respond_to do |format|
      format.xml
    end
  end
end