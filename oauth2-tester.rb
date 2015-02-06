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

load 'oauthutil.rb'

if (ARGV.length < 2)
  puts "Usage: oauth2-tester.rb <command> <authorization code> || <access/id token> <refresh token>\n\n"
  puts "  Commands: "
  puts "    'code' - Accepts and echanges an authorization code for tokens"
  puts "    'call' - Accepts an access token and makes an API call"
  puts "    'info' - Accepts an ID or access token and retrieves information about it"
end

command = ARGV[0]
code = ARGV[1]
token = { :access_token => ARGV[1], :refresh_token => ARGV[2] }


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
    :redirect_uri => (command == "code") ? $credentials.redirect_uris.first : "urn:ietf:wg:oauth:2.0:oob",
    :scope => "profile")
$client = Google::APIClient.new


if (command == "code" || command == "ioscode")
  codeExchange(code)
end
if (command == "call")
  apiCall(token)
end
if (command == "info")
  tokeninfo(token)
end
