class FollowsController < ApplicationController
  before_action :require_authentication
  before_action :set_user

  def create
    if current_user == @user
      redirect_to @user, alert: "You cannot follow yourself."
      return
    end

    follow = current_user.active_follows.build(followed: @user)

    if follow.save
      redirect_to @user, notice: "You are now following #{@user.username}."
    else
      redirect_to @user, alert: follow.errors.full_messages.to_sentence.presence || "Could not follow this user."
    end
  end

  def destroy
    follow = current_user.active_follows.find_by(followed: @user)

    if follow&.destroy
      redirect_to @user, notice: "You unfollowed #{@user.username}."
    else
      redirect_to @user, alert: "You are not following this user."
    end
  end

  private

  def set_user
    @user = User.find(params.expect(:user_id))
  end
end
