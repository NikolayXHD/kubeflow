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

COPY install_tig.sh /tmp
RUN /tmp/install_tig.sh && rm /tmp/install_tig.sh

COPY install_git_delta.sh /tmp
RUN /tmp/install_git_delta.sh && rm /tmp/install_git_delta.sh

USER $NB_UID

# s6 - copy scripts
COPY --chown=${NB_USER}:${NB_GID} --chmod=755 s6/ /etc

# Copy vscode settings and shortcuts. These file are then copied without
# overwriting into mounted /home/jovyan by
# components/example-notebook-servers/base/s6/cont-init.d/01-copy-tmp-home
COPY --chown=${NB_USER}:${NB_GID} home_tmp/ $HOME_TMP

EXPOSE 8888
