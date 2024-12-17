# Start with the base image used by GitHub Codespaces
FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu

# Switch to root to install packages
USER root

# Update and install necessary packages
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Download the Cato client
RUN wget -c https://clientdownload.catonetworks.com/public/clients/cato-client-install.deb -O /tmp/cato-client-install.deb

# Install the Cato client without starting the service
RUN dpkg --unpack /tmp/cato-client-install.deb && \
    rm /var/lib/dpkg/info/cato-client.postinst -f && \
    dpkg --configure cato-client && \
    apt-get install -f -y

# Clean up
RUN rm /tmp/cato-client-install.deb

# Switch back to the non-root user
USER codespace

# Set up a script to start the Cato client manually
RUN echo '#!/bin/bash\n/opt/cato/cato-client start' > /home/codespace/start-cato.sh && \
    chmod +x /home/codespace/start-cato.sh

# Set the entry point to start the Cato client and then run the default command
ENTRYPOINT ["/bin/bash", "-c", "/home/codespace/start-cato.sh && exec \"$@\""]
CMD ["/bin/bash"]
