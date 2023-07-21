source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 4.1'
gem 'rails', '~> 6.0.6', '>= 6.0.6.1'
gem 'jbuilder', '~> 2.7'
gem 'sass-rails', '>= 6'
gem 'colorize'
gem 'concurrent-ruby'
gem 'google-protobuf', '~> 3.23', '>= 3.23.3'
gem 'daemons'

gem 'bootsnap', '>= 1.4.2', require: false

gem "sidekiq", "~> 6.5"
gem 'delayed_job_active_record'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'rspec-rails', '~> 5.0'
  gem 'awesome_print'
end

group :development do
  gem 'listen', '~> 3.2'
  gem 'web-console', '>= 3.3.0'
end
