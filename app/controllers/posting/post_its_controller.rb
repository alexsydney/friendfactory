class Posting::PostItsController < ApplicationController
  
  before_filter :require_user
   
  def new
    @wave = Wave::Base.find_by_id(params[:wave_id])
  end
  
  def create
    wave = Wave::Base.find_by_id(params[:wave_id])
    if wave.present?
      @posting = Posting::PostIt.new(params[:posting_post_it])
      @posting.user = current_user
      if @posting.save
        wave.postings << @posting
        @posting.publish!
      end
    end    
    respond_to do |format|
      format.js { render :layout => false }
    end
  end
    
end
