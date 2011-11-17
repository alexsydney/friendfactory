class Wave::ConversationsController < ApplicationController

  before_filter :require_user

  helper_method :page_title

  layout 'conversation'

  cattr_reader :per_page
  @@per_page = 12

  def index
    @conversations = current_user.inbox(current_site).order('`waves`.`updated_at` DESC').paginate(:page => params[:page], :per_page => @@per_page)
    recipient_user_ids = @conversations.map(&:resource_id)
    @profiles = current_site.waves.type(Wave::Profile).where(:user_id => recipient_user_ids)
    @profiles = Hash[ *@profiles.map { |profile| [ profile.user_id, profile ]}.flatten ]
    respond_to do |format|
      format.html
    end
  end

  def show
    # Conversation with other user identified by :profile_id
    user = Wave::Profile.find_by_id(params[:profile_id]).try(:user)
    @wave = current_user.conversation.with(user, current_site) || current_user.create_conversation_with(user, current_site)
    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  def popup
    @popup = true
    @title = current_site.name
    @wave = current_user.conversations.site(current_site).find_by_id(params[:id])
    if @wave.present? && @wave.recipient.present?
      @title += " with #{@wave.recipient.handle(current_site)}"
    end
    respond_to do |format|
      format.html { render :action => 'show' }
    end
  end

  def close
    if @wave = current_user.inbox(current_site).find_by_id(params[:id])
      @wave.unpublish!
      @wave.read
    end
    respond_to do |format|
      format.json { render :json => { :closed => true }}
    end
  end

  private

  def page_title
    "#{current_site.display_name} - #{current_profile.handle}'s Inbox"
  end

end
