# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_tpv_session',
  :secret      => '0091e9ad4ba63b1f7208b95ff7c8bccbd8cbd3a05a2497d7dd05a68e9e5ce180ebf6adcb11347a9781a9cd7b887fe234c5e7b6c1661abc59c6129e3c9b19047c'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
