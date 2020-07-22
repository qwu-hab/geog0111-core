FROM jgomezdans/geog

LABEL maintainer="Philip Lewis <p.lewis@ucl.ac.uk>"
USER root

# Install all OS dependencies for notebook server that starts but lacks all
# features (e.g., download as all possible file formats)
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
 && apt-get install -yq --no-install-recommends \
    git \
    wget \
    curl \
    bzip2 \
    ca-certificates \
    sudo \
    locales \
    fonts-liberation \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# Configure environment
ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash \
    NB_USER=$NB_USER \
    NB_UID=$NB_UID \
    NB_GID=$NB_GID \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8
ENV PATH=$CONDA_DIR/bin:$PATH \
    HOME=/home/$NB_USER

# get some basics for setup
#
# fix-permissions
# environment.yml
# Chapter1_help.ipynb as a test notebook
# postBuild

RUN curl -O https://raw.githubusercontent.com/jupyter/docker-stacks/master/base-notebook/fix-permissions && \
    curl -O https://raw.githubusercontent.com/profLewis/newform0111/master/environment.yml && \
    curl -O https://raw.githubusercontent.com/profLewis/newform0111/master/notebooks/Chapter1_help.ipynb && \
    curl -O https://raw.githubusercontent.com/profLewis/newform0111/master/postBuild && \
    chmod a+rx fix-permissions && \
    cp fix-permissions /usr/local/bin/fix-permissions


RUN mkdir -p test && \
    fix-permissions test && \
    mv environment.yml postBuild Chapter1_help.ipynb test

# Create NB_USER wtih name jovyan user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
RUN mkdir -p $CONDA_DIR && \
    chown $NB_USER:$NB_GID $CONDA_DIR && \
    chmod g+w /etc/passwd && \
    fix-permissions $HOME && \
    fix-permissions $CONDA_DIR

USER $NB_UID
WORKDIR $HOME
ARG PYTHON_VERSION=default

RUN fix-permissions /home/$NB_USER

# update conda packages
RUN conda update -n base conda --yes && \
    conda update -n base --all --yes && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER 



