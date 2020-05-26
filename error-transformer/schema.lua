return {
  no_consumer = false,
  fields = {
    -- This plugin has no customizable configuration.
  },
  self_check = function(schema, plugin_t, dao, is_updating)  --luacheck: no unused args
    return true
  end
}
