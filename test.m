clear all;
%% Test DMM
% dmm = DMM(22, 7);
% dmm.setupTempKelvin(20);
% for i = 1:10
%     temp{i} = dmm.readTempKelvin();
%     fprintf("The temperature is now %s Kelvin\n", temp{i});
%     pause(2);
% end
% dmm.checkStatusAndDisconnect();
%% Test switches
% sw.handle = actxcontrol('USBTUNERX.USBTUNERXCtrl.1');
% sw.handle.PulseBit(sw.in_vna);
%% Test Tuner
% tuner = ImpGen(5);
% for i = 1:4
%     tuner.setState(i);
%     pause(2);
% end
% 
% %Should fail here:
% disp("Should fail here");
% tuner.setState(5);

%% Test DC Supply
 dcSupply = DCPower(1,7);
%  dcSupply.setVoltage(1, 6);
%  dcSupply.setCurrent(1, 0.1);
%  dcSupply.enableOutput(1);
% pause(50);
% dcSupply.disableOutput(1);
% dcSupply.checkStatusAndDisconnect();
%% Test switch code
switchID(1) = dcSupply.addSwitchSetup(2, 3, 12, 12);
pause(5);
dcSupply.setSwitchState(switchID(1), 2);
pause(5);
dcSupply.setSwitchState(switchID(1), 1);
dcSupply.checkStatusAndDisconnect();

%% Test Tuner
impGen = ImpGen(5);
impGen.setState(1);

%% Test PNA-X
pnax = PNAX("USB0::0x0957::0x0118::MY48420967::0::INSTR");
pnax.setup(100e6,2e9,201,128, "ML_CAL_MAR_13", "HIGH", -55);
pnax.saveS2P("test1.s2p");
%pnax.saveNoisePower("test1.csv");
pnax.checkErrors();
pnax.checkStatusAndDisconnect();