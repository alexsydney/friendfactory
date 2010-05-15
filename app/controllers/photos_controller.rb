class PhotosController < ApplicationController

  before_filter :require_user
  
  def create
    wave = Wave::Base.find_by_id(params[:wave_id])
    @posting = Posting::Photo.create(params[:posting_photo].merge(:wave_id => wave, :user_id => current_user)) if wave.present?
    respond_to_parent do
      respond_to do |format|
        format.js
      end
    end    
  end
    
end
