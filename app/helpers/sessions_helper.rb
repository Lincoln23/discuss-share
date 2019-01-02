module SessionsHelper
  def log_in(user)
    session[:user_id] = user.id #saves it to the browser's cookie, session is a rails method included in application_controller.rb
  end

  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end
  def logged_in?
    !current_user.nil? #test to see if current user is logged in
  end
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
end
