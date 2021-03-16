classdef PNAX < GPIBObj
    properties
        fStart
        fStop
        nPoints
        nAvg
        noiseGain
    end
    
    methods
        function obj = PNAX(visaAddr)
            
            obj = obj@GPIBObj(visaAddr);
            %Reset PNA-X
            disp("Resetting PNA-X");
            obj.sendCommand("SYST:FPR", 1);
        end
        
        function setup(obj, fstart, fstop, numpoints, numavg, calSet, noiseGain, portPower)
            obj.fStart = fstart;
            obj.fStop = fstop;
            obj.nPoints = numpoints;
            obj.nAvg = numavg;
            disp("Setting up PNA-X");
            % Set format of S2P file
            tempArrayCounter = 1;
            % Delete existing channel traces
            temp(tempArrayCounter)  = sprintf("CALC:PAR:DEL:ALL"); 
            tempArrayCounter = tempArrayCounter + 1;
            
%             temp(tempArrayCounter) = "MMEM:STOR:TRAC:FORM:SNP MA"; 
%             tempArrayCounter = tempArrayCounter + 1;

          
                      
            %Setup channel 1 for S parameters
            temp(tempArrayCounter)  = convertCharsToStrings('CALC1:PAR:DEF:EXT "SParamMeasS11", S11');
            tempArrayCounter = tempArrayCounter + 1;
            temp(tempArrayCounter)  = convertCharsToStrings('CALC1:PAR:DEF:EXT "SParamMeasS12", S12');
            tempArrayCounter = tempArrayCounter + 1;
            temp(tempArrayCounter)  = convertCharsToStrings('CALC1:PAR:DEF:EXT "SParamMeasS21", S21');
            tempArrayCounter = tempArrayCounter + 1;
            temp(tempArrayCounter)  = convertCharsToStrings('CALC1:PAR:DEF:EXT "SParamMeasS22", S22');
            tempArrayCounter = tempArrayCounter + 1;
            
            %Associate measurements to window 1
            temp(tempArrayCounter)  = "DISP:WIND1:STATE ON";
            tempArrayCounter = tempArrayCounter + 1;
            temp(tempArrayCounter)  = convertCharsToStrings('DISPlay:WINDow1:TRACe1:FEED "SParamMeasS11"');
            tempArrayCounter = tempArrayCounter + 1;
            temp(tempArrayCounter)  = convertCharsToStrings('DISPlay:WINDow1:TRACe2:FEED "SParamMeasS12"');
            tempArrayCounter = tempArrayCounter + 1;
            temp(tempArrayCounter)  = convertCharsToStrings('DISPlay:WINDow1:TRACe3:FEED "SParamMeasS21"');
            tempArrayCounter = tempArrayCounter + 1;
            temp(tempArrayCounter)  = convertCharsToStrings('DISPlay:WINDow1:TRACe4:FEED "SParamMeasS22"');
            tempArrayCounter = tempArrayCounter + 1;
            % Setup window for S parameters
            temp(tempArrayCounter)  = "DISPlay:WINDow1:TITLe:STATe ON";
            tempArrayCounter = tempArrayCounter + 1;
            temp(tempArrayCounter)  = "DISPlay:ANNotation:FREQuency ON";
            tempArrayCounter = tempArrayCounter + 1;
            temp(tempArrayCounter)  = "DISPlay:WINDow1:TRACe1:STATe ON";
            tempArrayCounter = tempArrayCounter + 1;
            temp(tempArrayCounter)  = "DISPlay:WINDow1:TRACe2:STATe ON";
            tempArrayCounter = tempArrayCounter + 1;
            temp(tempArrayCounter)  = "DISPlay:WINDow1:TRACe3:STATe ON";
            tempArrayCounter = tempArrayCounter + 1;
            temp(tempArrayCounter)  = "DISPlay:WINDow1:TRACe4:STATe ON";
            tempArrayCounter = tempArrayCounter + 1;
            
            %Change channel one frequency range
            temp(tempArrayCounter)  = sprintf("SENS1:FREQ:STAR %f", obj.fStart); 
            tempArrayCounter = tempArrayCounter + 1;
            temp(tempArrayCounter)  = sprintf("SENS1:FREQ:STOP %f", obj.fStop);
            tempArrayCounter = tempArrayCounter + 1;
            temp(tempArrayCounter)  = sprintf("SENS1:SWE:POIN %d", obj.nPoints); 
            tempArrayCounter = tempArrayCounter + 1;
            % Load Calibration file
            temp(tempArrayCounter) = sprintf("SENS1:CORR:CSET:ACT '%s',1", calSet);
            tempArrayCounter = tempArrayCounter + 1;
            % Set up s parameter settings
            temp(tempArrayCounter)  = sprintf("SENS1:AVER:COUN %d", obj.nAvg);
            tempArrayCounter = tempArrayCounter + 1;
            temp(tempArrayCounter)  = sprintf("SENS1:AVER:MODE POIN");
            tempArrayCounter = tempArrayCounter + 1;
            temp(tempArrayCounter)  = sprintf("SENS1:AVER:STAT 1"); 
            tempArrayCounter = tempArrayCounter + 1;
                    
            % Set channel 1 stimulus to desired power
            temp(tempArrayCounter) = sprintf("SOUR:POW1 %d", portPower);
            tempArrayCounter = tempArrayCounter + 1;
            
            % Set sweep mode to HOLD for channel 1
            temp(tempArrayCounter) = "SENS1:Sweep:Mode HOLD";
            tempArrayCounter = tempArrayCounter + 1;

            %Change channel two frequency range
            
            temp(tempArrayCounter) = convertCharsToStrings('CALC2:CUST:DEF "sysnpd", "Noise Figure Cold Source", "SYSNPD"');
            tempArrayCounter = tempArrayCounter + 1;    
            %Attach measurement to window
            
            temp(tempArrayCounter)  = "DISP:WIND2:STATE ON";
            tempArrayCounter = tempArrayCounter + 1;
            temp(tempArrayCounter)  = convertCharsToStrings('DISPlay:WINDow2:TRACe1:FEED "sysnpd"');
            tempArrayCounter = tempArrayCounter + 1;
            % Annotate window measurements
            temp(tempArrayCounter)  = "DISPlay:WINDow2:TITLe:STATe ON";
            tempArrayCounter = tempArrayCounter + 1;
            temp(tempArrayCounter)  = "DISPlay:WINDow2:TRACe1:STATe ON";
            tempArrayCounter = tempArrayCounter + 1;

            % Setup stop/start freq
            temp(tempArrayCounter)  = sprintf("SENS2:FREQ:STAR %f", obj.fStart); 
            tempArrayCounter = tempArrayCounter + 1;
            temp(tempArrayCounter)  = sprintf("SENS2:FREQ:STOP %f", obj.fStop); 
            tempArrayCounter = tempArrayCounter + 1;
            temp(tempArrayCounter)  = sprintf("SENS2:SWE:POIN %d", obj.nPoints); 
            tempArrayCounter = tempArrayCounter + 1;
            temp(tempArrayCounter)  = sprintf("SENS2:AVER:COUN %d", obj.nAvg); 
            tempArrayCounter = tempArrayCounter + 1;
            temp(tempArrayCounter)  = "SENS2:AVER ON"; 
            tempArrayCounter = tempArrayCounter + 1;

            temp(tempArrayCounter) = sprintf("SENS2:NOIS:BWID 800e3"); 
            tempArrayCounter = tempArrayCounter + 1;
            
            temp(tempArrayCounter) = "SENS2:NOIS:AVER:STAT 1";
            tempArrayCounter = tempArrayCounter + 1;

            temp(tempArrayCounter) = sprintf("SENS2:NOIS:AVER %d", obj.nAvg);
            tempArrayCounter = tempArrayCounter + 1;
            
          
            
            %Set trigger to manual
            temp(tempArrayCounter) = sprintf("TRIG:SOUR MAN");
            tempArrayCounter = tempArrayCounter + 1;
            temp(tempArrayCounter)  = sprintf("TRIG:SCOP CURR"); 
            tempArrayCounter = tempArrayCounter + 1;
            
            % Set up s parameter settings
            temp(tempArrayCounter) = sprintf("SENS2:AVER:COUN %d", obj.nAvg); 
            tempArrayCounter = tempArrayCounter + 1;
            temp(tempArrayCounter) = sprintf("SENS2:AVER:MODE POIN"); 
            tempArrayCounter = tempArrayCounter + 1;
            temp(tempArrayCounter) = sprintf("SENS2:AVER:STAT 1"); 
            tempArrayCounter = tempArrayCounter + 1;
            % set up noise receiver gain
            switch noiseGain
                case "LOW"
                    temp(tempArrayCounter) = sprintf("SENS2:NOIS:GAIN 0"); 
                    obj.noiseGain = 0;
                case "MED"
                    temp(tempArrayCounter) = sprintf("SENS2:NOIS:GAIN 15"); 
                    obj.noiseGain = 15;
                case "HIGH"
                    temp(tempArrayCounter) = sprintf("SENS2:NOIS:GAIN 30"); 
                    obj.noiseGain = 30;
                otherwise 
                    warning("Invalid noise gain requested");
            end
            % Set sweep mode to HOLD for channel 1
            temp(tempArrayCounter) = "SENS2:Sweep:Mode HOLD";
            tempArrayCounter = tempArrayCounter + 1;
            obj.sendCommand(temp, length(temp));
            % Wait for commands to process
            obj.sendQuery("*OPC?");
        end
            
        function saveS2P(obj, s2pFilename)    
            % reset averaging
            
            obj.sendCommand("SENS1:AVER:CLE", 1);
            
            
            obj.sendQuery("*OPC?");
            
            % Clear status register
            obj.sendCommand("*CLS", 1);
            
            obj.sendQuery("*OPC?");
                       
            % Start the measurement and wait until it is complete
            obj.sendCommand("INIT1:IMM", 1);
            obj.sendCommand("*OPC", 1);
            
            % Wait until operation is complete
            esrBit = 0;
            while(~bitand(esrBit, 1))
                esrBit = str2num(obj.sendQuery("*ESR?"));
                pause(5);
                disp("Still waiting")
                disp(esrBit);
            end
            
            obj.sendQuery("*OPC?");
            % Autoscale display
            obj.sendCommand("DISP:WIND1:Y:AUTO", 1);
            
            [data, numPoints] = obj.saveData("SNP");
            freqRange = data(:,1);
            
            % Convert retrieved magnitude info from dB
            sparamMag = data(:,2:2:8);

            % Convert retrieved phase info from degrees to radians
            sparamPhase = data(:,3:2:9)*(pi/180);
            
            
            % Extract S-Parameter vectors
            rawDataRI = sparamMag.*(cos(sparamPhase)+1i*sin(sparamPhase));
            S11 = reshape(rawDataRI(:,1),1,1,numPoints);
            S12 = reshape(rawDataRI(:,3),1,1,numPoints);
            S21 = reshape(rawDataRI(:,2),1,1,numPoints);
            S22 = reshape(rawDataRI(:,4),1,1,numPoints);

            % Assemble into a 3D matrix to be consumed by the RF Toolbox
            SParameter3Ddata = [S11 S12; S21 S22]; 
            
            rfwrite(SParameter3Ddata, freqRange, s2pFilename);
            
            
        end
        
        
        function saveNoisePower(obj, noiseFilename)
            obj.sendCommand("SENS2:AVER:CLE", 1);
            
            obj.sendCommand("CALC2:PAR:SEL 'sysnpd'", 1);
            % Clear status register
            obj.sendCommand("*CLS", 1);
            % Start the measurement and wait until it is complete
            obj.sendCommand("INIT2:IMM", 1);
            % Wait until operation is complete
            obj.sendCommand("*OPC", 1); % Sets the status register to 1 once complete
            esrBit = 0;
            while(~(bitand(esrBit, 1)))
                pause(5);
                disp("Still waiting");
                esrBit = str2num(obj.sendQuery("*ESR?"));
                disp(esrBit);
            end
            
            % Autoscale display
            obj.sendCommand("DISP:WIND2:Y:AUTO", 1);
            
            [data, ~] = obj.saveData("Noise");
            data = array2table(data, 'VariableNames', {'Freq', 'SYSNPD'});
            writetable(data, noiseFilename);
        end
        
        function [data, numPoints] = saveData(obj, type)
            %Set format to transfer data
            obj.sendCommand("FORM REAL,64", 1);
            
            %Set byte order
            
            obj.sendCommand("FORM:BORD SWAP", 1);
            
            switch type
                case "SNP" 
                    % Request measurement data
                    obj.sendCommand(convertCharsToStrings('CALC1:DATA:SNP:PORT? "1,2"'), 1);
                    data = binblockread(obj.gpibObj, 'double');
                    fread(obj.gpibObj, 1);
                    %Reshape measurement data to array
                    numPoints = str2double(obj.sendQuery("SENS1:SWE:POIN?"));
                    data = reshape(data, numPoints, 9);
                case "Noise"
                    % Request measurement data
                    obj.sendCommand("CALC2:DATA? FDATA", 1);
                    data = binblockread(obj.gpibObj, 'double');
                    fread(obj.gpibObj, 1);
                    obj.sendCommand("CALC2:X?", 1);
                    freqArray = binblockread(obj.gpibObj, 'double');
                    fread(obj.gpibObj, 1);
                    numPoints = str2double(obj.sendQuery("SENS2:SWE:POIN?"));
                    data = [freqArray, data];
                otherwise
                    warning("Invalid measurement requested");
            
            end
        end
            
    end
end
            
        