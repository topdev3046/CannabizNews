class Product < ActiveRecord::Base
    
    #scope
    scope :featured, -> { where(featured_product: true) }
    
    #relationships
    belongs_to :category
    
    has_many :product_states
    has_many :states, through: :product_states
    
    has_many :vendor_products, -> { order(:units_sold => :desc) }
    has_many :vendors, through: :vendor_products
    
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
    
    #delete relations
    before_destroy :delete_relations
    def delete_relations
       self.dispensary_source_products.destroy_all
       self.average_prices.destroy_all
    end
    
end