classdef TcpConnection < handle
    
    properties (Access = private, Transient)
        socket
    end
    
    properties (Access = private)
        readTimeout
    end
    
    methods
        
        function obj = TcpConnection(socket)
            v = version('-java');
            if str2double(v(6:8)) < 1.7
                error('Java 7+ required');
            end
            
            if nargin < 1
                socket = java.net.Socket();
            end
            
            obj.socket = socket;
            obj.readTimeout = 0;
        end
        
        function delete(obj)
            obj.close();
        end
        
        % Connects to the specified host ip on the specified port.
        function connect(obj, host, port)
            addr = java.net.InetSocketAddress(host, port);
            timeout = 10000;
            
            try
                obj.socket.connect(addr, timeout);
            catch x
                error(char(x.ExceptionObject.getMessage()));
            end
        end
        
        function close(obj)
            obj.socket.close();
        end
        
        % Sets read timeout in milliseconds. A timeout less than or equal to zero is considered infinite.
        function setReadTimeout(obj, t)
            obj.readTimeout = t;
        end
        
        function write(obj, varargin)
            try
                stream = java.io.ObjectOutputStream(obj.socket.getOutputStream());
            catch x
                if isa(x, 'matlab.exception.JavaException')
                    error(char(x.ExceptionObject.getMessage()));
                end
                rethrow(x);
            end
            
            % Serialize
            temp = [tempname '.mat'];
            save(temp, 'varargin');
            file = java.io.File(temp);
            
            try
                stream.writeObject(java.nio.file.Files.readAllBytes(file.toPath));
            catch x
                if isa(x, 'matlab.exception.JavaException')
                    error(char(x.ExceptionObject.getMessage()));
                end
                rethrow(x);
            end
            delete(temp);
        end
        
        function varargout = read(obj)
            in = obj.socket.getInputStream();
            
            start = tic;
            while in.available() == 0
                if obj.readTimeout > 0 && toc(start) >= obj.readTimeout / 1e3
                    error('TcpConnection:ReadTimeout', 'Read timeout');
                end
            end
            
            stream = java.io.ObjectInputStream(in);
            
            result = stream.readObject();
            
            % Deserialize
            temp = [tempname '.mat'];
            fid = fopen(temp, 'w');
            fwrite(fid, typecast(result, 'uint8'));
            fclose(fid);
            s = load(temp);
            delete(temp);
            
            varargout = s.varargin;
        end
        
    end
    
end