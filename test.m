clear all;
%%Test DMM
dmm = DMM(22, 7);
dmm.setup();
for i = 1:10
    temp{i} = dmm.readTempKelvin();
    fprintf("The temperature is now %s Kelvin\n", temp{i});
    pause(10);
end
