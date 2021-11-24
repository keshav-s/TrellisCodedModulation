%% Load parameters and signals
params;

transmitsignal = load('transmitsignal.mat');
receivedsignal = load('receivedsignal.mat');
xt = transmitsignal.transmitsignal;
yt = receivedsignal.receivedsignal;
lenyt = length(yt);

%% Recover bits
% Filter with matched filter
wt = flipud(pt); 
zt = conv(wt,yt)*(1/fs); % '1/fs' simply serves as 'delta' to approximate integral as sum 
lenzt = length(zt);

% timing offset + rotation
[tau, theta] = timing_sync(zt);
timing_yt = yt(tau+1:fs:end);

% Sample pilots and equalize
if use_one_tap
    % Sample signal AFTER timing preamble
    zk = zt(tau+length(timingSignal)+1:fs:end);
    zk = zk(1:LL-freqT-timingT+1);
    [vk, zk_full_eq] = one_tap_equalize(zk);
else
    % Sample signal starting at timing preamble
    zk = zt(tau+1:fs:end);
    zk = zk(1:end-freqT+1);
    vk = mmse_le(zk);
end

%% Plot Original and Recovered Images
% Final recovered bits and image
bits_hat = qamdemod(vk, M, 'OutputType','bit');
fprintf('BER: %f\n', sum(bits_hat~=bits)/length(bits));
fprintf('Number of Incorrect Bits: %d\n', sum(bits_hat ~= bits))


subplot(1,2,1)
imshow(imread(img_path));
title('Original Image')
subplot(1,2,2);
im_hat = reshape(bits_hat, h, w);
imshow(im_hat);
title('Recovered Image')

%% Plot Signals
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