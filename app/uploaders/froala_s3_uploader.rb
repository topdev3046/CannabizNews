
# encoding: utf-8

class FroalaS3Uploader < CarrierWave::Uploader::Base

    include CarrierWave::MiniMagick #adds ability to resize images
    include CarrierWave::ImageOptimizer
    include Sprockets::Rails::Helper
    
    process :optimize
    
    storage :fog #connects application and AWS
    
    #where to store the image
    def store_dir
        "uploads/blog/#{DateTime.now.to_i}"
    end
    
    #specifies the file types we can take
    #if we wanted file upload we would use different file sizes
    def extension_white_list
        %w(jpg jpeg gif png)
    end
  
end