local pl_utils = require "pl.utils"
local typedefs = require "kong.db.schema.typedefs"

local function validate_file(value)
  local ok = pl_utils.executeex("touch "..value)
  if not ok then
    return false, "Cannot create file. Make sure the path is valid, and has the right permissions"
  end

  return true
end

-- return {
--   fields = {
--     path = { required = true, type = "string", func = validate_file },
--     log_bodies = { type = "boolean", default = true },
--     log_body = { type = "boolean", default = true },
--     exclude = { type = "array", elements = { type = "string" }}
--   }
-- }
-- local typedefs = require "kong.db.schema.typedefs"

return {
  name = "file-log-extended",
  --no_consumer = false, -- this plugin is available on APIs as well as on Consumers,
  fields = {
    -- Describe your plugin's configuration's schema here.
    {
      config = {
        type = "record",
        fields = {
          
          {
            consumer = typedefs.no_consumer,
          },
          {
            path = { required = true, type = "string", custom_validator = validate_file },
          },
          {
            log_bodies = { type = "boolean", default = true },
          },
          {
            exclude_request_fields = { type = "array", elements = { type = "string" }},
          },
        },
      },
    },
  },

}

