# OAuth 2.0 Tester

This simple app lets you perform various OAuth 2.0 flows for testing from
the command line.

For testing, you can configure a client from https://console.developers.google.com
and then can use the values from there in client_secrets.json. There is also
a test page that you can use to get exchangeable auth codes and tokens.

Run `python -m SimpleHTTPServer 8000` and navigate to localhost:8000/testpage.html
for the utility / test page.

*Note* This is a work in progress and may not work at all yet.

# Usage

`oauth2-tester.rb command <code> || <access token> <refresh token> <id token>`

Accepted commads are:
* code - code exchange, requires `<code>`
* ioscode - code exchange from iOS
* call - API call, requires `<access token>` / `<refresh token>`
* info - Gets inforamtion about an ID / Access token
