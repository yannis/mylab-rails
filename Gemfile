source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.1'
# Use postgresql as the database for Active Record
gem 'pg'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem "sass-rails"
gem 'bootstrap-sass'

gem 'active_model_serializers', '0.8.3'

gem "figaro"
# gem "devise"
gem 'devise'
gem "cancancan"
gem "papertrail"
gem "kaminari"
gem "rmagick"
gem "carrierwave"
gem "redcarpet"
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'
gem "word-to-markdown"

gem 'rack-cors', require: 'rack/cors'

gem "sidekiq"
gem 'sinatra', :require => nil
gem 'slim'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem "factory_girl_rails"
  gem "rspec-rails"
  gem 'email_spec'

  gem "guard"
  gem "rb-fsevent"
  gem 'guard-rspec'
  gem 'guard-bundler'

  gem "faker"
end

group :test do
  gem 'shoulda-matchers', require: false
end
