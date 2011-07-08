class Posting::LinksController < ApplicationController

  before_filter :require_user

  @@embedly_api = Embedly::API.new :key => EmbedlyKey

  def create
    @posting = nil
    if wave = current_site.waves.find_by_id(params[:wave_id])
      @posting = Posting::Link.new(params[:posting_link]) do |link|
        link.user = current_user
        link.state = :published
      end
      @posting.embedify
      if @posting.valid?
        wave.postings << @posting
        current_user.profile(current_site).postings << @posting
      end
    end
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

end
