ARG BASE_IMG=<base>
FROM $BASE_IMG

ARG TARGETARCH

USER root

RUN apt -yq update \
    && apt install -yq \
    fish emacs openssh-client \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

USER $NB_UID