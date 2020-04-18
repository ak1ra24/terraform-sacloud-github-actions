#!/bin/sh
set -e
cd "${TF_ACTION_WORKING_DIR:-.}"

if [[ ! -z "$TF_ACTION_WORKSPACE" ]] && [[ "$TF_ACTION_WORKSPACE" != "default" ]]; then
  terraform workspace select "$TF_ACTION_WORKSPACE"
fi

set +e
PLUGINS_DIR="$HOME/.terraform.d/plugins/linux_amd64"
mkdir -p $PLUGINS_DIR
mv /terraform-provider-sakuracloud $PLUGINS_DIR
set -e

set +e
PLUGINS_DIR="$HOME/.terraform.d/plugins/linux_amd64"
mkdir -p $PLUGINS_DIR
cp -f /terraform-provider-sakuracloud $PLUGINS_DIR
set -e

set +e
OUTPUT=$(sh -c "terraform init -no-color -input=false $*; terraform validate -no-color $*" 2>&1)
SUCCESS=$?
echo "$OUTPUT"
echo "$HOME"
echo "$PWD"
set -e

if [ $SUCCESS -eq 0 ]; then
    exit 0
fi

if [ "$TF_ACTION_COMMENT" = "1" ] || [ "$TF_ACTION_COMMENT" = "false" ]; then
    exit $SUCCESS
fi

COMMENT="#### \`terraform validate\` Failed
\`\`\`
$OUTPUT
\`\`\`
*Workflow: \`$GITHUB_WORKFLOW\`, Action: \`$GITHUB_ACTION\`*"
PAYLOAD=$(echo '{}' | jq --arg body "$COMMENT" '.body = $body')
COMMENTS_URL=$(cat /github/workflow/event.json | jq -r .pull_request.comments_url)
curl -s -S -H "Authorization: token $GITHUB_TOKEN" --header "Content-Type: application/json" --data "$PAYLOAD" "$COMMENTS_URL" > /dev/null

exit $SUCCESS
