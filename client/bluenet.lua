os.loadAPI("json")
local ws, err
local id
return {
    open = function(url, newId)
        ws, err = http.websocket(url)
        if not ws then
            error(err)
        end
        id = newId
    end,


    close = function()
        ws.close()
    end,
    

    send = function(receiveId, msg, protocol)
        local message = {from = id, to = receiveId, protocol = protocol, message = msg}
        local encoded = json.encode(message)
        ws.send(encoded)
    end,


    broadcast = function(msg, protocol)
        local message = {from = id, to = "all", protocol = protocol, message = msg}
        local encoded = json.encode(message)
        ws.send(encoded)
    end,


    receive = function(protocol, timeout)
        while true do
            local msg = ws.receive(timeout)
            local obj = json.parseObject(msg)
            local decoded = json.parseObject(obj.func)

            if decoded.to == id or decoded.to == "all" then
                if protocol then
                    if protocol == decoded.protocol then
                        return decoded.from, decoded.message, decoded.protocol
                    end
                else
                    return decoded.from, decoded.message, decoded.protocol
                end
            end
        end
    end,
}