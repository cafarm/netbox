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
        
        function disconnect(obj)
            message.type = 'disconnect';
            obj.connection.write(message);
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
        
    end
    
end

