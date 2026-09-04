FROM ubuntu:24.04

ARG CODER_UID=1000
ARG CODER_GID=1000

ENV DEBIAN_FRONTEND=noninteractive \
    PATH="/home/coder/.local/bin:${PATH}"
# HOME is intentionally NOT set here: setting it globally would apply to
# every RUN step regardless of which USER is active, including the
# code-server install below which still runs as root. Docker sets HOME
# correctly per-user automatically once `USER coder` is in effect,
# resolving it from /etc/passwd -- an explicit global override here
# previously caused root's installer to write into what should be
# coder-only home directory contents, poisoning their ownership.

# --- Base packages -----------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        git \
        sudo \
        tmux \
        ca-certificates \
        unzip \
        build-essential \
        openssh-client \
        locales \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8

# --- Non-root user -------------------------------------------------------
# code-server and Claude Code both expect to run as a normal user, not root.
# GID 100 is Ubuntu's own reserved "users" group -- and also the default
# GID of Synology's "users" group, so CODER_GID often collides with it.
# Reuse the existing group by GID instead of failing when that happens.
RUN (getent group ${CODER_GID} >/dev/null || groupadd -g ${CODER_GID} coder) \
    && useradd -m -u ${CODER_UID} -g ${CODER_GID} -s /bin/bash coder \
    && echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# --- code-server (VS Code in the browser) --------------------------------
RUN curl -fsSL https://code-server.dev/install.sh | sh

# --- Claude Code (native installer, no Node.js dependency) ---------------
USER coder
WORKDIR /home/coder
RUN curl -fsSL https://claude.ai/install.sh | bash

# --- Entrypoint ------------------------------------------------------------
COPY --chown=coder:coder entrypoint.sh /home/coder/entrypoint.sh
USER root
RUN chmod +x /home/coder/entrypoint.sh
USER coder

EXPOSE 8080

ENTRYPOINT ["/home/coder/entrypoint.sh"]
