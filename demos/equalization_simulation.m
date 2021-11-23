% Practical MMSE-LE Equalizer
% LMS algorithm used to calculate Practical MMSE-LE equalizer

clear
clc
close all
rng('default')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters
Ex = 1; % Symbol energy
SNR_mfb_dB = 20; % SNR_MFB in dB. Try 20 
num_symbols = 400; % Total number of symbols transmitted.  Try 400
Trainlen = 50; % Length of equalizer pilot sequence in symbols. Try 50. The higher the SNR_eq desired and the more the number of filter taps, the longer the pilot sequence needed
pilotsymbolindex = 20; % First pilot symbol in transmitted xk sequence
mmse_len = 5; % Number of taps in Practical MMSE-LE filter. Try 5
gamma = 0.05; % Step-size normalization constant of LMS algorithm. Try 0.01.  
num_train_epochs = 21; % Run over the same pilot sequence repeatedly this many times, to use the pilot more comprehensively
mu_scaling = 0.98; % Reduce the mu by this factor each epoch
le_delay =  2; % To allow noncausal Practical MMSE-LE filter design, let filter predict a **past** symbol


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulated channel 
hh= [1.2, 0.6*exp(j*2*pi/3), 0.3*exp(j*pi/5), 0.2*exp(j*pi/2)];  % Channel impulse response

SNR_mfb = 10^(SNR_mfb_dB/10); % SNR_MFB as a ratio
sigma_n = sqrt(norm(hh)^2*Ex/SNR_mfb); 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modulation and Channel operation
bits = (rand(2*num_symbols,1) > 0.5);
xx = sqrt(Ex/2)*((2*bits(1:2:end)-1)+j*(2*bits(2:2:end)-1)); % 4-QAM modulation
zz = [conv(xx,hh); zeros(le_delay+1,1)];
zz = zz+sigma_n/sqrt(2)*(randn(size(zz))+j*randn(size(zz))); % Channel with ISI and noise
constellation = unique(xx); % Assuming there are lots of symbols


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Practical MMSE-LE (FIR-filter)

ww = zeros(mmse_len,1); % Initialize LMS algorithm
% Training phase of LMS algorithm for Practical MMSE-LE
mu = gamma/mean(abs(zz(1:Trainlen)).^2); % Normalized step-size, normalized by filter input energy
for mm=1:num_train_epochs
    for (ii=pilotsymbolindex:pilotsymbolindex+Trainlen-1)
       zz_past = zz(ii+le_delay:-1:ii+le_delay-mmse_len+1);
       vv(ii,1) = transpose(ww)*zz_past; % LE Filter output
       ee(ii,1) = vv(ii) - xx(ii); % ek = vk - xk
       ww = ww - mu*ee(ii,1)*conj(zz_past); % Adapt filter. Use normalized stepsize
    end
    mu = mu*mu_scaling; % Change the mu for next epoch
end

% Data phase for Practical MMSE-LE
for (ii=pilotsymbolindex+Trainlen:num_symbols)
   zz_past = zz(ii+le_delay:-1:ii+le_delay-mmse_len+1); 
   vv(ii) = transpose(ww)*zz_past; % Output of Practical MMSE-LE filter
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate SNR_MMSELE assuming actual data phase symbols (so, unbiased estimate
% of SNR) for the equalized AWGN channel
sigma_tilden_square = mean(abs(vv(pilotsymbolindex+Trainlen:num_symbols) - xx(pilotsymbolindex+Trainlen:num_symbols)).^2);
SNR_MMSELE = Ex/sigma_tilden_square;
disptxt1 = ['SNR-MFB = ', num2str(SNR_mfb_dB) ' dB'];
disp(disptxt1)
disptxt2 = ['SNR-MMSELE = ', num2str(10*log10(SNR_MMSELE)) ' dB'];
disp(disptxt2)


% Plot Signal space in equalized as well as unequalized signal
figure(1)
LargeFigure(gcf, 0.15); % Make figure large
clf
subplot(1,2,1)
plot(real(zz(pilotsymbolindex+Trainlen:num_symbols)),imag(zz(pilotsymbolindex+Trainlen:num_symbols)),'o') % Received samples
hold on
plot(real(constellation),imag(constellation),'rs','MarkerFaceColor','r') % Constellation
xlabel('$I$')
ylabel('$Q$')
title('zk')
text(0.2, 0.9, disptxt1, 'Units', 'Normalized', 'fontsize', 16)
axis([-4*sqrt(Ex) 4*sqrt(Ex) -4*sqrt(Ex) 4*sqrt(Ex)])
subplot(1,2,2)
plot(real(vv(pilotsymbolindex+Trainlen:num_symbols)),imag(vv(pilotsymbolindex+Trainlen:num_symbols)),'o') % Equalized samples
hold on
plot(real(constellation),imag(constellation),'rs','MarkerFaceColor','r') % Constellation
xlabel('$I$')
ylabel('$Q$')
title('vk')
text(0.2, 0.9, disptxt2, 'Units', 'Normalized', 'fontsize', 16)
axis([-4*sqrt(Ex) 4*sqrt(Ex) -4*sqrt(Ex) 4*sqrt(Ex)])
sgtitle('Signal spaces')




