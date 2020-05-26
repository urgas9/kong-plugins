FROM kong:0.14.1

COPY error-transformer/ /usr/local/share/lua/5.1/kong/plugins/error-transformer/

# Copy configuration file to a place readable by Kong
COPY kong.conf /etc/kong/kong.conf

# Copy over entry point script used for testing purposes
COPY scripts/fix-host-entrypoint.sh /fix-host-entrypoint.sh
