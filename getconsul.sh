CONSUL_URL=$1
CONSUL_TOKEN=$2

# Fetch and process Consul data
response=$(curl -fsS -H "X-Consul-Token: $CONSUL_TOKEN" "$CONSUL_URL")
echo "CONSUL URL $CONSUL_URL"

# Check if response is valid JSON
if ! jq -e . >/dev/null 2>&1 <<<"$response"; then
  echo "ERROR: Invalid JSON response from Consul" >&2
  exit 1
fi

# Extract and decode the Value field
value=$(jq -r '.[0].Value' <<<"$response" | base64 -d)

# Convert JSON to .env format with proper value handling
jq -r 'to_entries[] | 
       "\(.key)=\(.value | 
       if type == "boolean" then (. | if . then "true" else "false" end) 
       else . end)"' <<<"$value"
