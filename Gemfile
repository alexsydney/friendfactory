source 'http://rubygems.org'

gem 'rails', '3.0.9'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mysql2'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

gem 'jquery-rails', '>= 1.0.12'
gem 'transitions', '>= 0.0.10', :require => [ 'transitions', 'active_record/transitions' ]
gem 'authlogic', '~> 3.1.0'
gem 'paperclip', '>= 2.4'
gem 'remotipart'
gem 'haml', '>= 3.1.2'
gem 'haml-rails'
gem 'sass', '>= 3.1.1'
gem 'acts-as-taggable-on', '~> 2.2.2'
gem 'pusher', '~> 0.8.1'
gem 'will_paginate', '~> 3.0.2'
gem 'whenever', '~> 0.7.3', :require => false
gem 'embedly', '~> 1.5.2'
gem 'user_agent'
gem 'delayed_job_active_record'
gem 'daemons'
gem 'bluecloth', '~> 2.0.10'

# gem 'responsalizr'
# gem 'exifr'
# gem 'sanitize'
# gem 'thinking-sphinx', '>= 1.3.16', :require => 'thinking_sphinx'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:

gem 'letter_opener', :group => :development

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl', :git => 'git://github.com/thoughtbot/factory_girl.git'
  gem 'webrat', '>= 0.7.2'
  gem 'sql-logging'
end

group :production do
  gem 'memcache-client'
end
