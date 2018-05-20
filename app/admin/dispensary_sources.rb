ActiveAdmin.register DispensarySource do

    
    permit_params :name, :admin_user_id, :state_id, :dispensary_id, :source_id,
            :image, :location, :street, :city, :zip_code, :last_menu_update,
            :facebook, :instagram, :twitter, :website, :email, :phone, :min_age,
            :monday_open_time, :monday_close_time, :tuesday_open_time, :tuesday_close_time,
            :wednesday_open_time, :wednesday_close_time, :thursday_open_time, :thursday_close_time,
            :friday_open_time, :friday_close_time, :saturday_open_time, :saturday_close_time,
            :sunday_open_time, :sunday_close_time
          
    
    filter :name
    filter :state_id
    
    #save queries
    includes :dispensary, :source, :state, :admin_user
  
    
    index do
        column :name
    
        column "Image" do |dispensary|
          truncate(dispensary.image_url, omision: "...", length: 50) if dispensary.image
        end
        
        if current_admin_user.admin?
            
            column "Dispensary" do |ds|
                if ds.dispensary.present?
                    link_to ds.dispensary.name, admin_dispensary_path(ds.dispensary_id)
                end
            end
            column "Source" do |ds|
                if ds.source.present?
                    link_to ds.source.name, admin_source_path(ds.source_id)
                end
            end
            column "Admin User" do |ds|
                link_to ds.admin_user.email, admin_admin_user_path(ds.admin_user_id) if ds.admin_user
            end
            column "State" do |ds|
                if ds.state.present?
                    link_to ds.state.name, admin_state_path(ds.state_id)
                end
            end
        end

        column :location

    
        column :updated_at
        #should make a new column thats like - awaiting approval - everytime they change it I set it
        actions
    end
end
