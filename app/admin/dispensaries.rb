# frozen_string_literal: true

ActiveAdmin.register Dispensary do
  permit_params :name, :state_id, :has_hypur, :has_payqwick

  menu priority: 3

  # use with friendly id
  before_filter only: [:show, :edit, :update, :delete] do
    @dispensary = Dispensary.friendly.find(params[:id])
  end

  # save queries
  includes :state

  # filters
  filter :name
  filter :"state_id", as: :select, collection: State.all.map { |u| [u.name, u.id] }

  #-----CSV ACTIONS ----------#

  # import csv
  action_item only: :index do
    if current_admin_user.admin?
      link_to "Import Dispensaries", admin_dispensaries_import_dispensaries_path, class: "import_csv"
    end
  end

  # export csv
  csv do
    column :name
    column :state_id
    column "State" do |dispensary|
      if dispensary.state.present?
        dispensary.state.name
      end
    end
    column :has_hypur
    column :has_payqwick
  end

  collection_action :import_dispensaries do
    if request.method == "POST"
      if params[:dispensary][:file_name].present?
        Dispensary.import_from_csv(params[:dispensary][:file_name])
        flash[:notice] = "Dispensaries imported successfully."
      end
      redirect_to admin_dispensaries_path
    end
  end

  #-----CSV ACTIONS ----------#

index do
        column :name
        column "State", :sortable=>:"states.name" do |dispensary|
    			if dispensary.state.present?
    				link_to dispensary.state.name, admin_state_path(dispensary.state)
    			end
		    end
        column "Dispensary Sources" do |dispensary|
            dispensary.dispensary_sources.map{|ds| "#{link_to ds.name, admin_dispensary_source_path(ds)}".html_safe}.join('\n,').html_safe
        end
        column :has_hypur
        column :has_payqwick
        column :updated_at
        actions

  form do |f|
    f.inputs "Dispensary" do
      f.input :name
      f.input :state_id, label: "State", as: :select,
          collection: State.all.map { |u| ["#{u.name}", u.id] }
      f.input :has_hypur
      f.input :has_payqwick
    end
    f.actions
  end

end
