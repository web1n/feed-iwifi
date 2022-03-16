#! /usr/bin/lua

require 'iwifi'

require 'luci.model.uci'
require 'luci.util'

local argparse = require 'argparse'


local parser = argparse('iwifi', 'Client for Hebei Unicom iWiFi Service')
parser:option('-I --interface', 'Network interface'):count(1)
parser:option('-U --username', 'Your username'):count(1)
parser:option('-P --password', 'Your password'):count(1)

local args = parser:parse()

print('iWiFi client')

while true do
    local status = luci.util.ubus('network.interface.%s' % args.interface, 'status', {})
    if status == nil then
		print('interface not found')

		os.exit()
    elseif status['ipv4-address'] then
        local check_result = iwifi.check_net(status['ipv4-address'])
        if (check_result ~= true and check_result ~= false) then
            print('%s: find redirect url' % args.interface)

            local res, message = iwifi.login(status['ipv4-address'], args.username, args.password, check_result)
            if res == 'ok' then
                print('success')
            else
                print(message or 'can not auth')

                luci.util.ubus('network.interface.%s' % args.interface, 'down', {})
                luci.util.ubus('network.interface', 'notify_proto', {
                    interface = interface,
                    action = 3,
                    error = { tostring(content) }
                })
            end
        end
    end

    luci.util.exec('sleep %d' % 10)
end

