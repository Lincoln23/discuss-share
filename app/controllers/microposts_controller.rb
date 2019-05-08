class MicropostsController < ApplicationController
  require 'json'
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user, only: :destroy


  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "Micropost created"
      redirect_to root_path
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end


  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted"
    redirect_back fallback_location: root_path
  end

  def search
    unless params[:search_posts].nil?
      @posts = Autocompleter.call(search_params[:query].to_s)
    end
  end

  private

  def search_params
    params.require(:search_posts).permit(:query)
  end

  def correct_user
    @micropost = current_user.microposts.find_by(id: params[:id])
    redirect_to root_path if @micropost.nil?
  end

  def micropost_params
    params.require(:micropost).permit(:content, :picture)
  end
end
