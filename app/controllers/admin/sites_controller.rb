require 'sass'

class Admin::SitesController < ApplicationController

  before_filter :require_admin, :except => [ :stylesheets ]

  def index
    @sites = Site.order('name asc')
    respond_to do |format|
      format.html
    end
  end

  def new
    @site = Site.new
    @site.assets.build
    respond_to do |format|
      format.html
    end
  end

  def create
    raise params.inspect
    @site = Site.new(params[:site])
    respond_to do |format|
      if @site.save
        format.html { redirect_to admin_sites_path, :notice => "#{@site.name} was successfully created" }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def edit
    @site = Site.find(params[:id])
    @site.assets.build
  end

  def update
    @site = Site.find(params[:id])
    respond_to do |format|
      if @site.update_attributes(params[:site])
        format.html { redirect_to admin_sites_path, :notice => "#{@site.name} successfully updated" }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  def stylesheets
    variables = current_site.assets.inject([]) do |memo, asset|
      memo << "$#{asset.name}:'#{asset.asset.url(:original)}';" if asset.name.present?
      memo
    end
    @engine = Sass::Engine.new((variables << current_site.css).join, :syntax => :scss)
    respond_to do |format|
      format.css { render :text => @engine.render }
    end
  end

end