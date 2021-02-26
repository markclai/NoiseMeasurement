classdef PNAX < GPIBObj
    properties
        fStart
        fStop
        nPoints
        nAvg
    end
    
    methods
        function obj = PNAX(visaAddr)
            
            obj = obj@GPIBObj(visaAddr);
            %Reset PNA-X
            disp("Resetting PNA-X");
            obj.sendCommand('SYST:FPR', 1);
        end
        
        function setup(fstart, fstop, numpoints, numavg, calFile)
            obj.fStart = fstart;
            obj.fStop = fstop;
            obj.nPoints = numpoints;
            obj.nAvg = numavg;
            disp("Setting up PNA-X");
            % Set format of S2P file
            temp(1) = sprintf('MMEM:STOR:TRAC:FORM:SNP MA'); 

                %Load Calibration file
            temp(2) = sprintf('MMEM:LOAD:CSAR "%s"', calFile); 

            %Set trigger to manual
            temp(3) = sprintf('TRIG:SOUR MAN'); 
            temp(4) = sprintf('TRIG:SCOP ALL'); 

            %Change channel one frequency range
            temp(5) = sprintf('SENS1:FREQ:STAR %f', obj.fStart); 
            temp(6) = sprintf('SENS1:FREQ:STOP %f', obj.fStop); 
            temp(7) = sprintf('SENS1:SWE:POIN %d', obj.nPoints); 

            % Set up s parameter settings
            temp(8) = sprintf('SENS1:AVER:COUN %d', obj.nAvg); 
            temp(9) = sprintf('SENS1:AVER:MODE SWEEP');
            temp(10) = sprintf('SENS1:AVER:STAT 1'); 

            %Change channel two frequency range
            temp(11) = sprintf('SENS2:FREQ:STAR %f', obj.fStart); 
            temp(12) = sprintf('SENS2:FREQ:STOP %f', obj.fStop); 
            temp(13) = sprintf('SENS2:SWE:POIN %d', obj.nPoints); 

            temp(14) = sprintf('SENS2:NOIS:BWID 800e3'); 
            temp(15) = sprintf('SENS2:NOIS:GAIN 30'); 
            temp(16) = sprintf('SENS2:NOIS:AVER %d', obj.nAvg);
            
            % Set up s parameter settings
            temp(17) = sprintf('SENS2:AVER:COUN %d', obj.nAvg); 
            temp(18) = sprintf('SENS2:AVER:MODE SWEEP'); 
            temp(19) = sprintf('SENS2:AVER:STAT 1'); 
            
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
        end
    end
end
            
        