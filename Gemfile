source 'https://rubygems.org'

gem 'rails', '3.2.9'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

#gem 'sqlite3'
gem 'mysql2'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

#gem 'jquery-rails'
gem "prototype-rails", "~> 3.2.1"
gem 'prototype_legacy_helper', '0.0.0', :git => 'git://github.com/rails/prototype_legacy_helper.git' # Esto es para mantener soporte de form_remote_tag en Rails3

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'

# Traducciones
#gem "locale"
#gem "locale_rails"
#gem "gettext"
#gem "gettext_activerecord" #, :version => '2.1.0'
#gem "gettext_rails"
#gem 'gettext_i18n_rails'
#gem 'rails-i18n'

# Solo para el entorno de desarrollo
group :development do
  # Para buscar traducciones
  gem 'gettext', '>=1.9.3', :require => false
  # Para debug
  gem 'ruby-debug19',:platform => :ruby_19
  # Para generar UML
  #gem "rails-erd"
  # Para hacer volcados de BBDD en un seeds
  #gem "seed_dump", "~> 0.4.2"
end


# Otras gemas
#gem "autocomplete" # Da un error al arrancar
#gem "autocomplete", :git => 'git://github.com/voislavj/autocomplete.git'
#gem "auto_complete", :git => 'git://github.com/david-kerins/auto_complete.git'
#gem "respond_to_parent", :git => 'git://github.com/itkin/respond_to_parent.git' # Da error cargando como gema. Cargado como plugin. 
gem "spreadsheet"
gem "spreadsheet_on_rails", :git => 'git://github.com/10to1/spreadsheet_on_rails.git'
#gem "paperclip", "~> 3.0"
gem 'will_paginate', '~> 3.0.0'
gem 'calendar_date_select', :git => 'git://github.com/paneq/calendar_date_select.git'
gem 'rufus-scheduler'
gem 'hpricot'
# Problemas con utf8 us-ascii
#gem 'pdf-writer'
#gem 'dav4rack'

