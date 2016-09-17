class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :check_avatar
  def check_avatar(user)
       if user.avatar_file_name.nil?
         # return default image
         "#{ENV['QINIU_HOST']}/images/avatar.png"
      else
         #return user avatar
         user.avatar.url
      end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
    devise_parameter_sanitizer.permit(:sign_up, keys: [:gender])
    devise_parameter_sanitizer.permit(:account_update, keys: [:gender])
    devise_parameter_sanitizer.permit(:sign_up, keys: [:birthday])
    devise_parameter_sanitizer.permit(:account_update, keys: [:birthday])
    devise_parameter_sanitizer.permit(:sign_up, keys: [:tag_list])
    devise_parameter_sanitizer.permit(:account_update, keys: [:tag_list])
    devise_parameter_sanitizer.permit(:sign_up, keys: [:avatar])
    devise_parameter_sanitizer.permit(:account_update, keys: [:avatar])
   end
end
