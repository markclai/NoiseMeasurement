%% Connect to Lab instruments
pnax = PNAX('', 0);
tuner = ImpGen(2);
dmm = DMM('', 0);
pnaxCalFile = "";
sw.handle = actxcontrol('USBTUNERX.USBTUNERXCtrl.1');
sw.handle.PulseBit(sw.in_vna);

pnax.setup(100e6, 2e9, 50, 50, pnaxCalFile);
%% Run measurement

for tunerState = 1:4
    tuner.setState(tunerState);
    tempKelvin(tunerState) = dmm.readTempKelvin();
    pnax.saveS2P(sprintf("S2PState%d.csv", tunerState);
    sw.handle.PulseBit(sw.in_vna);
    pnax.saveNoisePower(sprintf("NoisePower%d.csv", tunerState);
    sw.handle.PulseBit(sw.in_vna);
end







