local BasePlugin = require "kong.plugins.base_plugin"
local body_transformer = require "kong.plugins.error-transformer.body_transformer"

local table_concat = table.concat

-- error-transformer plugin was inspired by response-transformer plugin:
-- https://github.com/Kong/kong/tree/master/kong/plugins/response-transformer
local ErrorTransformerHandler = BasePlugin:extend()

-- kong plugin's execution order:
-- https://getkong.org/docs/0.13.x/plugin-development/custom-logic/#plugins-execution-order
ErrorTransformerHandler.PRIORITY = 13
ErrorTransformerHandler.VERSION = "0.1.0"

function ErrorTransformerHandler:new()
  ErrorTransformerHandler.super.new(self, "error-transformer")
end

function ErrorTransformerHandler:header_filter()
  ErrorTransformerHandler.super.header_filter(self)
  -- Removing the content-length header because the body might change
  if ngx.status >= 400 then
    ngx.header.content_length = nil
  end
end

function ErrorTransformerHandler:body_filter()
  --[[
  This function implements the main logic to intercept error messages via Nginx
  data chunks, transform them with help of error-transformer.body_transformer module
  and return them to the client.

  More about this request context:
  https://getkong.org/docs/0.13.x/plugin-development/custom-logic/#available-request-contexts
  --]]
  ErrorTransformerHandler.super.body_filter(self)

  local ctx = ngx.ctx
  -- This logic was moved out of :access as it did not get called before
  -- :body_filter in case of a Kong error
  ctx.rt_body_chunks = ctx.rt_body_chunks or {}
  ctx.rt_body_chunk_number = ctx.rt_body_chunk_number or 1

  -- We only transform in case of an HTTP error (4xx or 5xx)
  if ngx.status < 400 then
    return
  end

  local chunk, eof = ngx.arg[1], ngx.arg[2]

  -- Apply logic only when eof flag is set to true
  if eof then
    local body = table_concat(ctx.rt_body_chunks)
    ngx.log(ngx.INFO, "Original error message: " .. body)
    local mapped_error = body_transformer.transform_error(body)
    ngx.log(ngx.INFO, "Mapped error message: " .. tostring(mapped_error))
    if mapped_error ~= nil then
      ngx.arg[1] = mapped_error
    else
      ngx.arg[1] = ctx.rt_body_chunks
    end
  else
    ctx.rt_body_chunks[ctx.rt_body_chunk_number] = chunk
    ctx.rt_body_chunk_number = ctx.rt_body_chunk_number + 1
    ngx.arg[1] = nil
  end

end

return ErrorTransformerHandler
