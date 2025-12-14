# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.183.0/containers/ruby/.devcontainer/base.Dockerfile

# [Choice] Ruby version: 3, 3.0, 2, 2.7, 2.6
ARG VARIANT="bookworm"
FROM mcr.microsoft.com/devcontainers/ruby:${VARIANT}

#ARG INSTALL_ZSH="true"

# [Option] Install Node.js
# ARG INSTALL_NODE="true"
# ARG NODE_VERSION="lts/*"
# RUN if [ "${INSTALL_NODE}" = "true" ]; then su vscode -c "umask 0002 && . /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} 2>&1"; fi

# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends tesseract-ocr tesseract-ocr-deu libleptonica-dev imagemagick postgresql-client libvips42 libffi-dev libgmp-dev libyaml-dev libpq-dev 

# [Optional] Uncomment this line to install global node packages.
# RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && npm install -g <your-package-here>" 2>&1

RUN curl -fsSL https://starship.rs/install.sh | sh -s -- --yes 
RUN echo "eval \"\$(starship init bash)\"" >> /home/vscode/.bashrc && echo "eval \"\$(starship init zsh)\"" >> /home/vscode/.zshrc

USER vscode

