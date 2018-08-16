# frozen_string_literal: true

ActiveAdminRole.configure do |config|
  # [Required:Hash]
  # == Role | default: { guest: 0, support: 1, staff: 2, manager: 3, admin: 99 }

  config.roles = {dispensary_admin: 1, admin: 99, read_only_admin: 2 }


  # [Optional:Array]
  # == Special roles which don't need to manage on database
  config.super_user_roles = [:admin]

  # [Optional:String]
  # == User class name | default: 'AdminUser'
  config.user_class_name = "AdminUser"

  # [Optional:String]
  # == method name of #current_user in Controller
  config.current_user_method_name = "current_admin_user"

  # [Optional:Symbol]
  # == Default permission | default: :cannot
  config.default_state = :cannot
end
