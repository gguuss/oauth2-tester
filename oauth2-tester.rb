#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Author: class@google.com (Gus Class)

require 'base64'
require 'rubygems'
require 'json'
require 'google/api_client'
require 'google/api_client/client_secrets'
require 'net/https'
require 'uri'
use Rack::Session::Pool, :expire_after => 86400 # 1 day

if (ARGV.length < 2)
  puts "Usage: oauth2-tester.rb <authorization code> <access token> <refresh token>\n\n";
end

command = ARGV[0]
code = ARGV[1]
token = { :access_token => ARGV[1], :refresh_token => ARGV[2] }

if (command == "code")
  codeExchange
end

if (command == "call")
  apiCall
end


# Configuration
# See the README.md for getting the OAuth 2.0 client ID and
# client secret.

# Configuration that you probably don't have to change
APPLICATION_NAME = 'OAuth 2.0 tester'

# Build the global client
$credentials = Google::APIClient::ClientSecrets.load
$authorization = Signet::OAuth2::Client.new(
    :authorization_uri => $credentials.authorization_uri,
    :token_credential_uri => $credentials.token_credential_uri,
    :client_id => $credentials.client_id,
    :client_secret => $credentials.client_secret,
    :redirect_uri => $credentials.redirect_uris.first,
    :scope => PLUS_LOGIN_SCOPE)
$client = Google::APIClient.new


##
# Perform OAuth 2.0 code exchange for refresh token.
def codeExchange
  # Upgrade the code into a token object.
  $authorization.code = code
  $authorization.fetch_access_token!
  $client.authorization = $authorization

  # TODO: move into verify_token function
  id_token = $client.authorization.id_token
  encoded_json_body = id_token.split('.')[1]

  # Base64 must be a multiple of 4 characters long, trailing with '='
  encoded_json_body += (['='] * (encoded_json_body.length % 4)).join('')
  json_body = Base64.decode64(encoded_json_body)
  body = JSON.parse(json_body)

  # You can read the Google user ID in the ID token.
  # "sub" represents the ID token subscriber which in our case
  # is the user ID. This sample does not use the user ID.
  gplus_id = body['sub']
  puts "User ID: ${gplus_id}"

  # Serialize and store the token in the user's session.
  token_pair = TokenPair.new
  token_pair.update_token!($client.authorization)

  puts token_pair
end


##
# An Example API call, list the people the user shared with this app.
def apiCall
  # Authorize the client and construct a Google+ service.
  $client.authorization.update_token!(token)
  plus = $client.discovered_api('plus', 'v1')

  # Get the list of people as JSON and return it.
  response = $client.execute!(plus.people.get, :userId => 'me').body
  puts response
end


##
# Disconnect the user by revoking the stored token and removing session objects.
def disconnect
  # You could reset the state at this point, but as-is it will still stay unique
  # to this user and we're avoiding resetting the client state.
  # session.delete(:state)
  session.delete(:token)

  # Send the revocation request and return the result.
  revokePath = 'https://accounts.google.com/o/oauth2/revoke?token=' + token
  uri = URI.parse(revokePath)
  request = Net::HTTP.new(uri.host, uri.port)
  request.use_ssl = true
  status request.get(uri.request_uri).code
end



##
# Serializes and deserializes the token.
class TokenPair
  @refresh_token
  @access_token
  @expires_in
  @issued_at

  def update_token!(object)
    @refresh_token = object.refresh_token
    @access_token = object.access_token
    @expires_in = object.expires_in
    @issued_at = object.issued_at
  end

  def to_hash
    return {
      :refresh_token => @refresh_token,
      :access_token => @access_token,
      :expires_in => @expires_in,
      :issued_at => Time.at(@issued_at)}
  end
end