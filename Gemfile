source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem "rails", "~> 5.1.4"
gem "pg", "~> 0.18"
gem "puma", "~> 3.7"
gem "sass-rails", "~> 5.0"
gem "uglifier", ">= 1.3.0"
gem "turbolinks", "~> 5"
gem "jbuilder", "~> 2.5"
gem "redis", "~> 3.0"
gem "sidekiq"

group :development, :test do
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "capybara", "~> 2.13"
  gem "selenium-webdriver"
  gem "rspec-rails", "~> 3.6"
  gem "factory_bot_rails"
  gem "faker"
  gem "pry-rails"
  gem "railroady"
end

group :test do
  gem "shoulda-matchers"
end

group :development do
  gem "web-console", ">= 3.3.0"
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end

gem "tzinfo-data"

gem "devise"
gem "config"
gem "stringex"
gem "ransack", github: "activerecord-hackery/ransack"
gem "jquery-rails"
gem "draper"
gem "virtus"
gem "pundit"
gem "paranoia", "~> 2.2"
gem "counter_culture", "~> 1.8"
gem "kaminari"
gem "geocoder"
gem "wicked"
gem "carrierwave"
gem "mini_magick"
gem "file_validators"
gem "omniauth"
gem "omniauth-facebook"
gem "omniauth-google-oauth2"
