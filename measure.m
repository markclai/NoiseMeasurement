pnaxAddress = 0;
dmmAddress = 0;
dcSupplyAddress = 0;
impGenComPort = 0;
gpibBoard = 0;
freqStart = 100e6;
freqStop = 2e9;
nPoints = 50;
nAvg = 10;
noiseBW = 800e3;
noiseGain = "MED";
pnaxCalSetName = "ML_Cal_Mar3";
pnaxPortPower = -55;
dmmIntTime = 100;
dcVoltage = 56;
dcCurrent = 100e-3;
dutPowerChannel = 1;
rfSwitch.channel1 = 2;
rfSwitch.channel2 = 3;
rfSwitch.voltage1 = 12;
rfSwitch.voltage2 = 12;
%% Connect to Lab instruments
pnax = PNAX(pnaxAddress);
dmm = DMM(dmmAddress, gpibBoard);
dcSupply = DCPower(dcSupplyAddress, gpibBoard);
tuner = ImpGen(impGenComPort);

%% Setup Lab Instruments
pnax.setup(freqStart, freqStop, nPoints, nAvg, pnaxCalSetName, noiseGain, pnaxPortPower);
dmm.setupTempKelvin(dmmIntTime);
dcSupply.setVoltage(dutPowerChannel, dcVoltage);
dcSupply.setCurrent(dutPowerChannel, dcCurrent);
dcSupply.enableOutput(dutPowerChannel);
switchID = dcSupply.addSwitchSetup(rfSwitch.channel1, rfSwitch.channel2, rfSwitch.voltage1, rfSwitch.voltage2);
%% Run measurement

for tunerState = 1:4
    dcSupply.setSwitchState(switchID, 1);
    tuner.setState(tunerState);
    
    pnax.saveS2P(sprintf("S2PState%d.csv", tunerState));
    dcSupply.setSwitchState(switchID, 2);
    pnax.saveNoisePower(sprintf("NoisePower%d.csv", tunerState));
    tempKelvin(tunerState) = dmm.readTempKelvin();
end

% Write tempertaure to csv file
writematrix(tempKelvin, "RoomTempKelvin");






