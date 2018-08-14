# frozen_string_literal: true

base_url = "http://#{request.host_with_port}"
xml.instruct! :xml, version: "1.0"
xml.tag! "urlset", "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  xml.url {
    xml.loc("https://www.cannabiznetwork.com")
    xml.changefreq("daily")
    xml.priority(1.0)
  }
  @blogs.each do |blog|
    xml.url {
      xml.loc "#{blog_url(blog)}"
      xml.lastmod blog.published_date.strftime("%F")
      xml.changefreq("never")
      xml.priority(0.8)
    }
  end
  @products.each do |product|
    xml.url {
      xml.loc "#{product_url(product)}"
      xml.changefreq("weekly")
      xml.priority(0.8)
    }
  end
  @vendors.each do |vendor|
    xml.url {
      xml.loc "#{vendor_url(vendor)}"
      xml.changefreq("weekly")
      xml.priority(0.8)
    }
  end
  @dispensaries.each do |dispensary|
    xml.url {
      xml.loc "#{dispensary_url(dispensary)}"
      xml.changefreq("monthly")
      xml.priority(0.8)
    }
  end
end
