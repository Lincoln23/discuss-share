module SessionsHelper
  def log_in(user)
    session[:user_id] = user.id
    # saves it to the browser's cookie,
    # session is a rails method included in application_controller.rb
  end

  def current_user
    if (user_id = session[:user_id])
      return @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        return @current_user = user
      end
    end
  end

  def current_user?(user)
    user == current_user
  end

  def logged_in?
    !current_user.nil?
  end

  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end


  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    # permanent -> lasts 20 years, singed -> encrypted and singed
    cookies.permanent[:remember_token] = user.remember_token
    # the cookies saved on the browser will be encrypted
  end

  # Redirects to stored location (or to the default).
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # Stores the URL trying to be accessed.
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
