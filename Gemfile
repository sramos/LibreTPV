source 'https://rubygems.org'

gem 'rails', '~> 4.2'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

#gem 'sqlite3'
gem 'mysql2', '~> 0.4'
gem 'activerecord-session_store'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier'
end

#gem 'jquery-rails'
gem 'prototype-rails', git: 'https://github.com/rails/prototype-rails', branch: '4.2'
gem 'prototype_legacy_helper', '0.0.0', :git => 'https://github.com/rails/prototype_legacy_helper.git' # Esto es para mantener soporte de form_remote_tag en Rails3

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
  # Para ocultar los logs de los assets en consola
  gem 'quiet_assets'
  # Para buscar traducciones
  gem 'gettext'#, '>=1.9.3', :require => false
  # Para debug
  gem 'byebug'
  # Para generar UML
  #gem "rails-erd"
  # Para hacer volcados de BBDD en un seeds
  gem "seed_dump"
  # gem 'web-console'
  # Test-unit deja de estar en el core, pero se carga como gema
  # gem 'test-unit'

  # Embed the V8 JavaScript interpreter into Ruby
  gem 'therubyracer'
end


# Otras gemas
gem "spreadsheet"
gem "spreadsheet_on_rails", :git => 'https://github.com/10to1/spreadsheet_on_rails.git'
gem "paperclip", "~> 6"
gem 'will_paginate', '~> 3.1'
gem 'rufus-scheduler'
gem 'hpricot'
gem 'prawn'
gem 'prawn-table'
# Gemas para hacer mas bonitos los select (funciona con prototype y jquery)
gem 'chosen-rails', git: 'https://github.com/tsechingho/chosen-rails.git'

# Gestion de usuarios
gem 'devise'
gem 'devise-i18n'

# Usamos puma para el servidor de aplicaciones
gem 'puma'
gem 'non-stupid-digest-assets'
