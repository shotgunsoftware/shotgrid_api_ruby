# typed: strict

module ShotgridApiRuby
  module Types
    AuthType =
      T.type_alias do
        T.any(
          { client_id: String, client_secret: String },
          { 'client_id' => String, :client_secret => String },
          { :client_id => String, 'client_secret' => String },
          { 'client_id' => String, 'client_secret' => String },
          { username: String, password: String },
          { 'username' => String, :password => String },
          { :username => String, 'password' => String },
          { 'username' => String, 'password' => String },
          { refresh_token: String },
          { 'refresh_token' => String },
          { session_token: String },
          { 'session_token' => String },
        )
      end
  end
end
