% Matched filter
params;

transmitsignal = load('transmitsignal.mat');
receivedsignal = load('receivedsignal.mat');
xt = transmitsignal.transmitsignal;
yt = receivedsignal.receivedsignal;
lenyt = length(yt);

wt = flipud(pt); 

% Filter with matched filter
zt = conv(wt,yt)*(1/fs); % '1/fs' simply serves as 'delta' to approximate integral as sum 
lenzt = length(zt);

% timing offset + rotation
[corrs,lags] = xcorr(zt,timingSignal); % pilot upsampled
[~,I] = max(abs(corrs));
theta = angle(corrs(I));
tau = lags(I);

timing_yt = yt(tau+1:fs:end);

% Sample signal after timing preamble
zk = zt(tau+length(timingSignal)+1:fs:end);
zk = zk(1:LL-freqT-timingT+1);

% Sample pilots and equalize
pilotSignal = conv(pilotUp,pt,'same');
pk = pilotSignal(1:fs:end);
zk_full_eq = [];
vk = [];
for i=1:num_packets
    if length(zk(packetLen*(i-1)+1:end)) > packetLen
        zk_packet = zk(packetLen*(i-1)+1:packetLen*i);
    else
        zk_packet = zk(packetLen*(i-1)+1:end-1);
    end

    pk_hat = zk_packet(1:pilotT);
    zk_message = zk_packet(pilotT+1:end);
    eq = (pk_hat.' * pk)/ (pk' * pk);
    zk_full_eq = [zk_full_eq; zk_packet/eq];
    vk = [vk; zk_message/eq];
end

% **********************************************************
% Final recovered bits and image
xk_hat = sign(real(vk));
bits_hat = (xk_hat>=0);
fprintf('BER: %f\n', sum(bits_hat~=bits)/length(bits));
fprintf('Number of Incorrect Bits: %d\n', sum(bits_hat ~= bits))


subplot(1,2,1)
imshow(imread('./images/shannon1440.bmp'));
title('Original Image')
subplot(1,2,2);
im_hat = reshape(bits_hat, h, w);
imshow(im_hat);
title('Recovered Image')

% **********************************************************
% Plot time domain signals
figure('Name', 'Receiver Time Signals');
clf

subplot(4,1,1)
lenyt = length(yt);
plot([-lenyt/2+1:lenyt/2]/lenyt*fsamp,real(yt),'b')
hold on
plot([-lenyt/2+1:lenyt/2]/lenyt*fsamp,imag(yt),'r')
zoom xon
legend('real','imag')
title('yI(t)  and  yQ(t)')
xlabel('Time in samples')

subplot(4,1,2)
lentyt = length(timing_yt);
plot([-lentyt/2+1:lentyt/2]/lentyt*fsamp,real(timing_yt),'b')
hold on
plot([-lentyt/2+1:lentyt/2]/lentyt*fsamp,imag(timing_yt),'r')
zoom xon
legend('real','imag')
title('yI(t)  and  yQ(t) after finding the timing offset')
xlabel('Time in samples')

subplot(4,1,3)
plot(real(zk),'b')
hold on
plot(imag(zk),'r')
zoom xon
legend('real','imag')
title('zI_k  and  zQ_k')
xlabel('Samples')

subplot(4,1,4)
plot(real(vk),'b')
hold on
plot(imag(vk),'r')
zoom xon
legend('real','imag')
title('vI_k  and  vQ_k')
xlabel('Samples')

% Plot frequency domain signals
figure('Name', 'Received Signal Spectra')
title('Frequency responses in dB')
subplot(2,1,1);
plot([-lenyt/2+1:lenyt/2]/lenyt*fsamp,20*log10(abs(fftshift(1/sqrt(lenyt)*fft(yt)))))
xlabel('f in MHz')
title('abs(Y(f))')
axis([-30 30 -100 20])

subplot(2,1,2);
plot([-lenzt/2+1:lenzt/2]/lenzt*fsamp,20*log10(abs(fftshift(1/sqrt(lenzt)*fft(zt)))))
xlabel('f in MHz')
title('abs(Z(f)), where z(t) is p(-t)*y(t)')
axis([-30 30 -100 20])

% Plot constellation
scatterplot(vk);