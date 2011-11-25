<<<<<<< HEAD
# Be sure to restart your server when you modify this file.

Dummy::Application.config.session_store :cookie_store, :key => '_dummy_session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Dummy::Application.config.session_store :active_record_store
=======
# Configure the TorqueBox Servlet-based session store.
# Provides for server-based, in-memory, cluster-compatible sessions
Dummy::Application.config.session_store :torquebox_store
>>>>>>> c0c42f90b990a880f3b144a0a00188e4c105632d
