local cjson = require "cjson"
local helpers = require "spec.helpers"
local client = require "resty.kafka.client"
local producer = require "resty.kafka.producer"

local function create_big_data(size)
  return {
    mock_json = {
      big_field = string.rep("*", size),
    },
  }
end

for _, strategy in helpers.each_strategy() do
  describe("Plugin: kafka-log (log) [#" .. strategy .. "]", function()
    local proxy_client

    lazy_setup(function()
      local bp = helpers.get_db_utils(strategy, {
        "routes",
        "services",
        "plugins",
      })

      local service = bp.services:insert {
        protocol = "http",
        host = helpers.mock_upstream_host,
        port = helpers.mock_upstream_port,
      }

      local route = bp.routes:insert {
        hosts = { "kafka.com" },
        service = service
      }

      bp.plugins:insert {
        route = { id = route.id },
        name = "kafka-log",
        config = {
          bootstrap_servers = { "172.28.1.6:9092" },
          topic = "kong-log-test"
        }
      }

      local test_error_log_path = helpers.test_conf.nginx_err_logs
      os.execute(":> " .. test_error_log_path)

      assert(helpers.start_kong({
        database = strategy,
        plugins = "kafka-log",
        nginx_conf = "/kong/spec/fixtures/custom_nginx.template",
      }))
    end)

    lazy_teardown(function()
      helpers.stop_kong()
    end)

    before_each(function()
      proxy_client = helpers.proxy_client()
    end)

    after_each(function()
      if proxy_client then
        proxy_client:close()
      end
    end)

    it("logs to Kafka", function()

      local res = assert(proxy_client:send({
        method = "POST",
        path = "/post",
        body = create_big_data(2048),
        headers = {
          ["host"] = "kafka.com",
          ["Content-Type"] = "application/json"
        }
      }))

      assert.res_status(200, res)

    end)
  end)
end
