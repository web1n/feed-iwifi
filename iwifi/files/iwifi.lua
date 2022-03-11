require 'nixio.fs'

require 'luci.http'
require 'luci.util'
require 'luci.jsonc'

local URL_DO_LOGIN = "http://61.240.137.242:8888/hw/internal_auth"
local URL_PORTAL = "http://connect.rom.miui.com/generate_204"

iwifi = {}

function parse_url(url)
    local params = {}

    local path = url:split '?'
    if (#path ~= 2) then
        return params
    end
    path = path[2]

    for _, v in pairs(path:split '&') do
        local args = v:split '='
        if (#args == 2) then
            params[args[1]] = args[2]
        end
    end

    return params
end

function curl(url, interface, data, timeout)
    local user_agent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.121 Safari/537.36'

    local command = "curl -i -s --user-agent '%s' --interface %s --connect-timeout %d '%s'" % { user_agent, interface, timeout or 3, url }
    if data ~= nil then
        command = '%s -d \'%s\'' % { command, luci.http.urlencode_params(data) }
    end

    local result = luci.util.exec(command):split('\r\n\r\n', 1)
    if (#result ~= 2) then
        return 0, nil, {}
    end

    local result_data = result[2]
    if (#result_data == 0) then
        result_data = nil
    end

    local code = tonumber(result[1]:split ' '[2])

    local response_headers = {}
    for _, line in pairs(result[1]:split '\r\n') do
        local args = line:split ': '
        if (#args == 2) then
            response_headers[args[1]:lower()] = args[2]
        end
    end

    return code, result_data, response_headers
end

function iwifi.check_net(interface)
    local code, _, response_headers = curl(URL_PORTAL, interface)
    if code == 204 then
        return true
    elseif response_headers.location ~= nil then
        local params = parse_url(response_headers.location)
        for _, v in ipairs({ 'userip', 'nasip', 'user-mac' }) do
            if not params[v] then
                return false
            end
        end

        return response_headers.location
    else
        return false
    end
end

function iwifi.login(interface, username, password, redirect_url)
    if not redirect_url then
        return 'error', 'need redirect url'
    end

    local params = parse_url(redirect_url)

    local data = {
        mobile = username,
		mobile_english = '',
        password = password,
		password_english = '',
        auth_type = 'account',
        enterprise_id = 51,
        enterprise_url = 'HBHUAWEI',
        site_id = 4662,
        client_mac = params['user-mac']:gsub(':', '%%3A'),
        nas_ip = params['nasip'],
		wlanacname = 'None',
        user_ip = params['userip'],
		ap_mac = 'None',
        vlan = '11-11-11-11-11-11',
		ssid = 'None',
		vlan_id = 'None',
		ip = 'None',
		ac_ip = 'None',
		from = 'None',
		sn = 'None',
		gw_id = 'None',
		gw_address = 'None',
		gw_port = 'None',
		url = 'None',
		language_tag = 0
    }

    local code, result_data = curl(URL_DO_LOGIN, interface, data)
    if code ~= 200 then
        return 'error', 'response code is %d' % code
	elseif result_data == nil then
		return 'error', 'response data is null'
    else
        local parsed_data = luci.jsonc.parse(result_data)

        return parsed_data['op'], parsed_data['message']
    end
end

return iwifi
