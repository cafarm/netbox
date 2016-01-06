classdef Server < handle
    
    properties
        clientConnectedFcn
        clientDisconnectedFcn
        eventReceivedFcn
    end
    
    methods
        
        function start(obj, port)
            if nargin < 2
                port = 5678;
            end
            
            listen = netbox.tcp.TcpListen(port);
            close = onCleanup(@()delete(listen));
            
            while true
                connection = netbox.Connection(listen.accept());
                obj.serve(connection);
            end
        end
        
    end
    
    methods (Access = protected)
        
        function serve(obj, connection)
            if ~isempty(obj.clientConnectedFcn)
                obj.clientConnectedFcn(connection);
            end
                        
            while true
                message = connection.receiveMessage();
                if strcmp(message.type, 'disconnect')
                    break;
                end
                
                if ~isempty(obj.eventReceivedFcn)
                    obj.eventReceivedFcn(connection, message.event);
                end
            end
            
            if ~isempty(obj.clientDisconnectedFcn)
                obj.clientDisconnectedFcn(connection);
            end
        end
        
    end
    
end

