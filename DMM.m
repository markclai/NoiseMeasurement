classdef DMM < GPIBObj
    %DMM Summary of this class goes here
    %   Detailed explanation goes here

    
    methods
        function obj = DMM(gpibAddr,gpibBoard)
            %DMM Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@GPIBObj(gpibAddr, gpibBoard);
            %Reset DMM
            disp("Resetting DMM");
            resetArray(1) = "*RST;";
            resetArray(2) = "*CLS;";
            obj.sendCommand(resetArray, length(resetArray));
        end
        
        function setup(obj)
            setupSequence(1) = "CONF:TEMP THER,5000";
            setupSequence(2) = "UNIT:TEMP K";
            %setupSequence(3) = "TEMP:NPLC %d";
            obj.sendCommand(setupSequence, length(setupSequence));
        end
        function tempKelvin = readTempKelvin(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            tempKelvin = obj.sendQuery("READ?"); 
        end
    end
end

