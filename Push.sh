#!/bin/sh

##  Copyright 2022 Michael Deller
##
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##
##      http://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.
##
##  https://developer.apple.com/documentation/usernotifications/sending_push_notifications_using_command-line_tools

TEAM_ID=XXX			# From developer.apple.com
TOKEN_KEY_FILE_NAME=YYY		# From developer.apple.com
AUTH_KEY_ID=ZZZ			# From developer.apple.com
BUNDLE_ID=AAA.AAA.AAA		# Bundle Identifier from Xcode
DEVICE_TOKEN=BBB		# Device Token from running on your device
APNS_HOST_NAME=api.sandbox.push.apple.com

JWT_ISSUE_TIME=$(date +%s)
JWT_HEADER=$(printf '{ "alg": "ES256", "kid": "%s" }' "${AUTH_KEY_ID}" | openssl base64 -e -A | tr -- '+/' '-_' | tr -d =)
JWT_CLAIMS=$(printf '{ "iss": "%s", "iat": %d }' "${TEAM_ID}" "${JWT_ISSUE_TIME}" | openssl base64 -e -A | tr -- '+/' '-_' | tr -d =)
JWT_HEADER_CLAIMS="${JWT_HEADER}.${JWT_CLAIMS}"
JWT_SIGNED_HEADER_CLAIMS=$(printf "${JWT_HEADER_CLAIMS}" | openssl dgst -binary -sha256 -sign "${TOKEN_KEY_FILE_NAME}" | openssl base64 -e -A | tr -- '+/' '-_' | tr -d =)
AUTHENTICATION_TOKEN="${JWT_HEADER}.${JWT_CLAIMS}.${JWT_SIGNED_HEADER_CLAIMS}"

curl -v --header "apns-topic: $BUNDLE_ID" \
	--header "apns-push-type: alert" \
	--header "authorization: bearer $AUTHENTICATION_TOKEN" \
	--data '{"aps":{"alert":"test"}}' \
	--http2 https://${APNS_HOST_NAME}/3/device/${DEVICE_TOKEN}
