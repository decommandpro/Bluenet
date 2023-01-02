os.loadAPI("json")
local ws, err = http.websocket("ws://localhost:8081")
local id = math.random(1000, 10000)
return {
    open = function(url, newId)
        ws, err = http.websocket(url)
        if not ws then
            error("Cant connect to specified websocket")
        end
        id = newId
    end,


    send = function(receiveId, msg, protocol)
        local message = {from = '\"'..id..'\"', to = '\"'..receiveId..'\"', protocol = protocol, message = msg}
        ws.send(message)
    end,


    broadcast = function(msg, protocol)
        local message = {from = id, to = "all", protocol = protocol, message = msg}
        ws.send(message)
    end,


    receive = function(protocol, timeout)
        repeat
            local msg = ws.receive(timeout)
            local obj = json.decode(msg)
            local func = load("return "..obj.func)
            decoded = func()

            if decoded.to == id then
                if protocol then
                    if protocol == decoded.protocol then
                        return decoded.from, decoded.message, decoded.protocol
                    end
                else
                    return decoded.from, decoded.message, decoded.protocol
                end
            end
        until false
    end,
}