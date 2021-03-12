classdef ImpGen
    %IMPGEN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        baudRate = 115200;
        serialObject;
    end
    
    methods
        function obj = ImpGen(comNumber)
            %IMPGEN Construct an instance of this class
            %   Detailed explanation goes here
            obj.serialObject = serial(sprintf("COM%d", comNumber), 'BaudRate', obj.baudRate);
        end
        
        function openSerial(obj)
            if(strcmp(obj.serialObject.Status, "closed"))      
                try
                    fopen(obj.serialObject);
                catch
                    error("Couldn't connect to impedance generator\n");
                end
            end
        end
        
        function setState(obj,setState)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            try
                obj.openSerial();
                switch setState
                    case 1
                        fprintf(obj.serialObject, 'setStateA');
                    case 2
                        fprintf(obj.serialObject, 'setStateB');
                    case 3
                        fprintf(obj.serialObject, 'setStateC');
                    case 4
                        fprintf(obj.serialObject, 'setStateD');
                    otherwise
                        warning("Invalid state requested");
                end
                fclose(obj.serialObject);
            catch
                error("Error sending command to impedance generator\n");
            end
        end
    end
end

