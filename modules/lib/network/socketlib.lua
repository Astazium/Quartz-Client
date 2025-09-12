
local socketlib = {}

-- Подключение к TCP-серверу
function socketlib.connect(address, port, on_connect, on_error)
    local status, socket = pcall(network.tcp_connect, address, port, function(s)
        if s:is_connected() then
            if on_connect then
                on_connect(s)
            end
        end
    end)

    if not status then
        if on_error then
            on_error()
        end
        return
    end

    return socket
end

-- Отправка байт через сокет
function socketlib.send(socket, bytes)
    if socket and socket:is_alive() then
        socket:send(bytes)
    else
        error("Сокет закрыт или не существует.")
    end
end

-- Получение байт через сокет
function socketlib.receive(socket, max_length)
    if socket then
        local bytes = socket:recv(max_length, true) -- Читаем как таблицу
        bytes = bytes or {}
        if #bytes > 0 then
            return bytes
        else
            return nil
        end
    else
        error("Сокет закрыт или не существует.")
    end
end

-- Закрытие сокета
function socketlib.close_socket(socket)
    if socket and socket:is_alive() then
        socket:close()
    end
end

-- Аналитика сети
function socketlib.get_network_stats()
    return {
        total_upload = network.get_total_upload(),
        total_download = network.get_total_download()
    }
end

return socketlib