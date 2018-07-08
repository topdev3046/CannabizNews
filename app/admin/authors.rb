ActiveAdmin.register Author do
    menu :if => proc{ current_admin_user.admin? }
	
	permit_params :name
	
	#use with friendly id
    before_filter :only => [:show, :edit, :update, :delete] do
    	@author = Author.friendly.find(params[:id])
    end

end
