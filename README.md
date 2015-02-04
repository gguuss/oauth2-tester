# OAuth 2.0 Tester

This simple app lets you perform various OAuth 2.0 flows for testing from
the command line.

For testing, you can configure a client from https://console.developers.google.com
and then can use the values from there in client_secrets.json.

*Note* This is a work in progress and may not work at all yet.

# Usage

`oauth2-tester.rb command <code> || <access token> <refresh token>`

Accepted commads are:
* code - code exchange, requires <code>
* call - API call, requires <access token> / <refresh token>
