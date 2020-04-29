FROM akiranet24/terraform-sakuracloud:latest

LABEL "com.github.actions.name"="terraform validate"
LABEL "com.github.actions.description"="Validate the terraform files in a directory"
LABEL "com.github.actions.icon"="alert-triangle"
LABEL "com.github.actions.color"="blue"

LABEL "repository"="https://github.com/ak1ra24/terraform-sacloud-github-actions"
LABEL "maintainer"="Shogo Maeda <ak1ra24net@gmail.com>"

RUN sh /install.sh
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
