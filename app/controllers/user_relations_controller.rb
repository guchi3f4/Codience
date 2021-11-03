class UserRelationsController < ApplicationController
  def create
    @user = User.find(params[:user_id])
    current_user.active_relations.create(followed_id: @user.id)
    if request.referer.include?(user_path(@user))
      render 'users/user_follow'
    else
      render 'users/user_info'
    end
  end

  def destroy
    @user = User.find(params[:user_id])
    current_user.active_relations.find_by(followed_id: @user.id).destroy
    if request.referer.include?(user_path(@user))
      render 'users/user_follow'
    else
      render 'users/user_info'
    end
  end
end
