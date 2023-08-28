extends Node
## Controls Twitch API requests
## 
## Under GNU General Public License v3
## Copyright (C) 2023 - Rafael Alcalde Azpiazu (NEKERAFA)


signal access_token_completed(success: bool)
signal get_user_completed(exists: bool)


const GET_OAUTH_TOKEN = "https://id.twitch.tv/oauth2/token"
const GET_USERS = "https://api.twitch.tv/helix/users"


var access_token_request = false
var access_token = null


## Get Twitch access token
func _ready():
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._on_get_access_token_completed)

	var uri = GET_OAUTH_TOKEN + "?client_id=%s&client_secret=%s&grant_type=client_credentials" % [Globals.TWITCH_CLIENT_ID, Secrets.TWITCH_CLIENT_SECRET]
	if http_request.request(uri, ["Content-Type: application/x-www-form-urlencoded"], HTTPClient.METHOD_POST) != OK:
		push_error("cannot connect to %s" % GET_OAUTH_TOKEN)


func _on_get_access_token_completed(result, _response_code, _headers, body):
	access_token_request = true

	if result != HTTPRequest.RESULT_SUCCESS:
		push_warning("Cannot get access token")
		access_token_completed.emit(false)
	else:
		var json = JSON.new()
		if json.parse(body.get_string_from_utf8()) != OK:
			push_warning("Cannot parse response: line {0}: {1}" % [json.get_error_line(), json.get_error_message()])
			access_token_completed.emit(false)
		else:
			print_debug(body.get_string_from_utf8())
			var response = json.get_data()
			access_token = response.get("access_token", null)
			access_token_completed.emit(true)


## Check if channel exists async
func try_channel_exist(channel):
	if access_token == null and not access_token_request:
		await access_token_completed
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._on_get_user_completed)

	var uri = GET_USERS + "?login=%s" % channel
	if http_request.request(uri, ["Client-Id: %s" % Globals.TWITCH_CLIENT_ID, "Authorization: Bearer %s" % str(access_token)]) != OK:
		push_error("cannot connect to %s" % uri)


## Check if channel exists
func is_channel_exists(channel) -> bool:
	try_channel_exist(channel)
	return await get_user_completed


func _on_get_user_completed(result, _response_code, _headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_warning("Cannot get user")
		get_user_completed.emit(false)
	else:
		var json = JSON.new()
		if json.parse(body.get_string_from_utf8()) != OK:
			push_warning("Cannot parse response: line {0}: {1}" % [json.get_error_line(), json.get_error_message()])
			get_user_completed.emit(false)
		else:
			print_debug(body.get_string_from_utf8())
			var response = json.get_data().get("data", [])
			get_user_completed.emit(not response.is_empty())
