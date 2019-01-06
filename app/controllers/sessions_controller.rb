class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        log_in user
        params[:session][:remember_me] == '1'? remember(user): forget(user) #if one session unchecks the  box it will log out of all browsers, therefore the else: forget(user)
        redirect_back_or(user)
      else
        flash[:warning] = "Account not activated, please check your email for the activation link"
        redirect_to root_path
      end
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in? # to prevent errors from logging out of multiple tabs
    redirect_to root_path
  end
end
