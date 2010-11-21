require "spec_helper"

describe Waves::ProfilesController do
  describe 'routing' do
    it 'recognizes #show' do
      { :get => '/waves/profiles/42' }.should route_to(:controller => 'waves/profiles', :action => 'show', :id => '42')
    end

    it 'recognizes waves_profile_path(42)' do
      waves_profile_path(42).should == '/waves/profiles/42'
    end
    
    it 'recognizes photos' do
      { :get => '/waves/profiles/42/photos' }.should route_to(:controller => 'waves/profiles', :action => 'photos', :id => '42')
    end

    it 'recognizes photos_waves_profile_path(42)' do
      photos_waves_profile_path(42).should == '/waves/profiles/42/photos'
    end
  end

  #    it "recognizes and generates #create" do
  #      { :post => "/profiles" }.should route_to(:controller => "profiles", :action => "create")
  #    end
  #
  #    it "recognizes and generates #update" do
  #      { :put => "/profiles/1" }.should route_to(:controller => "profiles", :action => "update", :id => "1")
  #    end
  #
  #    it "recognizes and generates #destroy" do
  #      { :delete => "/profiles/1" }.should route_to(:controller => "profiles", :action => "destroy", :id => "1")
  #    end

end
