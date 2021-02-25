clear all;
%% Test DMM
% dmm = DMM(22, 7);
% dmm.setup();
% for i = 1:10
%     temp{i} = dmm.readTempKelvin();
%     fprintf("The temperature is now %s Kelvin\n", temp{i});
%     pause(10);
% end
%% Test switches
% sw.handle = actxcontrol('USBTUNERX.USBTUNERXCtrl.1');
% sw.handle.PulseBit(sw.in_vna);
%% Test Tuner
tuner = ImpGen(5);
for i = 1:4
    tuner.setState(i);
    pause(2);
end

%Should fail here:
disp("Should fail here");
tuner.setState(5);