class Waves::MessagesController < ApplicationController

  before_filter :require_user

  def create
    # @wave = current_user.messages << Wave::Message.create(params[:posting_message])
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

end




    # wave = Wave::Base.find_by_id(params[:wave_id])
    # if wave.present?
    #   @posting = Posting::Text.new(:subject => params[:posting_text][:subject], :body => params[:posting_text][:body], :user_id => current_user.id)      
    #   wave.postings << @posting
    # end    
    # respond_to do |format|
    #   format.js { render :layout => false }
    # end

