classdef Client < handle
    
    properties (Access = private)
        connection
    end
    
    methods
        
        function delete(obj)
            obj.disconnect();
        end
        
        function connect(obj, host, port)
            if nargin < 2
                host = 'localhost';
            end
            if nargin < 3
                port = 5678;
            end
            obj.disconnect();
            obj.connection = netbox.Connection(host, port);
        end
        
        function disconnect(obj)
            if isempty(obj.connection)
                return;
            end
            obj.connection.disconnect();
            obj.connection = [];
        end
        
        function sendEvent(obj, event)
            if isempty(obj.connection)
                error('Not connected');
            end
            obj.connection.sendEvent(event);
        end
        
        function e = receiveEvent(obj)
            if isempty(obj.connection)
                error('Not connected');
            end
            m = obj.connection.receiveMessage();
            assert(strcmp(m.type, 'message'));
            e = m.event;
        end
        
    end
    
end

