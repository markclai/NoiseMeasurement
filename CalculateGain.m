clear all;
k = 1.38064852e-23;
noiseBW = 800e3;
tCold = 297;
nsColdFilename = "C:\Users\mlai4\OneDrive - University of Calgary\Thesis\Measurements\NS_Cal\New Cal\NS-OFF.csv";
nsHotFilename = "C:\Users\mlai4\OneDrive - University of Calgary\Thesis\Measurements\NS_Cal\New Cal\NS_ON.csv";
nsENRFilename = "C:\Users\mlai4\OneDrive - University of Calgary\Thesis\Measurements\Leo Custom ENR Tables\346C_ENRcor.ENR";
coldDataCSV = readmatrix(nsColdFilename);
coldData.freq = coldDataCSV(:,1);
coldData.noiseDensity = coldDataCSV(:,2);
hotDataCSV = readmatrix(nsHotFilename);
hotData.freq = hotDataCSV(:,1);
hotData.noiseDensity = hotDataCSV(:,2);
nsENR = readmatrix(nsENRFilename, 'FileType', 'text');

interpolatedENR = interp1(nsENR(:,1)*1e9, nsENR(:,2), hotData.freq);

hotNoiseDensityLinear = 10.^(hotData.noiseDensity/10)/1000 * noiseBW;
coldNoiseDensityLinear = 10.^(coldData.noiseDensity/10)/1000 * noiseBW;
gain = (hotNoiseDensityLinear - coldNoiseDensityLinear)./(k*tCold*(10.^(interpolatedENR/10)-1))/ noiseBW;

gaindB = 10*log10(gain);

plot(hotData.freq/1e6, gaindB);
figure;
plot(hotData.freq/1e6, hotData.noiseDensity);
hold on;
plot(coldData.freq/1e6, coldData.noiseDensity);