class UsersController < ApplicationController
  before_action :logged_in_user, only: [:show, :edit, :update, :index]
  before_action :correct_user, only: [:show, :edit, :update]
  before_action :admin_user, only: [:index, :destroy]

  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    redirect_to root_url and return if (!@user.activated?)
    @todo_posts = @user.todo_posts.paginate(page: params[:page])
  end

  def new
    @user = User.new
    @path_if_signup_fail = signup_path
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      @path_if_signup_fail = signup_path
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation, :time_zone)
  end

  # Ensure the current user is only able to make changes to its own profile.
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) if !current_user?(@user)
  end

  # Ensure only admins have access to admin privileges
  def admin_user
    redirect_to(root_url) if !(current_user && current_user.admin?)
  end
end
