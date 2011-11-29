class WelcomeController < ApplicationController

  before_filter :require_no_user
  before_filter :require_launch_site, :only => [ :launch ]
  before_filter :clear_lurker

  def show
    respond_to do |format|
      if current_site.launch?
        @launch_user = LaunchUser.new
        format.html { render :action => 'launch' }
      else
        @user = User.new({ :invitation_code => params[:invitation_code] })
        format.html
      end
    end
  end

  def signup
    account = Account.find_or_create_by_email(params[:user][:email])
    @user = account.users.build(params[:user]) { |user| user.site = current_site }
    user_session = current_site.user_sessions.new(params[:user])
    respond_to do |format|
      if account.save && user_session.save
        flash[:notice] = "Welcome to #{current_site.display_name}, #{@user.handle}!"
        format.html { redirect_to root_path }
      else
        format.html { render :action => 'show' }
      end
    end
  end

  def login
    user_session = current_site.user_sessions.new(params[:user_session])
    respond_to do |format|
      if user_session.save
        flash[:notice] = "Welcome back, #{user_session.record.handle(current_site)}!"
        format.html { redirect_back_or_default(root_path) }
      else
        @user = User.new({ :invitation_code => params[:invitation_code] })
        flash.now[:login] = user_session.errors.full_messages
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

end
