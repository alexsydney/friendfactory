class Posting::CommentsController < ApplicationController
  
  before_filter :require_user

  def index
    @comments = []
    if @posting = Posting::Base.find_by_id(params[:posting_id])
      @comments = @posting.children.type(Posting::Comment).published.order('updated_at desc')
    end
    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  def new
    @posting = Posting::Base.find_by_id(params[:posting_id])
    respond_to do |format|
      format.html { render :layout => false }
    end
  end
  
  def create
    @comment = nil
    if posting = Posting::Base.find_by_id(params[:posting_id])
      @comment = new_posting_comment
      posting.children << @comment
      @comment.publish!
    end
    respond_to do |format|
      format.js { render :layout => false }
    end
  end
  
  private
  
  def new_posting_comment
    Posting::Comment.new(:body => params[:posting_comment][:body]) do |posting|
      posting.user = current_user
    end    
  end
  
end
