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
        if not ws then
            error("No Websocket Opened")
        end
        ws.close()
    end,
    

    isOpen = function()
        if ws then
            return true
        end
        return false
    end,


    send = function(receiveId, msg, protocol)
        if not ws then
            error("No Websocket Opened")
        end
        local message = {from = id, to = receiveId, protocol = protocol, message = msg}
        local encoded = json.encode(message)
        ws.send(encoded)
    end,


    broadcast = function(msg, protocol)
        if not ws then
            error("No Websocket Opened")
        end
        local message = {from = id, to = "all", protocol = protocol, message = msg}
        local encoded = json.encode(message)
        ws.send(encoded)
    end,


    receive = function(protocol, timeout)
        local duration = 0
        while true do
            if timeout then
                if duration >= timeout*10 then
                    break
                end
                duration = duration + 1
            end

            local msg = ws.receive(0.1)
            local obj = json.parseObject(msg)
            local decoded = json.parseObject(obj.func)

            if decoded.to == id or decoded.to == "all" then
                if not protocol then
                    return decoded.from, decoded.message, decoded.protocol
                end
                if protocol == decoded.protocol then
                    return decoded.from, decoded.message, decoded.protocol
                end
            end
        end
    end,
}