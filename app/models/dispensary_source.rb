class DispensarySource < ActiveRecord::Base
    
    #scope for admin panel
    scope :has_admin, -> { where.not(admin_user_id: nil) }
    
    #relationships
    belongs_to :source
    belongs_to :dispensary
    belongs_to :state
    belongs_to :admin_user
    
    #many to many with products
    has_many :dispensary_source_products, -> { order(:product_id => :asc) }
    has_many :products, through: :dispensary_source_products
    
    #validations
    validates :dispensary_id, presence: true
    validates :source_id, presence: true
    
    #geocode location
    geocoded_by :location
    after_validation :geocode
    
    #photo aws storage
    mount_uploader :image, PhotoUploader
    
    #import CSV file
    def self.import(file)
        CSV.foreach(file.path, headers: true) do |row|
            DispensarySource.create! row.to_hash
        end
    end
    
    #export CSV file
    def self.to_csv
        CSV.generate do |csv|
            csv << column_names
            all.each do |dispensarySource|
                csv << dispensarySource.attributes.values_at(*column_names)
            end
        end
    end    
    
    #delete relations
    before_destroy :delete_relations
    def delete_relations
       self.dispensary_source_products.destroy_all
    end
    
    #set location from other fields
    def location
		"#{street}, #{city}, #{state.name}, #{zip_code}"
	end
    
end