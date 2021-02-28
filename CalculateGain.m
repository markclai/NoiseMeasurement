clear all;
k = 1.38064852e-23;
tCold = 297;
nsColdFilename = "C:\Users\Mark\OneDrive - University of Calgary\Thesis\Measurements\NS_Cal\NS-OFF.csv";
nsHotFilename = "C:\Users\Mark\OneDrive - University of Calgary\Thesis\Measurements\NS_Cal\NS_ON.csv";
nsENRFilename = "C:\Users\Mark\OneDrive - University of Calgary\Thesis\Measurements\NS_Cal\SNS_ENR.csv";
coldDataCSV = readmatrix(nsColdFilename);
coldData.freq = coldDataCSV(:,1);
coldData.noiseDensity = coldDataCSV(:,5);
hotDataCSV = readmatrix(nsHotFilename);
hotData.freq = hotDataCSV(:,1);
hotData.noiseDensity = hotDataCSV(:,5);
nsENR = readmatrix(nsENRFilename);

interpolatedENR = interp1(nsENR(:,1)*1e6, nsENR(:,2), hotData.freq);

hotNoiseDensityLinear = 10.^(hotData.noiseDensity/10)/1000;
coldNoiseDensityLinear = 10.^(coldData.noiseDensity/10)/1000;
gain = (hotNoiseDensityLinear - coldNoiseDensityLinear)./(k*tCold*(10.^(interpolatedENR/10)-1));

gaindB = 10*log10(gain);

plot(hotData.freq/1e6, gaindB);
figure;
plot(hotData.freq/1e6, hotData.noiseDensity);
hold on;
plot(coldData.freq/1e6, coldData.noiseDensity);