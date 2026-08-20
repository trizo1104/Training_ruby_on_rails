source "https://rubygems.org"

ruby ">= 3.3.0"

# ============================================================
# Rails core
# ============================================================

gem "rails", "~> 8.1.3"

# Modern Rails asset pipeline
gem "propshaft"

# PostgreSQL database adapter
gem "pg", "~> 1.1"

# Application web server
gem "puma", ">= 5.0"

# ============================================================
# Frontend: ERB + Hotwire + Tailwind CSS
# ============================================================

# JavaScript management without Node.js bundling
gem "importmap-rails"

# Hotwire: navigation and partial-page updates
gem "turbo-rails"

# Hotwire: lightweight JavaScript controllers
gem "stimulus-rails"

# Tailwind CSS integration for Rails
gem "tailwindcss-rails"

# ============================================================
# Authentication
# ============================================================

# Sign up, sign in, sign out, password management
gem "devise"

# ============================================================
# Pagination
# ============================================================

# Pagination for assignments list
gem "pagy"

# ============================================================
# File and image uploads
# ============================================================

# Image resizing and Active Storage variants
gem "image_processing", "~> 1.2"

# ============================================================
# Optional JSON responses
# ============================================================

# Keep this if the application may return JSON.
# It is not required for normal ERB pages.
gem "jbuilder"

# ============================================================
# Rails database-backed services
# ============================================================

# Database-backed Rails.cache
gem "solid_cache"

# Database-backed Active Job
gem "solid_queue"

# Database-backed Action Cable
gem "solid_cable"

# ============================================================
# Performance and deployment
# ============================================================

# Reduces application boot time
gem "bootsnap", require: false

# Docker deployment with Kamal
gem "kamal", require: false

# HTTP caching, compression and Puma acceleration
gem "thruster", require: false

# Windows does not include timezone database files
gem "tzinfo-data", platforms: %i[windows jruby]

# ============================================================
# Development and test
# ============================================================


gem "haml"
gem "haml-rails"

gem "caxlsx"
gem "caxlsx_rails"

gem "wicked_pdf"
gem "wkhtmltopdf-binary"

group :development, :test do
  # Ruby debugger
  gem "debug",
      platforms: %i[mri windows],
      require: "debug/prelude"

  gem "letter_opener_web"

  # Generate sample data in db/seeds.rb
  gem "faker"

  gem "dotenv-rails"

  # Check gems for known security vulnerabilities
  gem "bundler-audit", require: false

  # Scan Rails code for security vulnerabilities
  gem "brakeman", require: false

  # Standard Rails code style
  gem "rubocop-rails-omakase", require: false
end

group :development do
  # Interactive console on Rails exception pages
  gem "web-console"
end

group :test do
  # Browser-based system tests
  gem "capybara"

  # Control browser during system tests
  gem "selenium-webdriver"
end

gem "pundit", "~> 2.5"
