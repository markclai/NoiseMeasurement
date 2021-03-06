classdef GPIBObj < handle
    %GPIBOBJ Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        gpibAddr
        gpibObj
        gpibBoard
        interface = 'agilent'
        timeout = 1000;
        bufferSize = 10e6;
    end
    
    methods
        function obj = GPIBObj(gpibAddr, gpibBoard)
            %GPIBOBJ Creates a VISA or GPIB object depending on the number
            %of arguments. Also opens and requests the identifier.
            obj.gpibAddr = gpibAddr;
            if nargin == 2
                obj.gpibBoard = gpibBoard;
                try
                    obj.gpibObj = gpib(obj.interface, obj.gpibBoard, obj.gpibAddr);
                    obj.gpibObj.timeout = obj.timeout;
                    obj.gpibObj.InputBufferSize = obj.bufferSize;
                    fopen(obj.gpibObj);
                    fprintf("Connected to %s\n",(query(obj.gpibObj, "*IDN?")));
                    fclose(obj.gpibObj);
                catch ME
                    fprintf("Error message: %s\n", ME.message);
                    fclose(obj.gpibObj);
                    error("Couldn't initialize GPIB connection at GPIB Address %d\n", obj.gpibAddr);
                end
            else
                obj.gpibBoard = -1;
                obj.gpibObj = visa(obj.interface, obj.gpibAddr);
                obj.gpibObj.timeout = obj.timeout;
                obj.gpibObj.InputBufferSize = obj.bufferSize;
                obj.gpibObj.ByteOrder = 'littleEndian';
                try
                    fopen(obj.gpibObj);
                    clrdevice(obj.gpibObj);
                    fprintf("Connected to %s\n", query(obj.gpibObj, '*IDN?'));
                catch ME
                    fprintf("Error message: %s\n", ME.message);
                    error("Couldn't initialize VISA connection to %s\n", obj.gpibAddr);
                end
            end
        end
        
        
        function checkStatusAndConnect(obj)
            if strcmp(obj.gpibObj.status, 'closed')
                try
                    fopen(obj.gpibObj);
                catch ME
                    fprintf("Error message: %s\n", ME.message);
                    fclose(obj.gpibObj);
                    error("Couldn't connect to GPIB address %d", obj.gpibAddr);   
                end
            end
        end
        
        function status = checkStatusAndDisconnect(obj)
            status = true;
            if strcmp(obj.gpibObj.status, 'open')
                try
                    fclose(obj.gpibObj);
                    status = false;
                catch ME
                    fprintf("Error message: %s\n", ME.message);
                    fclose(obj.gpibObj);
                    error("Unable to close GPIB connection at GPIB Address %d\n", obj.gpibAddr);
                end
            end
        end
        function sendCommand(obj,comArray, size)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj.checkStatusAndConnect();
            for comCounter=1:size
                try
                    fprintf(obj.gpibObj,comArray(comCounter));
                    disp(comArray(comCounter));
                catch ME
                    fprintf("Error message: %s\n", ME.message);
                    fclose(obj.gpibObj);
                    error("Failed sending command %s\n", comArray{comCounter}); 
                end
            end
            
            %obj.checkStatusAndDisconnect();
        end
        
        function returnVal = sendQuery(obj, queryCmd)
            obj.checkStatusAndConnect();
            try
                returnVal = query(obj.gpibObj, queryCmd);
            catch
                fclose(obj.gpibObj);
                error("Failed to send query %s\n", queryCmd); 
            end
            
            %obj.checkStatusAndDisconnect();
        end
        
        function isError = checkErrors(obj)
            systemError = '';
            isError = false;
            while (~contains(lower(systemError),'no error'))
                systemError = obj.sendQuery("SYST:ERR?");
                fprintf("System error(s): %s", systemError);
                isError = true;
            end
        end
    end
end

