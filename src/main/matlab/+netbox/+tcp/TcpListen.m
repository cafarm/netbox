classdef TcpListen < handle
    
    properties (Access = private)
        socket
    end
    
    methods
        
        function obj = TcpListen(port)
            if nargin < 1
                port = 5678;
            end
            
            obj.socket = java.net.ServerSocket(port);
            obj.socket.setSoTimeout(10);
        end
        
        function delete(obj)
            obj.close();
        end
        
        function connection = accept(obj)
            connection = [];
            while isempty(connection) && ~obj.socket.isClosed
                try
                    s = obj.socket.accept();
                catch x
                    if isa(x.ExceptionObject, 'java.net.SocketTimeoutException')
                        continue;
                    else
                        error(char(x.ExceptionObject.getMessage()));
                    end
                end 
                connection = netbox.tcp.TcpConnection(s);
            end
        end
        
        function close(obj)
            obj.socket.close();
        end
        
    end
    
end

