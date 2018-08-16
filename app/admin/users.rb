ActiveAdmin.register User do

	menu :if => proc{ current_admin_user.admin? || current_admin_user.read_only_admin? }

end
