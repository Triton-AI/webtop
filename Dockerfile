ARG BASE_FROM
FROM $BASE_FROM as base
LABEL maintainer="Moises Lopez <mdlopezme@gmail.com>"

FROM base as apt
COPY apt/common-packages /tmp/common-packages
# Install Apt packages
RUN apt update && DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends \
        $(cat /tmp/common-packages | cut -d# -f1) && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/common-packages

ARG APT_PACKAGES
COPY apt/${APT_PACKAGES} /tmp/${APT_PACKAGES}
# Install Apt packages
RUN apt update && DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends \
        $(cat /tmp/${APT_PACKAGES} | cut -d# -f1) && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/${APT_PACKAGES}

FROM apt as pip
# Install pip packages
ARG PIP_PACKAGES
COPY pip/${PIP_PACKAGES} /tmp/${PIP_PACKAGES}
RUN pip3 install --no-cache-dir --upgrade -r /tmp/${PIP_PACKAGES} && \
    rm -rf /tmp/${PIP_PACKAGES}

FROM pip as pip-gpu
# Install pip packages
ARG PIP_GPU_PACKAGES
COPY pip-gpu/${PIP_GPU_PACKAGES} /tmp/${PIP_GPU_PACKAGES}
RUN pip3 install --no-cache-dir -r /tmp/${PIP_GPU_PACKAGES} && \
    rm -rf /tmp/${PIP_GPU_PACKAGES}

FROM pip-gpu as custom
RUN mkdir -p ~/.ssh \
  && ssh-keyscan github.com >> ~/.ssh/known_hosts \
  && ssh-keyscan gitlab.com >> ~/.ssh/known_hosts
# Run the custom install file
ARG CUSTOM_INSTALL_FILE
COPY custom/${CUSTOM_INSTALL_FILE} /tmp/${CUSTOM_INSTALL_FILE}
RUN --mount=type=ssh \
    DEBIAN_FRONTEND=noninteractive /bin/sh /tmp/${CUSTOM_INSTALL_FILE} && \
    rm -rf /tmp/${CUSTOM_INSTALL_FILE}

FROM custom as bash
# Append to the bashrc file
ARG BASH_SETTINGS_FILE
COPY bash/${BASH_SETTINGS_FILE} /tmp/.bashrc
RUN cat /tmp/.bashrc >> /root/.bashrc && \
    rm -rf /tmp/.bashrc

FROM bash as test
# Run the test install file
ARG TEST_INSTALL_FILE
COPY test/${TEST_INSTALL_FILE} /tmp/${TEST_INSTALL_FILE}
RUN DEBIAN_FRONTEND=noninteractive /bin/sh /tmp/${TEST_INSTALL_FILE} && \
    rm -rf /tmp/${TEST_INSTALL_FILE}