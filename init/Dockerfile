FROM akiranet24/terraform-sacloud-hoge

LABEL "com.github.actions.name"="terraform init"
LABEL "com.github.actions.description"="Run terraform init"
LABEL "com.github.actions.icon"="download"
LABEL "com.github.actions.color"="blue"

LABEL "repository"="https://github.com/ak1ra24/terraform-sacloud-github-actions"
LABEL "maintainer"="Shogo Maeda <ak1ra24net@gmail.com>"

RUN sh /install.sh
COPY entrypoint.sh /entrypoint-init.sh
ENTRYPOINT ["/entrypoint-init.sh"]
