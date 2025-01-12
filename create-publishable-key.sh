#!/bin/sh

# Exit immediately if any command fails
set -e

echo "$(date '+%Y-%m-%d %H:%M:%S') Starting API key creation process..."

# Initialize variables
EMAIL=""
PASSWORD=""
BACKEND_URL=""

# Parse the input arguments
while [ $# -gt 0 ]; do
  case "$1" in
    -e|--email)
      EMAIL="$2"
      shift 2
      ;;
    -p|--password)
      PASSWORD="$2"
      shift 2
      ;;
    -u|--backend-url)
      BACKEND_URL="$2"
      shift 2
      ;;
    *)
      echo "$(date '+%Y-%m-%d %H:%M:%S') Error: Invalid argument $1"
      exit 1
      ;;
  esac
done

# Check if the required arguments are provided
if [ -z "$EMAIL" ] || [ -z "$PASSWORD" ] || [ -z "$BACKEND_URL" ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') Error: Email, password, and backend URL are required."
  echo "Usage: $0 -e <email> -p <password> -b <backend-url>"
  exit 1
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') Authenticating user..."

# Obtain the JWT token and save it into a variable
TOKEN=$(curl -s -X POST "$BACKEND_URL/auth/user/emailpass" \
-H 'Content-Type: application/json' \
--data-raw "{
  \"email\": \"$EMAIL\",
  \"password\": \"$PASSWORD\"
}" | jq -r '.token')

# Check if token is valid
if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') Error: Failed to obtain authentication token"
  exit 1
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') Successfully authenticated"
echo "$(date '+%Y-%m-%d %H:%M:%S') Checking for existing API keys..."

# Get all API keys
API_KEYS_RESPONSE=$(curl -s -X GET "$BACKEND_URL/admin/api-keys" \
-H "Authorization: Bearer $TOKEN")

# Check for existing publishable API key
EXISTING_API_KEY=$(echo "$API_KEYS_RESPONSE" | jq -r '.api_keys[] | select(.title=="Storefront Key" and .type=="publishable") | .id' | head -n1)

if [ -n "$EXISTING_API_KEY" ] && [ "$EXISTING_API_KEY" != "null" ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') Found existing Storefront API key (ID: $EXISTING_API_KEY)"
  API_KEY_ID=$EXISTING_API_KEY
  
  # Get the token for this specific API key
  API_KEY_TOKEN=$(echo "$API_KEYS_RESPONSE" | jq -r --arg ID "$API_KEY_ID" '.api_keys[] | select(.id==$ID) | .token')
  
  if [ -z "$API_KEY_TOKEN" ] || [ "$API_KEY_TOKEN" = "null" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') Creating new API key since token retrieval failed"
    CREATE_NEW=true
  fi
else
  echo "$(date '+%Y-%m-%d %H:%M:%S') No existing Storefront API key found"
  CREATE_NEW=true
fi

if [ "$CREATE_NEW" = "true" ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') Creating new Storefront API key..."
  # Create a publishable API key and retrieve the api_key id from the response
  CREATE_RESPONSE=$(curl -s -X POST "$BACKEND_URL/admin/api-keys" \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  --data-raw '{
    "title": "Storefront Key",
    "type": "publishable"
  }')
  
  API_KEY_ID=$(echo "$CREATE_RESPONSE" | jq -r '.api_key.id')
  API_KEY_TOKEN=$(echo "$CREATE_RESPONSE" | jq -r '.api_key.token')
  
  if [ -z "$API_KEY_ID" ] || [ "$API_KEY_ID" = "null" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') Error: Failed to create API key"
    echo "Response: $CREATE_RESPONSE"
    exit 1
  fi
  echo "$(date '+%Y-%m-%d %H:%M:%S') Successfully created new API key (ID: $API_KEY_ID)"
fi

if [ -z "$API_KEY_TOKEN" ] || [ "$API_KEY_TOKEN" = "null" ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') Error: Failed to retrieve API key token"
  exit 1
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') Successfully retrieved API key token"

echo "$(date '+%Y-%m-%d %H:%M:%S') Checking for sales channels..."

# Check for existing sales channels
SALES_CHANNEL_ID=$(curl -s -X GET "$BACKEND_URL/admin/sales-channels" \
-H "Authorization: Bearer $TOKEN" | jq -r '.sales_channels[0].id')

if [ -z "$SALES_CHANNEL_ID" ] || [ "$SALES_CHANNEL_ID" = "null" ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') Error: No sales channel found. Please ensure at least one sales channel exists."
  exit 1
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') Found default sales channel (ID: $SALES_CHANNEL_ID)"
echo "$(date '+%Y-%m-%d %H:%M:%S') Checking API key association with sales channel..."

# Check if API key is already associated with the sales channel
CHANNEL_CHECK=$(curl -s -X GET "$BACKEND_URL/admin/api-keys/$API_KEY_ID" \
-H "Authorization: Bearer $TOKEN" | jq -r '.api_key.sales_channels[] | select(.id=="'"$SALES_CHANNEL_ID"'") | .id')

if [ -z "$CHANNEL_CHECK" ] || [ "$CHANNEL_CHECK" = "null" ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') Adding API key to sales channel..."
  # Add the key to the default Sale channel
  STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BACKEND_URL/admin/api-keys/$API_KEY_ID/sales-channels" \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  --data-raw "{
    \"add\": [\"$SALES_CHANNEL_ID\"]
  }")

  if [ "$STATUS_CODE" -ne 200 ] && [ "$STATUS_CODE" -ne 201 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') Error: Failed to add the key to the sales channel. HTTP status code: $STATUS_CODE"
    exit 1
  fi
  echo "$(date '+%Y-%m-%d %H:%M:%S') Successfully added API key to sales channel"
else
  echo "$(date '+%Y-%m-%d %H:%M:%S') API key already associated with sales channel"
fi

# Return the publishable key
echo "$API_KEY_TOKEN"
