#!/bin/sh
set -e

if [ -z "$TF_SACLOUD_PROVIDER_VERSION" ]; then
	TF_SACLOUD_PROVIDER_VERSION=$(curl -s https://api.github.com/repos/sacloud/terraform-provider-sakuracloud/releases | jq -r '.[0] | .tag_name' | sed -e 's/[^0-9\.]//g')
fi

FILE="terraform-provider-sakuracloud"
if [ ! -f "$FILE" ]; then
	echo "$TF_SACLOUD_PROVIDER_VERSION download..."
	wget https://github.com/sacloud/terraform-provider-sakuracloud/releases/download/v${TF_SACLOUD_PROVIDER_VERSION}/terraform-provider-sakuracloud_${TF_SACLOUD_PROVIDER_VERSION}_linux-amd64.zip
	unzip terraform-provider-sakuracloud_${TF_SACLOUD_PROVIDER_VERSION}_linux-amd64.zip
	rm terraform-provider-sakuracloud_${TF_SACLOUD_PROVIDER_VERSION}_linux-amd64.zip
	mv terraform-provider-sakuracloud* terraform-provider-sakuracloud
fi

cd "${TF_ACTION_WORKING_DIR:-.}"

if [[ ! -z "$TF_ACTION_TFE_TOKEN" ]]; then
  cd ~
  pwd
  cat > ~/.terraformrc << EOF
credentials "${TF_ACTION_TFE_HOSTNAME:-app.terraform.io}" {
  token = "$TF_ACTION_TFE_TOKEN"
}
EOF
fi

set +e
PLUGINS_DIR="$HOME/.terraform.d/plugins/linux_amd64"
mkdir -p $PLUGINS_DIR
cp -f /terraform-provider-sakuracloud $PLUGINS_DIR
set -e

set +e
export TF_APPEND_USER_AGENT="terraform-github-actions/1.0"
OUTPUT=$(sh -c "terraform init -no-color -input=false $*" 2>&1)
SUCCESS=$?
echo "$OUTPUT"
set -e

if [ $SUCCESS -eq 0 ]; then
    exit 0
fi

if [ "$TF_ACTION_COMMENT" = "1" ] || [ "$TF_ACTION_COMMENT" = "false" ]; then
    exit $SUCCESS
fi

COMMENT="#### \`terraform init\` Failed
\`\`\`
$OUTPUT
\`\`\`
*Workflow: \`$GITHUB_WORKFLOW\`, Action: \`$GITHUB_ACTION\`*"
PAYLOAD=$(echo '{}' | jq --arg body "$COMMENT" '.body = $body')
COMMENTS_URL=$(cat /github/workflow/event.json | jq -r .pull_request.comments_url)
curl -s -S -H "Authorization: token $GITHUB_TOKEN" --header "Content-Type: application/json" --data "$PAYLOAD" "$COMMENTS_URL" > /dev/null

exit $SUCCESS

