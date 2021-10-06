class UsersController < ApplicationController
  before_action :ensure_correct_user, only: [:edit,:update]

  def show
  end

  def index
    @users = User.all
  end

  def edit
  end

  def update
    if @user.update(params_user)
      redirect_to user_path(@user)
    else
      render :edit
    end
  end

  private

  def params_user
    params.require(:user).permit(:name, :profile_image, :introduction)
  end

  def ensure_correct_user
    @user = User.find(params[:id])
    unless @user == current_user
      redirect_to user_path(current_user)
    end
  end
end
