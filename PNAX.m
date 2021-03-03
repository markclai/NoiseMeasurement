classdef PNAX < GPIBObj
    properties
        fStart
        fStop
        nPoints
        nAvg
        storedS2PFiles
        storedCSVFiles
        noiseGain
    end
    
    methods
        function obj = PNAX(visaAddr)
            
            obj = obj@GPIBObj(visaAddr);
            %Reset PNA-X
            disp("Resetting PNA-X");
            obj.sendCommand("SYST:FPR", 1);
        end
        
        function setup(obj, fstart, fstop, numpoints, numavg, calFile, noiseGain)
            obj.fStart = fstart;
            obj.fStop = fstop;
            obj.nPoints = numpoints;
            obj.nAvg = numavg;
            disp("Setting up PNA-X");
            % Set format of S2P file
            tempArrayCounter = 1;
            temp(tempArrayCounter) = "MMEM:STOR:TRAC:FORM:SNP MA"; 
            tempArrayCounter = tempArrayCounter + 1;

            %Load Calibration file
            temp(tempArrayCounter) = convertCharsToStrings(sprintf('MMEM:LOAD:CSAR "%s"', calFile));
            tempArrayCounter = tempArrayCounter + 1;
            %Set trigger to manual
            temp(tempArrayCounter) = sprintf("TRIG:SOUR MAN");
            tempArrayCounter = tempArrayCounter + 1;
            temp(tempArrayCounter)  = sprintf("TRIG:SCOP ALL"); 
            tempArrayCounter = tempArrayCounter + 1;

            %Change channel one frequency range
            temp(tempArrayCounter)  = sprintf("SENS1:FREQ:STAR %f", obj.fStart); 
            tempArrayCounter = tempArrayCounter + 1;
            temp(tempArrayCounter)  = sprintf("SENS1:FREQ:STOP %f", obj.fStop);
            tempArrayCounter = tempArrayCounter + 1;
            temp(tempArrayCounter)  = sprintf("SENS1:SWE:POIN %d", obj.nPoints); 
            tempArrayCounter = tempArrayCounter + 1;
            % Set up s parameter settings
            temp(tempArrayCounter)  = sprintf("SENS1:AVER:COUN %d", obj.nAvg);
            tempArrayCounter = tempArrayCounter + 1;
            temp(tempArrayCounter)  = sprintf("SENS1:AVER:MODE SWEEP");
            tempArrayCounter = tempArrayCounter + 1;
            temp(tempArrayCounter)  = sprintf("SENS1:AVER:STAT 1"); 
            tempArrayCounter = tempArrayCounter + 1;

            %Change channel two frequency range
            
            temp(tempArrayCounter) = convertCharsToStrings('CALC2:CUST:DEF "sysnpd", "Noise Figure Cold Source", "SYSNPD"');
            tempArrayCounter = tempArrayCounter + 1;      
            temp(tempArrayCounter)  = sprintf("SENS2:FREQ:STAR %f", obj.fStart); 
            tempArrayCounter = tempArrayCounter + 1;
            temp(tempArrayCounter)  = sprintf("SENS2:FREQ:STOP %f", obj.fStop); 
            tempArrayCounter = tempArrayCounter + 1;
            temp(tempArrayCounter)  = sprintf("SENS2:SWE:POIN %d", obj.nPoints); 
            tempArrayCounter = tempArrayCounter + 1;

            temp(tempArrayCounter) = sprintf("SENS2:NOIS:BWID 800e3"); 
            tempArrayCounter = tempArrayCounter + 1;

            temp(tempArrayCounter) = sprintf("SENS2:NOIS:AVER %d", obj.nAvg);
            tempArrayCounter = tempArrayCounter + 1;
            
            % Set up s parameter settings
            temp(tempArrayCounter) = sprintf("SENS2:AVER:COUN %d", obj.nAvg); 
            tempArrayCounter = tempArrayCounter + 1;
            temp(tempArrayCounter) = sprintf("SENS2:AVER:MODE SWEEP"); 
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
            obj.sendCommand(temp, length(temp));
        end
            
        function saveS2P(obj, s2pFilename)    
            % reset averaging
            
            obj.sendCommand('SENS1:AVER:CLE', 1);
            
            % Start the measurement and wait until it is complete
            for i=1:obj.nAvg
                status = obj.sendQuery('INIT:IMM;*OPC?'); 
                status = obj.sendQuery('DISP:WIND1:Y:AUTO;*OPC?'); 
       
                pause(1);
            end
            
            % Save S2P file with noise parameters
            %temp = sprintf('CALC1:DATA:SNP:PORTs:Save "3,4","%s";*OPC?', filename); status = query(NetworkAnalyzer,temp);

            temp = obj.sendQuery('DISP:WIND1:TRAC2:SEL;*OPC?'); 
            temp = obj.sendQuery('MMEM:STOR "%s";*OPC?', s2pFilename); 

            temp = obj.sendQuery('DISP:WIND2:TRAC2:SEL;*OPC?');
            temp = obj.sendQuery('MMEM:STOR:DATA "%s","CSV Formatted Data","Channel","Displayed",5;*OPC?', noiseFilename); 
            obj.storedS2PFiles{end+1} = s2pFilename;
        end
        
        function saveNoisePower(obj, noiseFilename)
            obj.sendCommand('SENS2:AVER:CLE', 1);
            for avgCount = 1:obj.nAvg
                status = obj.sendQuery('INIT:IMM;*OPC?'); 
                status = obj.sendQuery('DISP:WIND2:Y:AUTO;*OPC?');
                pause(1);
            end
            temp = obj.sendQuery('DISP:WIND2:TRAC2:SEL;*OPC?');
            temp = obj.sendQuery('MMEM:STOR:DATA "%s","CSV Formatted Data","Channel","Displayed",5;*OPC?', noiseFilename); 
            obj.storedCSVFiles{end+1} = noiseFilename;
        end
        
        function transferData(obj, prefix, pcFilepath)
            %Copy S2P Files
            for s2pCounter = 1:length(obj.storedS2PFiles)
                temp = strcat(prefix, obj.storedS2PFiles{s2pCounter}); temp = strcat('MMEM:TRAN? "',temp,'"');
                data = obj.sendQuery(temp);
                temp = strcat(pcFilepath, obj.storedS2PFiles{s2pCounter});
                writematrix(temp,data,'');
            end
            
            for csvCounter = 1:length(obj.storedCSVFiles)
                temp = strcat(prefix, obj.storedS2PFiles{csvCounter}); temp = strcat('MMEM:TRAN? "',temp,'"');
                data = query(PNAX,temp);
                temp = strcat(pcFilepath, obj.storedS2PFiles{csvCounter});
                writematrix(temp,data,'');
            end
        end
        
            
    end
end
            
        