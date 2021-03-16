clear all;
% Set path to LNA measurements
calPath = "C:\Users\Mark\OneDrive - University of Calgary\Thesis\Measurements\NS_Cal\Mar 13\";
dataPath = "C:\Users\Mark\OneDrive - University of Calgary\Thesis\Measurements\Mar 13\13-Mar-2021 184027\";
nsColdFilename = "COLD.csv";
nsHotFilename = "HOT.csv";
calTemp = 299; % [K]0; % [K] ambient temperature
refTemp = 290; % [K] reference temperature

% NFA Calibration


coldDataCSV = readmatrix(strcat(calPath, nsColdFilename));
coldData.freq = coldDataCSV(1:(end-1),1);
coldData.noiseDensity = 10.^(coldDataCSV(1:(end-1),2)./10);

hotDataCSV = readmatrix(strcat(calPath, nsHotFilename));
hotData.freq = hotDataCSV(1:(end-1),1);
hotData.noiseDensity = 10.^(hotDataCSV(1:(end-1),2)./10);

% Load ENR filename
% nsENRFilename = strcat(calPath, "346C_ENRcor.ENR"); 
% nsENR = readmatrix(nsENRFilename, 'FileType', 'text');
% 
% interpolatedENR = interp1(nsENR(:,1)*1e9, nsENR(:,2), hotData.freq);
load("C:\Users\Mark\OneDrive - University of Calgary\Thesis\Measurements\CryoNoiseMeasurementSoftware\CryoNoiseMeasurementSoftware\Data\Calibration\ENR_346_dB.mat");
interpolatedENR = fittedmodel(hotData.freq);
% Extrapolate ENR data with constants
nanIndices = find(~isnan(interpolatedENR));
interpolatedENR(1:nanIndices(1)) = interpolatedENR(nanIndices(1));
interpolatedENR(nanIndices(end):end) = interpolatedENR(nanIndices(end));
interpolatedENR = 10.^(interpolatedENR/10);
hotTemp = refTemp*interpolatedENR + calTemp; % Calculate T_hot

% Compute the Gain and Noise of NFA for Calibration
kGB = (hotData.noiseDensity - coldData.noiseDensity)./(hotTemp - calTemp);
N0 = coldData.noiseDensity - kGB*calTemp;

TNFA = N0./kGB;

% Define Temperatures and Corresponding NFA Attenuators
T = [300];%[15];%[300];%[15,20,25,50,75,100];
Tact = readmatrix(strcat(dataPath, "RoomTempKelvin"));

tunerDUTS2P = sparameters(strcat(dataPath, "S2PState1.s2p"));% This is the uncalibrated s-parameters of the tuner/DUT cascade
testFreq = tunerDUTS2P.Frequencies;
thruTunerCal = sparameters(strcat(calPath, "CAL_1.s2p"));
thruTunerCal = rfinterp1(thruTunerCal, testFreq);
totalS2P = cascadesparams(tunerDUTS2P, thruTunerCal);
dutS2P = deembedsparams(totalS2P, thruTunerCal, thruTunerCal);
gammaPNAX = 0;

kGB = interp1(hotData.freq, kGB, testFreq);
N0 = interp1(hotData.freq, N0, testFreq);

