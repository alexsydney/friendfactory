class Wave::ConversationsController < ApplicationController

  before_filter :require_user

  def index
    inbox = current_user.inbox
    unless inbox.present?
      inbox = current_user.create_inbox
      inbox.waves = current_user.conversations      
    end
    @waves = inbox.waves
    respond_to do |format|
      format.html
    end
  end

  def show
    # current_user's conversation with another identified by other user's profile_id.
    user = Wave::Profile.find_by_id(params[:profile_id]).try(:user)
    @wave = current_user.conversation.with(user) || current_user.create_conversation_with(user)
    respond_to do |format|
      format.html { render :layout => false }
    end
  end
  
  def close
    inbox = current_user.inbox
    if inbox.present?
      @wave = inbox.waves.find_by_id(params[:id])
      inbox.waves.delete(@wave) if @wave.present?
    end
    respond_to do |format|
      format.js { render :layout => false }
    end
  end
  
end
