ARG BASE_IMG=<base>
FROM $BASE_IMG

ARG TARGETARCH

# args - software versions
USER root

ARG CODESERVER_VERSION=v4.93.1

# install - code-server
RUN curl -fsSL "https://github.com/coder/code-server/releases/download/${CODESERVER_VERSION}/code-server_${CODESERVER_VERSION/v/}_${TARGETARCH}.deb" -o /tmp/code-server.deb \
    && dpkg -i /tmp/code-server.deb \
    && rm -f /tmp/code-server.deb

RUN chown ${NB_USER}:${NB_GID} -R /home/${NB_USER}

# Install NGINX to solve 2 problems.
# 1. kubeflow docker images need to support $NB_PREFIX variable, which is the
# URL base path for the running notebook server instance. code-server can only
# serve the URL with empty base path. So we use nginx to strip the base path
# before passing request to code-server.
# 2. VSCode uses HOST header to determine the target of secure socket
# connection wss://<host>/some_resource. The HOST header it recieves from
# kubeflow is something like "prodflow-ui", which is different from domain name
# in kubeflow URL prodflow.sberned.ru, which makes wss connection fail. So, we
# use nginx to modify the HOST header.
ENV DEBIAN_FRONTEND=noninteractive
RUN apt -yq update \
    && apt install -yq --no-install-recommends nginx nginx-extras  \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

RUN chown $NB_UID:$NB_GID -R /var/log/nginx /var/lib/nginx /etc/nginx


# We don't have internet access in running kubeflow instances, so VSCode
# extensions have to be installed at docker build time
USER $NB_UID
RUN code-server --force \
    --install-extension ms-python.python \
    --install-extension ms-python.isort \
    --install-extension ms-python.black-formatter \
    --install-extension ms-python.mypy-type-checker \
    --install-extension ms-vscode.makefile-tools \
    --install-extension ms-toolsai.jupyter \
    --install-extension mtxr.sqltools \
    --install-extension mtxr.sqltools-driver-pg \
    --install-extension mtxr.sqltools-driver-mysql \
    --install-extension redhat.vscode-yaml \
    --install-extension janisdd.vscode-edit-csv \
    --install-extension mechatroner.rainbow-csv \
    --install-extension tamasfe.even-better-toml \
    --install-extension donjayamanne.githistory \
    --install-extension ryuta46.multi-command \
    && (curl -sSL https://install.python-poetry.org | python3 -) \
    && cp -ar $HOME/.local $HOME/.config $HOME_TMP \
    && rm -r $HOME/.local $HOME/.config

USER root

RUN apt -yq update \
    && apt install -yq python3.10-venv python3.11 python3.11-venv \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# No need to install nvidia driver or toolkit since kubeflow mounts it to the
# container.

RUN apt -yq update \
    && apt install -yq \
    7zip build-essential curl fish mc zip rsync man-db \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

COPY install_lazygit.sh /tmp
RUN /tmp/install_lazygit.sh && rm /tmp/install_lazygit.sh

USER $NB_UID

# s6 - copy scripts
COPY --chown=${NB_USER}:${NB_GID} --chmod=755 s6/ /etc

# Copy vscode settings and shortcuts. These file are then copied without
# overwriting into mounted /home/jovyan by
# components/example-notebook-servers/base/s6/cont-init.d/01-copy-tmp-home
COPY --chown=${NB_USER}:${NB_GID} home_tmp/ $HOME_TMP

EXPOSE 8888
ENV HOST=prodflow.sberned.ru
