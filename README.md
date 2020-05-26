# kong-plugins

## Available plugins

### error-transformer

Lua plugin, which, based on the message returned by the Kong core logic or higher priority plugins, maps the 
error to a new one (hardcoded in [logic](./error-transformer/body_transformer.lua)) and 
returns that one in the response payload instead. Could be easily modified to read messages from database.


## How to install plugins

The plugin must reside in the right folder, so Kong is aware of the plugin. Also you must update the `plugins` config to
tell Kong which plugin to load up on boot.

[Example for Docker](Dockerfile): to copy files with `kong:0.14.1` as a base image use the following command to copy a plugin 
to the right location:

    COPY error-transformer/ /usr/local/share/lua/5.1/kong/plugins/error-transformer/

Then enable it in [the config](kong.conf), either in `kong.conf` by setting `plugins` field or setting environment variable `KONG_PLUGINS` to:

    bundled,error-transformer

## Run Docker Compose locally

To set up Kong environment locally set up Kong using docker-compose, which will set up database, 
run database migrations and spin up a Kong instance.

    docker-compose up
    
    # Get container name
    docker ps
    
    # Get IP of the container (change <container-name>, normally it'd be kongplugins_kong-test_1)
    docker inspect <container-name> | grep IPAddress
    
    # Use the IP to access Kong Admin API
    curl -X GET http://<Kong-IP>:8001
    
    # Use the IP to access Kong Proxy
    curl -X GET https://<Kong-IP>:8443 --insecure
