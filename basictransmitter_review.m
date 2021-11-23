% **********************************************************
% Modulation

params;

% Create i.i.d. bits
bits = (randn(LL,1) > 0.5);

% BPSK mapping to symbols
xk = (2*bits-1)*sqrt(Ex);

% Choose sinc pulse
pt = sinc([-floor(Ns/2):Ns-floor(Ns/2)-1]/fs); pt = transpose(pt)/norm(pt)/sqrt(1/(fs)); % '1/fs' simply serves as 'delta' to approximate integral as sum
lenpt = length(pt);

% Create baseband signal
xk = [fsync_preamble; xk];
xk_up = upsample(xk,fs);
xt = conv(xk_up,pt);
lenxt = length(xt);

display(max(abs(xt)));

% **********************************************************
% Waveforms and spectra

% Plot time domain signals
ax = [];
figure(1)
LargeFigure(gcf, 0.15); % Make figure large
clf

subplot(3,1,1);
plot([-floor(Ns/2):Ns-floor(Ns/2)-1]/fsamp,pt)
ylabel('p(t)')
axis tight

ax(1) = subplot(3,1,2);
plot([0:lenxt-1]/fsamp,real(xt),'b')
hold on
plot([0:lenxt-1]/fsamp,imag(xt),'r')
axis('tight')
legend('I','Q')
ylabel('x(t)')
xlabel('t in microseconds')
zoom xon


% Plot frequency domain signals
figure(2)
LargeFigure(gcf, 0.15); % Make figure large
clf

subplot(3,1,1)
plot([-lenpt/2+1:lenpt/2]/lenpt*fsamp,20*log10(abs(fftshift(1/sqrt(lenpt)*fft(pt)))))
ylabel('abs(P(f))')
axis([-30 30 -100 20])
title('Frequency responses in dB')

subplot(3,1,2)
plot([-lenxt/2+1:lenxt/2]/lenxt*fsamp,20*log10(abs(fftshift(1/sqrt(lenxt)*fft(xt)))))
xlabel('f in MHz')
ylabel('abs(X(f))')
axis([-30 30 -100 20])
figure(1)


% **********************************************************
% Save transmitsignal
transmitsignal = xt;
save transmitsignal transmitsignal

disp('transmitsignal was generated and saved as mat file.')
disp('Transmit the transmitsignal and then copy receivedsignal into this directory. Press ENTER to continue after that is done.')
pause
disp('Continuing!')


% **********************************************************
% Load received signal
load receivedsignal
yt = receivedsignal;
lenyt = length(yt);


% **********************************************************
% Plot time domain signal received signal
figure(1)
ax(2) = subplot(3,1,3);
plot([0:lenyt-1]/fsamp,real(yt),'b')
hold on
plot([0:lenyt-1]/fsamp,imag(yt),'r')
legend('I','Q')
ylabel('y(t)')
axis('tight')
xlabel('t in microseconds')
linkaxes(ax,'x')
zoom xon


% Plot frequency domain signal received signal
figure(2)
subplot(3,1,3)
plot([-lenyt/2+1:lenyt/2]/lenyt*fsamp,20*log10(abs(fftshift(1/sqrt(lenyt)*fft(yt)))))
xlabel('f in MHz')
ylabel('abs(Y(f))')
axis([-30 30 -100 20])

figure(1)