# kong-plugins

## Available plugins

### error-transformer

Lua plugin, which, based on the message returned by the Kong core logic or higher priority plugins, maps the 
error to a new one (hardcoded in [logic](./error-transformer/body_transformer.lua)) and 
returns that one in the response payload instead. Could be easily modified to read messages from database.


### How to install plugins

The plugin must reside in the right folder, so Kong is aware of the plugin. Also you must update the `plugins` config to
tell Kong which plugin to load up on boot.

Example for Docker: to copy files with `kong:0.14.1` as a base image use the following command to copy a plugin 
to the right location:

    COPY error-transformer/ /usr/local/share/lua/5.1/kong/plugins/error-transformer/

Then enable it in the config, either in `kong.conf` by setting `plugins` field or setting environment variable `KONG_PLUGINS` to:

    bundled,error-transformer
