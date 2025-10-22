FROM debian:stable-slim

# Github labels
LABEL "com.github.actions.name"="Gokku deploy"
LABEL "com.github.actions.description"="Simple and powerful action to deploy to Gokku server via git or registry"
LABEL "com.github.actions.icon"="git-merge"
LABEL "com.github.actions.color"="green"

LABEL "repository"="https://github.com/thadeu/gokku-gh-action"
LABEL "homepage"="https://github.com/thadeu/gokku-gh-action"
LABEL "maintainer"="Thadeu Esteves <tadeuu@gmail.com>"

RUN apt-get update && apt-get install -y \
  openssh-client \
  git && \
  rm -Rf /var/lib/apt/lists/*

ADD LICENSE README.md /
ADD entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]