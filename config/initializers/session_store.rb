# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_tpv_session',
  :secret      => '17a4c34c96d9ba1c77d5fcf2af603c55d199514020bbfb262a8a56002cfe4fb7a5fed554377418a2ee20b46d013cf1588ec7b99b1c6d2d545a365a52534f18ca'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
