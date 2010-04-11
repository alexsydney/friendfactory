require 'exceptions'

class ApplicationController < ActionController::Base  
  
  include ActionController::Sites
  
  helper :application, :placeholder_text

  helper_method :current_user_session, :current_user
  helper_method :current_site
  helper_method :presenter

  filter_parameter_logging(:password, :password_confirmation) if Rails.env.production?
  
  protect_from_forgery

  rescue_from UnauthorizedException do |exception|
    render :file => "#{Rails.root}/public/401.html", :status => 401
  end
  
  protected
  
  def helpers
    self.class.helpers
  end
  
  private

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end
  
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end
  
  def require_user
    unless current_user
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to welcome_url
      return false
    end
  end

  def require_lurker
    unless current_user || session[:lurker]
      store_location
      redirect_to welcome_url
      return false
    end
  end
  
  def require_no_user
    if current_user
      store_location
      flash[:notice] = "You must be logged out to access this page"
      redirect_to root_url
      return false
    end
  end
  
  def store_location
    session[:return_to] = request.request_uri
  end
  
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
      
  def presenter
    @presenter ||= ApplicationPresenter.new(params)
  end
  
end
