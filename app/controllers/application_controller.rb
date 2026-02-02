class ApplicationController < ActionController::Base
  protected

  def after_sign_in_path_for(resource)
    return admin_root_path if resource.respond_to?(:admin?) && resource.admin?
    authenticated_root_path
  end
end
