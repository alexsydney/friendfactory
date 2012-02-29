class WelcomeController < ApplicationController

  before_filter :require_no_user
  before_filter :require_launch_site, :only => [ :launch ]
  before_filter :clear_lurker

  helper_method :featured_profiles, :user_session

  def show
    respond_to do |format|
      if current_site.launch?
        @launch_user = LaunchUser.new
        format.html { render :action => 'launch' }
      else
        @user = current_site.users.build(:invitation_code => params[:invitation_code])
        format.html
      end
    end
  end

  def signup
    @user = current_site.users.build(params[:user])
    respond_to do |format|
      if create_user_and_log_in
        flash[:notice] = "Welcome to #{current_site.display_name}, #{@user.default_personage.handle}!"
        format.html { redirect_to root_path }
      else
        format.html { render :action => 'show' }
      end
    end
  end

  def login
    respond_to do |format|
      if user_session.save
        flash[:notice] = "Welcome back, #{user_session.record.default_personage.handle}!"
        format.html { redirect_back_or_default(root_path) }
      else
        @user = User.new({ :invitation_code => params[:invitation_code] })
        format.html { render :action => 'show' }
      end
    end
  end

  def launch
    respond_to do |format|
      flash[:launch_user] = new_launch_user.save
      format.html { redirect_to welcome_path }
    end
  end

  def headshot
    render :text => params[:pane]
  end

  private

  def new_launch_user
    LaunchUser.new(params[:launch_user]).tap do |user|
      user.site = current_site.name
    end
  end

  def require_launch_site
    redirect_to welcome_path unless current_site.launch?
  end

  def featured_profiles
    @featured_profiles ||=
      Personage.enabled.site(current_site).joins(:user).merge(User.featured).includes(:profile).limit(4).order('rand()').map(&:profile)
  end

  def user_session
    @user_session ||= current_site.user_sessions.new(params[:user_session])
  end

  def create_user_and_log_in
    User.transaction do
      if @user.save && @user.accept_invitation
        current_site.user_sessions.create(params[:user])
      else
        raise ActiveRecord::Rollback
      end
    end
  end

end
