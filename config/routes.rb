ActionController::Routing::Routes.draw do |map|
  
  # Waves Controllers
  map.resources :waves, :only => [ :index, :show, :create ] do |wave|
    wave.resources :texts, :only => [ :create ]
  end
      
  map.resources :profiles,
      :only   => [ :show, :edit, :update ],
      :member => { :home => :get }
      
  map.edit_profile '/profile',
      :controller => 'profiles',
      :action     => 'edit'
  
  # # # # # # # # # # # # # # #
  
  # Postings Controllers
  map.resources :avatars,  :only => [ :create ] 
  map.resources :photos,   :only => [ :create ] 
  map.resources :postings, :only => [] do |posting|
    posting.resources :comments, :only => [ :create ]
  end
  
  map.resources :messages, :collection => { :sent => :get } do |message|
    message.reply 'reply',
        :controller => 'messages',
        :action     => 'reply',
        :conditions => { :method => :post }
  end

  # # # # # # # # # # # # # # #
  
  # User Controller
  map.with_options :controller => 'users' do |users_controller|
    users_controller.resources :users
    users_controller.resource  :account
  end

  # Friendships Controller
  map.resources :friendships, :only => [ :create, :destroy ]

  # # # # # # # # # # # # # # #
  
  # Welcome Controller
  map.with_options :controller => 'welcome' do |welcome_controller|
    welcome_controller.welcome 'welcome',
        :action     => 'index',
        :conditions => { :method => :get  }
        
    welcome_controller.login 'login',
        :action     => 'login',
        :conditions => { :method => :post }
        
    welcome_controller.register 'signup',
        :action     => 'register',
        :conditions => { :method => :post }
    
    welcome_controller.lurk 'lurk', :action => 'lurk'
  end

  # UserSession Controller
  map.resources :user_sessions
  map.logout 'logout',
      :controller => 'user_sessions',
      :action     => 'destroy',
      :conditions => { :method => :get }
  
  map.search 'search',
      :controller => 'search',
      :action     => 'index'
  
  # Root Controller
  map.root :controller => 'waves',
      :action     => 'show',
      :conditions => { :method => :get }

  # Chat Debug
  map.peek 'peek', :controller => 'welcome', :action => 'peek'  
  
  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end
