classdef Connection < handle
    
    properties (Access = private)
        connection
        attachedData
    end
    
    methods
        
        function obj = Connection(host, port)
            if nargin < 2
                obj.connection = host;
            else
                obj.connection = netbox.tcp.TcpConnection();
                obj.connection.connect(host, port);
            end
            obj.attachedData = containers.Map();
        end
        
        function n = getHostName(obj)
            n = obj.connection.getHostName();
        end
        
        function disconnect(obj)
            message.type = 'disconnect';
            try %#ok<TRYNC>
                obj.connection.write(message);
            end
            obj.connection.close();
        end
        
        function sendEvent(obj, event)
            message.type = 'message';
            message.event = event;
            obj.connection.write(message);
        end
        
        function setReceiveTimeout(obj, t)
            obj.connection.setReadTimeout(t);
        end
        
        function m = receiveMessage(obj)
            try
                m = obj.connection.read();
            catch x
                if strcmp(x.identifier, 'TcpConnection:ReadTimeout')
                    error('Connection:ReceiveTimeout', 'Receive timeout');
                else
                    rethrow(x);
                end
            end
        end
        
        function setData(obj, key, value)
            obj.attachedData(key) = value;
        end
        
        function d = getData(obj, key)
            d = obj.attachedData(key);
        end
        
        function removeData(obj, key)
            if ~obj.isData(key)
                return;
            end
            obj.attachedData.remove(key);
        end
        
        function tf = isData(obj, key)
            tf = obj.attachedData.isKey(key);
        end
        
        function clearData(obj)
            obj.attachedData = containers.Map();
        end
        
    end
    
end

