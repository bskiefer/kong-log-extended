local _M = {}

local random = math.random
local function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

function _M.serialize(ngx)
  local authenticated_entity
  if ngx.ctx.authenticated_credential ~= nil then
    authenticated_entity = {
      id = ngx.ctx.authenticated_credential.id,
      consumer_id = ngx.ctx.authenticated_credential.consumer_id
    }
  end

  return {
    service = {
      agent = {
        name = "kong",
        version = "1.0"
      },
      name = "Kong"
    },
    transactions = {
      {
        id = uuid(),
        duration = tonumber(ngx.var.request_time),
        result = tostring(ngx.status),
        name = ngx.req.get_method().." "..ngx.var.request_uri,
        type = "HTTP",
        context = {
          request = {
            uri = ngx.var.request_uri,
            upstream = {
              hostname = ngx.var.upstream_host,
              pathname = ngx.var.upstream_uri,
              protocol = ngx.var.upstream_scheme,
              status = ngx.var.upstream_status,
              forwarded_port = ngx.var.http_x_forwarded_port,
              forwarded_for = ngx.var.upstream_x_forwarded_for,
              forwarded_path = ngx.var.upstream_x_forwarded_prefix,
              forwarded_proto = ngx.var.upstream_x_forwarded_proto
            },
            url = {
              full = ngx.var.scheme.."://"..ngx.var.host..":"..ngx.var.server_port..ngx.var.request_uri,
              hostname = ngx.var.host,
              pathname = ngx.var.request_uri,
              port = ngx.var.server_port,
              protocol = ngx.var.scheme
            },
            querystring = ngx.req.get_uri_args(), -- parameters, as a table
            method = ngx.req.get_method(), -- http method
            headers = ngx.req.get_headers(),
            size = ngx.var.request_length,
            body = ngx.ctx.log_extended_req_body
          },
          response = {
            status_code = ngx.status,
            finished = true,
            headers = ngx.resp.get_headers(),
            size = ngx.var.bytes_sent,
            body = ngx.ctx.log_extended_res_body
          }
        }
      }
    }
  }
end

return _M