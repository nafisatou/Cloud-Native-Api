#!/bin/bash

# Setup Keycloak with realm and client for Cloud-Native Gauntlet

echo "🔐 Setting up Keycloak realm and client..."

# Wait for Keycloak to be ready
echo "Waiting for Keycloak to be ready..."
until curl -s http://keycloak.local:8888/realms/master > /dev/null; do
    echo "Waiting for Keycloak..."
    sleep 2
done

# Get admin token
echo "Getting admin token..."
ADMIN_TOKEN=$(curl -s -X POST http://keycloak.local:8888/realms/master/protocol/openid-connect/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin" \
  -d "password=admin" \
  -d "grant_type=password" \
  -d "client_id=admin-cli" | jq -r '.access_token')

if [ "$ADMIN_TOKEN" = "null" ] || [ -z "$ADMIN_TOKEN" ]; then
    echo "❌ Failed to get admin token. Please set up admin user first."
    echo "Go to http://keycloak.local:8888/admin/ and create admin user"
    exit 1
fi

echo "✅ Got admin token"

# Create realm
echo "Creating cloud-native realm..."
curl -s -X POST http://keycloak.local:8888/admin/realms \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "realm": "cloud-native",
    "displayName": "Cloud Native Gauntlet",
    "enabled": true,
    "registrationAllowed": true,
    "loginWithEmailAllowed": true,
    "duplicateEmailsAllowed": false,
    "resetPasswordAllowed": true,
    "editUsernameAllowed": false,
    "bruteForceProtected": true
  }'

echo "✅ Created cloud-native realm"

# Create todo client
echo "Creating todo client..."
curl -s -X POST http://keycloak.local:8888/admin/realms/cloud-native/clients \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "clientId": "todo-app",
    "name": "Todo Application",
    "description": "Cloud Native Todo Application Client",
    "enabled": true,
    "clientAuthenticatorType": "client-secret",
    "redirectUris": [
      "http://api.local:8888/*",
      "http://localhost:8081/*",
      "http://127.0.0.1:8081/*"
    ],
    "webOrigins": [
      "http://api.local:8888",
      "http://localhost:8081",
      "http://127.0.0.1:8081"
    ],
    "protocol": "openid-connect",
    "publicClient": false,
    "standardFlowEnabled": true,
    "implicitFlowEnabled": false,
    "directAccessGrantsEnabled": true,
    "serviceAccountsEnabled": true,
    "authorizationServicesEnabled": true
  }'

echo "✅ Created todo-app client"

# Get client secret
echo "Getting client secret..."
CLIENT_ID=$(curl -s -X GET http://keycloak.local:8888/admin/realms/cloud-native/clients \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq -r '.[] | select(.clientId=="todo-app") | .id')

if [ "$CLIENT_ID" != "null" ] && [ -n "$CLIENT_ID" ]; then
    SECRET=$(curl -s -X GET "http://keycloak.local:8888/admin/realms/cloud-native/clients/$CLIENT_ID/client-secret" \
      -H "Authorization: Bearer $ADMIN_TOKEN" | jq -r '.value')
    
    echo "✅ Client Secret: $SECRET"
    echo "📋 Save this secret for your application configuration"
fi

# Create test user
echo "Creating test user..."
curl -s -X POST http://keycloak.local:8888/admin/realms/cloud-native/users \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@cloudnative.local",
    "firstName": "Test",
    "lastName": "User",
    "enabled": true,
    "emailVerified": true,
    "credentials": [{
      "type": "password",
      "value": "password123",
      "temporary": false
    }]
  }'

echo "✅ Created test user (testuser/password123)"

echo ""
echo "🎉 Keycloak setup complete!"
echo ""
echo "🌐 Access Keycloak at: http://keycloak.local:8888"
echo "🔑 Admin credentials: admin/admin"
echo "👤 Test user: testuser/password123"
echo "🏢 Realm: cloud-native"
echo "📱 Client ID: todo-app"
echo ""
