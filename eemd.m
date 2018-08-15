% 1-D Ensemble Empirical Mode Decomposition (EEMD)
% Source: Z. Wu and N. E. Huang, "Ensemble Empirical Mode Decomposition:
% A Noise Assisted Data Analysis Method."
% Defines the true IMF components as the mean of an ensemble of trials,
% each consisting of the signal plus a white noise of finite amplitude.
% -------------------------------------------------------------------------
% Using Matlab EMD Toolbox 2018
% -------------------------------------------------------------------------
% Aug 15, 2018
% Pragya Sharma
% ps847@cornell.edu

%% ------------------------------------------------------------------------
function [imfEns,imf] = eemd(x,fs,stdNoiseRel,nEns,maxNumImf,dispOn)
%% EEMD()
% x = Input data, should be a column vector. 
% fs = sampling frequency
% nEns = Number of Ensemble, should be sufficiently large
% stdNoise = Standard deviation of nornal noise, controls noise amplitude
% maxNumImf = Maximum number of IMFs generated for input data x
% dispOn = '0' == OFF, '1' == Plot imfEns, '2' == Plot both imfEns, imf.

%% ------------------------------------------------------------------------
[sz,dim] = size(x); % Length of data

if dim ~= 1
    fprintf('The input data should be a column vector, code stopping...');
    return
end

t = (0:sz-1)/fs;

%% ------------------------------------------------------------------------
imfs = zeros(maxNumImf,sz);
stdNoise = stdNoiseRel*std(x);

%% ------------------------------------------------------------------------
% Calculating IMF Ensemble
for i = 1:nEns
    wn = randn(sz,1)*stdNoise; % White noise - psd is uniform
    xNoisy = x + wn;
    [imfNoisy,~] = emd(xNoisy,'MaxNumIMF',maxNumImf,'Display',0);
    if size(imfNoisy,2) ~= maxNumImf
        fprintf(['The imf size is less than specified max number, try',...
            'decreasing the maxNumImf. \n']);
        return
    end
    imfs = imfs + imfNoisy';
end

imfEns = imfs/nEns;

%% ------------------------------------------------------------------------
% Calculating IMF without Ensemble for comparison
[imf,~] = emd(x,'MaxNumIMF',maxNumImf,'Display',0);
imf = imf';

%% ------------------------------------------------------------------------
% Plot IMF from with and without ensemble for comparison
if dispOn
    nMaxSubplot = 4;
    nPlot = ceil(maxNumImf/nMaxSubplot);
    nImf = 0;
    
    for i = 1:nPlot
        figure('Units', 'pixels','Position', [100 100 650 600]);
        for j = 1:nMaxSubplot
            nImf = nImf + 1;
            if nImf <= maxNumImf
               ax1(nImf) = subplot(nMaxSubplot,1,j);
               plot(ax1(nImf),t,imfEns(nImf,:));
               if dispOn == 2
                   hold on
                   plot(ax1(nImf),t,imf(nImf,:));
               end
               if (j == nMaxSubplot) || (nImf == maxNumImf)
                   if dispOn < 2
                       plotCute1('Time (s)',['IMF',num2str(nImf)],ax1(nImf),[],[],0);  
                   else
                       plotCute1('Time (s)',['IMF',num2str(nImf)],ax1(nImf),[],...
                           {'EEMD','EMD'},1);  
                   end
               else
                   plotCute1([],['IMF',num2str(nImf)],ax1(nImf),[],[],0);                       
               end
            end
        end
    end
    
    figure
    ax1(nMaxSubplot+1) = gca;
    plot(t,x)
    linkaxes(ax1,'x')
end
    