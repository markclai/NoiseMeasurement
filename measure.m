pnaxAddress = "USB0::0x0957::0x0118::MY48420967::0::INSTR";
dmmAddress = 22;
dcSupplyAddress = 1;
impGenComPort = 5;
gpibBoard = 7;
freqStart = 100e6;
freqStop = 2e9;
nPoints = 50;
nAvg = 1;
noiseBW = 800e3;
noiseGain = "HIGH";
pnaxCalSetName = "ML_Cal_Mar3";
pnaxPortPower = -55;
dmmIntTime = 100;
dcVoltage = 6;
dcCurrent = 100e-3;
dutPowerChannel = 1;
rfSwitch.channel1 = 2;
rfSwitch.channel2 = 3;
rfSwitch.voltage1 = 12;
rfSwitch.voltage2 = 12;
%% Make directory
folderName = string(datetime('now'));
folderName = erase(folderName, ":");
mkdir(folderName);

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
    pause(5);
    pnax.saveS2P(sprintf("./%s/S2PState%d.s2p", folderName, tunerState));
    dcSupply.setSwitchState(switchID, 2);
    pause(5);
    pnax.saveNoisePower(sprintf("./%s/NoisePower%d.csv", folderName, tunerState));
    tempKelvin(tunerState) = dmm.readTempKelvin();
end

%% Disable DC outputs
for chanCounter = 1:4
    dcSupply.disableOutput(chanCounter);
end
%% Disconnect all lab instruments
pnax.checkStatusAndDisconnect();
dmm.checkStatusAndDisconnect();
dcSupply.checkStatusAndDisconnect();

% Write tempertaure to csv file
csvwrite(sprintf("%s/RoomTempKelvin.csv", folderName), tempKelvin);






