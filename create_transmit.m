% **********************************************************
% Modulation
params;

% BPSK mapping to symbols
if coded
    xk_symbs = tcm_encode(bits);
else
    xk_symbs = bits2symbs(bits, coded, B);
end
% Create baseband signal with pilots inserted every packetT symbols

extra = mod(length(xk_symbs),packetT);
xk_ps = xk_symbs(1:end-extra);
xk_ps = reshape(xk_ps.', packetT, []);
pilots = repmat(pilotSymbs, 1, size(xk_ps, 2));
xk_ps = cat(1, xk_ps, pilots);
xk_ps = xk_ps(:);
if extra > 0
    xk_symbs = [xk_ps; xk_symbs(end-extra+1:end)];
else
    xk_symbs = xk_ps(1:end-pilotT);
end

xk_up = upsample(xk_symbs, fs);
full_xk_up = [freqUp; timingUp; pilotUp; xk_up];
xt = conv(full_xk_up,pt);
xt_raw = conv(upsample(bits2symbs(bits, 'QAM', B), fs), pt, 'same');
xt = xt/(max(abs(xt)));
lenxt = length(xt);

%% **********************************************************
% Waveforms and spectra

% Plot time domain signals
ax = [];
figure('Name', 'Sent Time Signals')
LargeFigure(gcf, 0.15); % Make figure large
clf

subplot(3,1,1);
plot([-floor(Ns/2):Ns-floor(Ns/2)]/fsamp,pt)
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

ax(1) = subplot(3,1,3);
xt_sampled = xt_raw(1:fs:end);
plot(0:length(xt_sampled)-1, real(xt_sampled), 'b')
hold on
plot(0:length(xt_sampled)-1, imag(xt_sampled), 'r')
axis('tight')
legend('I','Q')
ylabel('Sampled x(t) without preambles and pilots')
zoom xon
hold off

% Plot frequency domain signals
figure('Name', 'Transmitter Spectral Signals')
LargeFigure(gcf, 0.15); % Make figure large
clf

subplot(2,1,1)
plot([-lenpt/2+1:lenpt/2]/lenpt*fsamp,20*log10(abs(fftshift(1/sqrt(lenpt)*fft(pt)))))
xlabel('f in MHz')
title('abs(P(f))')
axis([-30 30 -100 20])

subplot(2,1,2)
plot([-lenxt/2+1:lenxt/2]/lenxt*fsamp,20*log10(abs(fftshift(1/sqrt(lenxt)*fft(xt)))))
xlabel('f in MHz')
title('abs(X(f))')
axis([-30 30 -100 20])
figure(1)

%% **********************************************************
% Save transmitsignal
transmitsignal = xt;
save transmitsignal transmitsignal

disp('transmitsignal was generated and saved as mat file.')