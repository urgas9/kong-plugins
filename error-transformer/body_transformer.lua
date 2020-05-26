local cjson_decode = require("cjson").decode

local pcall = pcall

local _M = {}

local function get_mapped_error(message)
  --[[
  This function handles mapping between Kong error messages and custom error
  messages/structures.
  --]]

  local error_msg_mappings = {}
  error_msg_mappings["No API key found in request"] =
      '{"errors": [{"code": 0001, "message": "Not authorised or incorrect API key"}]}'

  error_msg_mappings["API keys mismatch"] =
      '{"errors": [{"code": 0002, "message": "Mismatch of URL parameter \\"key\\" and HTTP header parameter ' ..
      '\\"X-API-Key\\""}]}'

  error_msg_mappings["Invalid authentication credentials"] =
      error_msg_mappings["No API key found in request"]

  error_msg_mappings["API rate limit exceeded"] =
      '{"errors": [{"code": 0010,"message": "API rate limit exceeded"}]}'

  error_msg_mappings["An unexpected error occurred"] =
      '{"errors": [{"code": 9999, "message": "An unhandled exception occurred"}]}'

  return error_msg_mappings[message]
end

local function read_json_body(body)
  if body then
    local status, res = pcall(cjson_decode, body)
    if status then
      return res
    end
  end
end

function _M.transform_error(body)
  --[[
  Module function which reads JSON response and transforms
  Kong errors to custom errors.
  --]]
  local json_body = read_json_body(body)

  if json_body ~= nil then
    local mapped_error = get_mapped_error(json_body['message'])
    return mapped_error
  else
    return nil
  end
end

return _M
