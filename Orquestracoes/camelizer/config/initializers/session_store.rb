# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_fooBar_session',
  :secret      => 'b891c6ced4806017d28941b675197cad3bf0e7c6f6405c9bb78822de57c54f8aab7a760e971f868d4a2d76ed073be266884f825289375491520f76ac15c4c830'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