for tunerState = 1:4
    tunerFilename = sprintf("CAL_%d.s2p", tunerState);
    tunerSParam = sparameters(strcat(calPath, tunerFilename));
    tunerSParam = rfinterp1(tunerSParam, testFreq);
    gammaSource = rfparam(tunerSParam, 1, 1);
    dutS21 = rfparam(dutS2P, 2, 1);
    dutS11 = rfparam(dutS2P, 1, 1);
    dutS22 = rfparam(dutS2P, 2, 2);
    dutS12 = rfparam(dutS2P, 1, 2);
    transducerGain(:,tunerState) = abs(dutS21).^2.*(1-abs(gammaSource).^2).*(1-abs(gammaPNAX).^2)./...(
    (abs((1 - dutS11 .* gammaSource).*(1 - dutS22 * gammaPNAX) - dutS12.*dutS21.*gammaSource*gammaPNAX).^2);

    noiseData = readmatrix(strcat(dataPath, sprintf("NoisePower%d.csv", tunerState)));
    noisePower = noiseData(:,2);
    noisePower = interp1(noiseData(:,1), noisePower, testFreq);
    noisePower = 10.^(noisePower/10);
    noiseTempLNA(:, tunerState) = (noisePower - N0)./(kGB.*transducerGain(:,tunerState)) - Tact(tunerState);% 
    
    noiseFactorLNA(:, tunerState) = noiseTempLNA(:,tunerState)/refTemp + 1;
    
    plot(testFreq / 1e6, noiseTempLNA(:,tunerState));
    hold on;
end

ylim([-50 100]);
% 
% temp = strcat(dut_path, file, 'Pcold00.csv');
% Nmeas_00_dB = importfile(temp,[9 2909]);
% %dNmeas_00_dB = normrnd(0,0.0031,[1,2901]);
% %Nmeas_00_dB = Nmeas_00_dB + dNmeas_00_dB';
% Nmeas_00 = movmean(10.^(Nmeas_00_dB/10),1,'omitnan');
% Nmeas_00 = Nmeas_00(1:1:end);
% 
% temp = strcat(dut_path, file, 'Pcold10.csv');
% Nmeas_01_dB = importfile(temp,[9 2909]);
% %dNmeas_01_dB = normrnd(0,0.0031,[1,2901]);
% %Nmeas_01_dB = Nmeas_01_dB + dNmeas_01_dB';
% Nmeas_01 = movmean(10.^(Nmeas_01_dB/10),1,'omitnan');
% Nmeas_01 = Nmeas_01(1:1:end);
% 
% temp = strcat(dut_path, file, 'Pcold01.csv');
% Nmeas_10_dB = importfile(temp,[9 2909]);
% %dNmeas_10_dB = normrnd(0,0.0031,[1,2901]);
% %Nmeas_10_dB = Nmeas_10_dB + dNmeas_10_dB';
% Nmeas_10 = movmean(10.^(Nmeas_10_dB/10),1,'omitnan');
% Nmeas_10 = Nmeas_10(1:1:end);
% 
% temp = strcat(dut_path, file, 'Pcold11.csv');
% Nmeas_11_dB = importfile(temp,[9 2909]);
% %dNmeas_11_dB = normrnd(0,0.0031,[1,2901]);
% %Nmeas_11_dB = Nmeas_11_dB + dNmeas_11_dB';
% Nmeas_11 = movmean(10.^(Nmeas_11_dB/10),1,'omitnan');
% Nmeas_11 = Nmeas_11(1:1:end);
% 
% % Calculate TLNA
% TLNA_00 = (Nmeas_00' - N0)./(kGB.*GT_00) - Tact(i);% 
% TLNA_00 = movmean(TLNA_00,10,'omitnan');
% 
% TLNA_01 = (Nmeas_01' - N0)./(kGB.*GT_01) - Tact(i);
% TLNA_01 = movmean(TLNA_01,10,'omitnan');
% 
% TLNA_10 = (Nmeas_10' - N0)./(kGB.*GT_10) - Tact(i);
% TLNA_10 = movmean(TLNA_10,10,'omitnan');
% 
% TLNA_11 = (Nmeas_11' - N0)./(kGB.*GT_11) - Tact(i);
% TLNA_11 = movmean(TLNA_11,10,'omitnan');
% 
% % Calculate Noise Figures
% F_LNA_00 = TLNA_00/T0 + 1; % Tuner State C
% F_LNA_01 = TLNA_01/T0 + 1; % Tuner State A
% F_LNA_10 = TLNA_10/T0 + 1; % Tuner State D
% F_LNA_11 = TLNA_11/T0 + 1; % Tuner State B
% 
% F_LNA = [F_LNA_01.', F_LNA_11.', F_LNA_00.', F_LNA_10.'];
% 
% [Fmin,Rn,Yopt] = solveNoiseParameters(F_LNA,G_term_01.',G_term_11.',G_term_00.',G_term_10.',0,Freq.',50);
% 
% N = Rn.*real(Yopt);
% 
% Freq_Noise = Freq;
% 
% Fmin = movmean(Fmin,1,'omitnan');
% Rn = movmean(Rn,1,'omitnan');
% Yopt = movmean(real(Yopt),1,'omitnan') + 1i*movmean(imag(Yopt),1,'omitnan');
% 
% sanityCheckInd = find(~((Fmin - 1) <= 4*N));
% 
% Fmin(sanityCheckInd) = NaN;  
% Rn(sanityCheckInd) = NaN;
% Yopt(sanityCheckInd) = NaN;
% 
% sanityCheckInd2 = find(~((Fmin - 1) > 0));
% 
% Fmin(sanityCheckInd2) = NaN;
% Rn(sanityCheckInd2) = NaN;
% Yopt(sanityCheckInd2) = NaN;
% 
% Gamma_opt = ((1./Yopt)-50)./((1./Yopt)+50);
% %     
% %         B = 800e3;
% %     tau = 1800;
% %     dS21_dB = 0.025;
% %     dT = 0.33;
% %     dTc = 0.33;
% %     dENR_dB = 0.05;
% %     
% %     dTh_Tc = dTc;
% %     dTh_ENR = T0*(1-10.^(dENR_dB/10));
% %     dTh = sqrt(dTh_Tc.^2+dTh_ENR.^2);
% %    
% %     dkGB_Nhot = 1./(Th-Tc).*Nhot'./sqrt(B*tau);
% %     dkGB_Ncold = -1./(Th-Tc).*Ncold'./sqrt(B*tau);
% %     dkGB_Th = -(Nhot'-Ncold')./(Th-Tc).^2*dTh;
% %     dkGB_Tc = (Nhot'-Ncold')./(Th-Tc).^2*dTc;
% %     dkGB = sqrt(dkGB_Nhot.^2+dkGB_Ncold.^2+dkGB_Th.^2+dkGB_Tc.^2);
% %     
% %     dN0_Ncold = Ncold'./sqrt(B*tau);
% %     dN0_kGB = -Tc.*dkGB;
% %     dN0_Tc = -kGB.*dTc;
% %     dN0 = sqrt(dN0_Ncold.^2+dN0_kGB.^2+dN0_Tc.^2);
% %     
% %     dTLNA_Nmeas = 1/sqrt(B*tau)*Nmeas_01'./kGB./GT_01;
% %     dTLNA_GT = 2*(Nmeas_01'-N0).*(1-10^(dS21_dB/20))./kGB./GT_01;
% %     dTLNA_T = -dT;
% %     dTLNA_N0 = -1./kGB./GT_01.*dN0;
% %     dTLNA_kGB = -(Nmeas_01'-N0)./kGB./GT_01.^2.*dkGB;
% %     dTLNA_01 = sqrt(dTLNA_Nmeas.^2+dTLNA_GT.^2+dTLNA_T.^2+dTLNA_N0.^2+dTLNA_kGB.^2);
% %     
% %     dTLNA_Nmeas = 1/sqrt(B*tau)*Nmeas_00'./kGB./GT_00;
% %     dTLNA_GT = 2*(Nmeas_00'-N0).*(1-10^(dS21_dB/20))./kGB./GT_00;
% %     dTLNA_T = -dT;
% %     dTLNA_N0 = -1./kGB./GT_00.*dN0;
% %     dTLNA_kGB = -(Nmeas_00'-N0)./kGB./GT_00.^2.*dkGB;
% %     dTLNA_00 = sqrt(dTLNA_Nmeas.^2+dTLNA_GT.^2+dTLNA_T.^2+dTLNA_N0.^2+dTLNA_kGB.^2);
% %     
% %     dTLNA_Nmeas = 1/sqrt(B*tau)*Nmeas_10'./kGB./GT_10;
% %     dTLNA_GT = 2*(Nmeas_10'-N0).*(1-10^(dS21_dB/20))./kGB./GT_10;
% %     dTLNA_T = -dT;
% %     dTLNA_N0 = -1./kGB./GT_10.*dN0;
% %     dTLNA_kGB = -(Nmeas_10'-N0)./kGB./GT_10.^2.*dkGB;
% %     dTLNA_10 = sqrt(dTLNA_Nmeas.^2+dTLNA_GT.^2+dTLNA_T.^2+dTLNA_N0.^2+dTLNA_kGB.^2);
% %     
% %     dTLNA_Nmeas = 1/sqrt(B*tau)*Nmeas_11'./kGB./GT_11;
% %     dTLNA_GT = 2*(Nmeas_11'-N0).*(1-10^(dS21_dB/20))./kGB./GT_11;
% %     dTLNA_T = -dT;
% %     dTLNA_N0 = -1./kGB./GT_11.*dN0;
% %     dTLNA_kGB = -(Nmeas_11'-N0)./kGB./GT_11.^2.*dkGB;
% %     dTLNA_11 = sqrt(dTLNA_Nmeas.^2+dTLNA_GT.^2+dTLNA_T.^2+dTLNA_N0.^2+dTLNA_kGB.^2);
% %     
% %     figure(3)
% %     smithplot(Freq_Noise,Gamma_opt);
% %     hold on
%     
%     % Plot
%     figure(1)
%     subplot(2,2,1);
%     %errorbar(Freq(1:1:end)/1e6,abs(TLNA_01(1:1:end)),dTLNA(1:1:end));
%     plot(Freq(1:1:end)/1e6,abs(TLNA_01(1:1:end)));
%     %plot(Freq/1e6,GT_01)
%     ylim([0 100]);
%     xlim([500 2000]);
%     ylabel('Noise Temperature (K)');
%     xlabel('Frequency (MHz)');
%     grid on
%     hold on
%     
%     subplot(2,2,2);
%     plot(Freq/1e6, 20*log10(abs(S21_deembed)))
%     xlim([500 2000])
%     xlabel('Frequency (MHz)')
%     ylabel('S21 (dB)')
%     grid on
%     hold on
%     
%     subplot(2,2,3);
%     plot(Freq/1e6, 20*log10(abs(S11_deembed)))
%     xlim([500 2000])
%     xlabel('Frequency (MHz)')
%     ylabel('S11 (dB)')
%     grid on
%     hold on
%     
%     subplot(2,2,4);
%     plot(Freq/1e6, 20*log10(abs(S22_deembed)))
%     xlim([500 2000])
%     xlabel('Frequency (MHz)')
%     ylabel('S22 (dB)')
%     grid on
%     hold on
%     
% %     % Plot
% %     figure(2)
% %     subplot(2,2,1);
% %     plot(Freq_Noise/1e6,abs(290*(Fmin-1)));
% %     %plot(Freq/1e6,GT_01)
% %     ylim([0 50]);
% %     xlim([500 2000]);
% %     ylabel('Minimum Noise Temperature (K)');
% %     xlabel('Frequency (MHz)');
% %     grid on
% %     hold on
% %     
% %     subplot(2,2,2);
% %     plot(Freq_Noise/1e6, abs(Rn))
% %     ylim([0 5]);
% %     xlim([500 2000])
% %     xlabel('Frequency (MHz)')
% %     ylabel('Noise Resistance (\Omega)')
% %     grid on
% %     hold on
% %     
% %     subplot(2,2,3);
% %     plot(Freq_Noise/1e6, 20*log10(abs(Gamma_opt)))
% %     xlim([500 2000])
% %     xlabel('Frequency (MHz)')
% %     ylabel('Magnitude of \Gamma_{opt} (dB)')
% %     grid on
% %     hold on
% %     
% %     subplot(2,2,4);
% %     plot(Freq_Noise/1e6, 180/pi*phase(Gamma_opt))
% %     xlim([500 2000])
% %     xlabel('Frequency (MHz)')
% %     ylabel('Phase of \Gamma_{opt} (degrees)')
% %     grid on
% %     hold on
% 
% 
% legendEntries = strtrim(cellstr(num2str(T'))');
% legend(legendEntries)