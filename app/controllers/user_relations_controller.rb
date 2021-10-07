class UserRelationsController < ApplicationController
  def create
    @user = User.find(params[:user_id])
    current_user.active_relations.create(followed_id: @user.id)
    render 'users/user_follow'
  end

  def destroy
    @user = User.find(params[:user_id])
    current_user.active_relations.find_by(followed_id: @user.id).destroy
    render 'users/user_follow'
  end
end
