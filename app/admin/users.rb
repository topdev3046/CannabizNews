# frozen_string_literal: true

ActiveAdmin.register User do

  menu if: proc { current_admin_user.admin? }

end
