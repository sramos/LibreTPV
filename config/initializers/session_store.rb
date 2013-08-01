# Be sure to restart your server when you modify this file.

#Gor::Application.config.session_store :cookie_store, key: '_gor_rails3_session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
LibreTPV::Application.config.session_store :active_record_store
#Rails.application.config.session_store :active_record_store, key: '_gor_session'

