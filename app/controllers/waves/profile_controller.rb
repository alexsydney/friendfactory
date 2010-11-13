class Waves::ProfileController < Waves::BaseController

  before_filter :require_user

  helper :waves

  def show
    @wave = current_user.profile
    respond_to do |format|
      format.html
    end
  end

  def edit
    @wave = current_user.profile
    respond_to do |format|
      format.html
    end
  end
  
  def update
    @successful = current_user.info.update_attributes(params[:user_info])
    respond_to do |format|
      format.html { redirect_to profile_path }
    end
  end
  
  def avatar
    avatar = Posting::Avatar.create(params[:posting_avatar])
    current_user.profile.avatar = avatar
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

end
