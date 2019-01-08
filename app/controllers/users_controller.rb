class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_only, only: :destroy

  def index
    @users = User.paginate(page: params[:page])
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  def new
    @user = User.new #for the form_for in the view
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
    #pulls the users out of the database one chunk at a time (30 by default), based on the :page parameter
  end

  def create
    @user = User.new(user_params)
    if @user.save #checks if is user.valid?
       @user.send_activation_email
       log_in @user
       flash[:notice] = "In production an email would be sent using smtp"
       flash[:info] = edit_account_activation_url(@user.activation_token,
                                                  email: @user.email)
      #  flash[:info] = "Please check your email to activate your account"
      redirect_to root_path
    else
      render "new"
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile Updated!"
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

  def user_params #strong paramters
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
  # to prevent attackers to change/delete users by sending PATCH / DELETE requests
  #
  def correct_user
    @user = User.find(params[:id])
    redirect_to root_path unless current_user?(@user)
  end

  def admin_only
    redirect_to root_path unless current_user.admin?
  end

end
