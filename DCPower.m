classdef DCPower < GPIBObj & handle
    %DCPOWER Controls Agilent 6626A Power Supply
    %   Also includes code to control RF switches
    
    properties
        switches
    end
    
    methods
        function obj = DCPower(gpibAddr,gpibBoard)
            %DCPOWER Construct an instance of this class
            %   Pass in GPIB Address and GPIB Board address, also resets
            %   the DC Supply and disables outputs.
            obj = obj@GPIBObj(gpibAddr, gpibBoard);
            %Reset DMM
            disp("Resetting PSU");
            resetArray(1) = "*RST;";
            resetArray(2) = "*CLS;";
            obj.sendCommand(resetArray, length(resetArray));
            
            for channelCounter = 1:4
                obj.disableOutput(channelCounter);
            end
            
            obj.switches(1).state = -1;
            obj.switches(1).chanCtrl1 = 0;
            obj.switches(1).chanCtrl2 = 0;
            obj.switches(1).chanVolt1 = 0;
            obj.switches(1).chanVolt2 = 0;
            
        end
        
        function switchID = addSwitchSetup(obj, chan1, chan2, volt1, volt2)
            switchID = length(obj.switches) + 1;
            obj.switches(switchID).chanCtrl1 = chan1;
            obj.switches(switchID).chanCtrl2 = chan2;
            obj.switches(switchID).chanVolt1 = volt1;
            obj.switches(switchID).chanVolt2 = volt2;
            
            %Initialize power supply output
            obj.setVoltage(chan1, 0);
            obj.setVoltage(chan2, 0);
            obj.enableOutput(chan1);
            obj.enableOutput(chan2);
            %Set voltage so switch is set to state 1
            obj.switches(switchID).state = 1;
            obj.setSwitchState(switchID, 1);
            
        end
        
        function switchState = getSwitchState(obj, switchID)
            if(switchID > length(obj.switches) || obj.switches(switchID).state == -1)
                warning("Invalid switch requested");
                return;
            end
            switchState = obj.switches(switchID).state;
        end
        
            
        function setSwitchState(obj, switchID, state)
            if(switchID > length(obj.switches) || obj.switches(switchID).state == -1)
                warning("Invalid switch requested");
                return;
            end
            
            switch state
                case 1
                    obj.setVoltage(obj.switches(switchID).chanCtrl1, 0);
                    pause(2);
                    obj.setVoltage(obj.switches(switchID).chanCtrl1, obj.switches(switchID).chanVolt1);
                    pause(2);
                    obj.setVoltage(obj.switches(switchID).chanCtrl1, 0);
                    obj.switches(switchID).state = state;
                case 2
                    obj.setVoltage(obj.switches(switchID).chanCtrl2, 0);
                    pause(2);
                    obj.setVoltage(obj.switches(switchID).chanCtrl2, obj.switches(switchID).chanVolt2);
                    pause(2);
                    obj.setVoltage(obj.switches(switchID).chanCtrl2, 0);   
                    obj.switches(switchID).state = state;
                otherwise
                    warning("Invalid state requested");
            end
            
        end
        function deleteSwitch(obj, switchID)
            if(switchID > length(obj.switches) || obj.switches(switchID).state == -1)
                warning("Invalid switch requested");
                return;
            end
            
            obj.disableOutput(obj.switches(switchID).chanCtrl1);
            obj.disableOutput(obj.switches(switchID).chanCtrl2);
            
            obj.switches(switchID).state = -1;
        end
            
            
        function  setVoltage(obj, channel, voltage)
            %setVoltage Summary of this method goes here
            %   Sets voltage of a particular channel. 
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

