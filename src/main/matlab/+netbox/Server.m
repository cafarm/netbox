classdef Server < handle
    
    properties
        clientConnectedFcn
        clientDisconnectedFcn
        eventReceivedFcn
        interruptFcn
    end
    
    properties (Access = private)
        stopRequested
    end
    
    methods
        
        function start(obj, port)
            if nargin < 2
                port = 5678;
            end
            
            obj.stopRequested = false;
            
            listen = netbox.tcp.TcpListen(port);
            close = onCleanup(@()delete(listen));
            
            listen.setAcceptTimeout(10);
            
            while ~obj.stopRequested
                try
                    connection = netbox.Connection(listen.accept());
                catch x
                    if strcmp(x.identifier, 'TcpListen:AcceptTimeout')
                        if ~isempty(obj.interruptFcn)
                            obj.interruptFcn();
                        end
                        continue;
                    else
                        rethrow(x);
                    end
                end
                obj.serve(connection);
            end
        end
        
        function requestStop(obj)
            obj.stopRequested = true;
        end
        
    end
    
    methods (Access = protected)
        
        function serve(obj, connection)
            if ~isempty(obj.clientConnectedFcn)
                obj.clientConnectedFcn(connection);
            end
            
            connection.setReceiveTimeout(10);
                        
            while ~obj.stopRequested
                try
                    message = connection.receiveMessage();
                catch x
                    if strcmp(x.identifier, 'Connection:ReceiveTimeout')
                        if ~isempty(obj.interruptFcn)
                            obj.interruptFcn();
                        end
                        continue;
                    else
                        rethrow(x);
                    end
                end
                
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

