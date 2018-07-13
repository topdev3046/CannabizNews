ActiveAdmin.register Blog do
    menu :if => proc{ current_admin_user.admin? }, :label => 'Blog'
	
	permit_params :title, :body, :published, :published_date, :num_views, :image, :author_id
	
	#use with friendly id
    before_filter :only => [:show, :edit, :update, :delete] do
    	@blog = Blog.friendly.find(params[:id])
    end
    
    scope :all, default: true
	scope :published
	
	#filters
	filter :"author_id" , :as => :select, :collection => Author.all.map{|u| [u.name , u.id]}
    
	#-----CSV ACTIONS ----------#
    
    #import csv
	action_item only: :index do
		if current_admin_user.admin?
			link_to 'Import Blog Posts', admin_blogs_import_blogs_path, class: 'import_csv'
		end
	end
	
	collection_action :import_blogs do
		if request.method == "POST"
			if params[:blog][:file_name].present?
				Blog.import_from_csv(params[:blog][:file_name])
				flash[:notice] = "Blog imported successfully."
			end
			redirect_to admin_blogs_path
		end
	end	
	
	#-----CSV ACTIONS ----------#
    
    index do
		selectable_column
		id_column
		column "Title", :sortable=>:"blog.title" do |blog|
          truncate(blog.title, omision: "...", length: 50) if blog.title
        end
        column "Author",  :sortable=>:"authors.name" do |blog|
			if blog.author.present?
				link_to blog.author.name, admin_author_path(blog.author)
			end
		end
        column "Body", :sortable=>:"blog.body" do |blog|
          truncate(blog.body, omision: "...", length: 150) if blog.body
        end
        column "Image", :sortable=>:"blog.image" do |blog|
			if blog.image.present?
				image_tag blog.image_url, class: 'admin_image_size'
			end
		end
        column :published
        column :published_date
        column :num_views
		column :created_at
		column :updated_at
		actions
	end
	
	form(:html => { :multipart => true }) do |f|
		f.inputs do
			f.input :title
			f.input :image, :as => :file
			f.input :author_id, :label => 'Author', :as => :select, 
					:collection => Author.order('name DESC').map{|u| ["#{u.name}", u.id]}
			f.input :body, as: :froala_editor, input_html: {data: {options: {toolbarButtons: ['undo', 'redo', '|', 'bold', 'italic']}}}, :input_html => {:rows => 5, :cols => 50}
			f.input :published_date
			f.input :published
		end
		f.actions
	end

end