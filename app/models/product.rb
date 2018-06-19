class Product < ActiveRecord::Base
    
    #scope
    scope :featured, -> { where(featured_product: true) }
    
    #relationships
    belongs_to :category
    
    has_many :product_states
    has_many :states, through: :product_states
    
    #many to many for flowers and prerolls, one to many for other categories
    has_many :vendor_products, -> { order(:units_sold => :desc) }
    has_many :vendors, through: :vendor_products
    belongs_to :vendor
    
    has_many :average_prices, -> { order(:display_order => :asc) }
    
    has_many :dispensary_source_products
    has_many :dispensary_sources, through: :dispensary_source_products
    
    #friendly url
    extend FriendlyId
    friendly_id :name, use: :slugged
    
    #photo aws storage
    mount_uploader :image, PhotoUploader
    
    #validations
    validates :name, presence: true
    validates_uniqueness_of :name, :scope => :category_id #no duplicate products per category
    
    #increment the counters for headset whenever an existing product appears
    def increment_counters
       self.headset_alltime_count += 1 
       self.headset_monthly_count += 1
       self.headset_weekly_count += 1
       self.headset_daily_count += 1
       self.save
    end
    
    #import CSV file
    def self.import(file)
        CSV.foreach(file.path, headers: true, skip_blanks: true) do |row|
            
            #change to update record if id matches
            product_hash = row.to_hash
            product = self.where(id: product_hash["id"])
            
            if product.present? 
                product.first.update_attributes(product_hash)
            else
                #Product.create! product_hash
            end
        end
    end    
    
    #export CSV file
    def self.to_csv
        CSV.generate do |csv|
            csv << column_names
            all.each do |product|
                values = product.attributes.values_at(*column_names)
                values += [product.image.to_s]
                values += [product.category.name] if product.category
                csv << values
            end
        end
    end
    
    #stock image
    def default_image
        if Rails.env.production? && self.category.present?
            if self.category.name == 'Flower'
                return_image = 'substitutes/default_flower.jpg'
            
            elsif self.category.name == 'Concentrates'
                return_image = 'substitutes/default_concentrate.jpeg'
            
            elsif self.category.name == 'Edibles'
                return_image = 'substitutes/default_edible.jpg'
                
            elsif self.category.name == 'Pre-Rolls'
                return_image = 'substitutes/default_preroll.jpg'
            
            else
                return_image = 'substitutes/default_flower.jpg'    
            end
        else
            return_image = 'home_top_product.jpg'
        end
       return_image
    end
    
    #delete relations
    before_destroy :delete_relations
    def delete_relations
       self.dispensary_source_products.destroy_all
       self.average_prices.destroy_all
       self.vendor_products.destroy_all
       self.product_states.destroy_all
    end
    
    #set redis key after save
    after_save :set_redis_key
    def set_redis_key
        if self.slug.present?
            $redis.set("product_#{self.slug}", Marshal.dump(self))   
        end
    end
end