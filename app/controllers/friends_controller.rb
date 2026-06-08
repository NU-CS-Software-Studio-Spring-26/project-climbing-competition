class FriendsController < ApplicationController
  before_action :require_authentication

  def index
    @activities = FriendActivityFeed.for(current_user)
    @following_count = current_user.following.count
  end
end
