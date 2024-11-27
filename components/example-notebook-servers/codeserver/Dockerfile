ARG BASE_IMG=<base>
FROM $BASE_IMG

ARG TARGETARCH

# args - software versions
USER root

RUN chown ${NB_USER}:${NB_GID} -R /home/${NB_USER}

RUN apt -yq update \
    && apt install -yq python3.10-venv python3.11 python3.11-venv python-is-python3 \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# No need to install nvidia driver or toolkit since kubeflow mounts it to the
# container.

RUN apt -yq update \
    && apt install -yq \
    7zip build-essential curl mc zip rsync man-db htop nvtop \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

COPY install_lazygit.sh /tmp
RUN /tmp/install_lazygit.sh && rm /tmp/install_lazygit.sh

COPY install_tig.sh /tmp
RUN /tmp/install_tig.sh && rm /tmp/install_tig.sh

COPY install_git_delta.sh /tmp
RUN /tmp/install_git_delta.sh && rm /tmp/install_git_delta.sh

# install vscode
RUN DEBIAN_FRONTEND=noninteractive \
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg \
    && install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg \
    && echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
        | tee /etc/apt/sources.list.d/vscode.list > /dev/null \
    && rm -f packages.microsoft.gpg \
    && apt -yq update \
    && apt install -yq code \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# COPY --chown=${NB_USER}:${NB_GID} --chmod=755 download-vs-code.sh /tmp

# We don't have internet access in running kubeflow instances, so VSCode
# extensions have to be installed at docker build time
USER $NB_UID

RUN /usr/bin/code \
    --extensions-dir $HOME_TMP/.local/share/code-server/extensions \
    --force \
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

# RUN /tmp/download-vs-code.sh "linux" "x64" --extensions \
#     "ms-python.python ms-python.isort ms-python.black-formatter ms-python.mypy-type-checker ms-vscode.makefile-tools ms-toolsai.jupyter mtxr.sqltools mtxr.sqltools-driver-pg mtxr.sqltools-driver-mysql redhat.vscode-yaml janisdd.vscode-edit-csv mechatroner.rainbow-csv tamasfe.even-better-toml donjayamanne.githistory ryuta46.multi-command"

# RUN curl -sSL https://install.python-poetry.org | python3 - \
#     && cp -ar $HOME/.local $HOME/.config $HOME_TMP \
#     && rm -r $HOME/.local $HOME/.config

# RUN curl -sSL https://install.python-poetry.org | python3 - \
#     && cp -ar $HOME/.local $HOME_TMP \
#     && rm -r $HOME/.local

# s6 - copy scripts
COPY --chown=${NB_USER}:${NB_GID} --chmod=755 s6/ /etc

EXPOSE 8888
