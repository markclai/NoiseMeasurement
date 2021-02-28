classdef DCPower < GPIBObj
    %DCPOWER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        switchChannel1
        switchChannel2    
    end
    
    methods
        function obj = DCPower(gpibAddr,gpibBoard)
            %DCPOWER Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@GPIBObj(gpibAddr, gpibBoard);
            %Reset DMM
            disp("Resetting PSU");
            resetArray(1) = "*RST;";
            resetArray(2) = "*CLS;";
            obj.sendCommand(resetArray, length(resetArray));
            
            for channelCounter = 1:4
                obj.disableOutput(channelCounter);
            end
            
        end
        
        function  setVoltage(obj, channel, voltage)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            if(channel < 0 || channel > 4)
                warning("Invalid channel requested");
                return;
            end
            command = sprintf("VSET %d, %d", channel, voltage);
            obj.sendCommand(command, length(command));
        end
        
        function setCurrent(obj, channel, current)
            if(channel < 0 || channel > 4)
                warning("Invalid channel requested");
                return;
            end
            command = sprintf("ISET %d, %d", channel, current);
            obj.sendCommand(command, length(command));
        end
        
        function enableOutput(obj, channel)
            if(channel < 0 || channel > 4)
                warning("Invalid channel requested");
                return;
            end
            command = sprintf("OUT %d, 1", channel);
            obj.sendCommand(command, length(command));
        end
        
        function disableOutput(obj, channel)
            if(channel < 0 || channel > 4)
                warning("Invalid channel requested");
                return;
            end
            
            command = sprintf("OUT %d, 0", channel);
            obj.sendCommand(command, length(command));
        end
        
        
    end
end

