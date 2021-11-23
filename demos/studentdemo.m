% Demonstrates basic transmission and reception using USRP
%
% Place the included transmitsignal.mat file into your USRP user folder via SFTP.
% Once the receivedsignal.mat file is received, transfer it to your current
% Matlab folder.
% Then, run this program to display the transmit and received signals.

clc
disp(' ')

IsOffline = true; % true if no upload/download. false if upload/download being tested

% Received file name
if IsOffline
    received_filename = 'receivedsignalEXAMPLE.mat'; % Offline example
else
    received_filename = 'receivedsignal.mat'; % Choose as 'receivedsignal.mat' in your project code with actual upload/download
end

% Transmit signal
a = load('transmitsignal.mat'); % The variable transmitsignal is the transmit signal
transmitsignal = a.transmitsignal;
% Received signal
if exist(received_filename,'file')
    load(received_filename);
else
    disp(['Error! Did not find ' received_filename ' file.'])
    return
end

if ~exist('receivedsignal','var')
    disp('Error! Loaded file does not contain the receivedsignal variable.')
    return;
end


% Display signals
figure(1)
clf
subplot(2,1,1)
plot(real(transmitsignal),'b')
hold on
plot(imag(transmitsignal),'r')
legend('real','imag')
ylabel('xI(t)  and  xQ(t)')
xlabel('Time in samples')
subplot(2,1,2)
plot(real(receivedsignal),'b')
hold on
plot(imag(receivedsignal),'r')
zoom xon
legend('real','imag')
ylabel('yI(t)  and  yQ(t)')
xlabel('Time in samples')

figure(2)
clf
subplot(2,1,1)
plot([0:length(transmitsignal)-1]/length(transmitsignal)-0.5, abs(fftshift(fft(transmitsignal))))
ylabel('abs(X(f))')
xlabel('Frequency in 1/samples')
subplot(2,1,2)
plot([0:length(receivedsignal)-1]/length(receivedsignal)-0.5, abs(fftshift(fft(receivedsignal))))
ylabel('abs(Y(f))')
xlabel('Frequency in 1/samples')

figure(1)

% Display information
disp('Notice the following:')
disp(' ')
disp('1) The transmit signal is badly chosen here. Make a better choice in your project')
disp(' ')
disp('2) The USRP returns a  received signal whose length is larger than the transmit signal.')
disp('This is because it does not know exactly where your signal is placed in the received stream.')
disp('However, if you look carefully, your will notice that the actual signal present in the received stream')
disp('   is smaller in length than the transmit signal. (Why?)')
disp(' ')
disp('3) The received signal is delayed (with an unknown delay) w.r.t. transmit signal.')
disp('You need to do frame synchronization to discover the delay in the received signal.')
disp(' ')
disp('4) There is initially a large frequency offset  in the received signal,')
disp('and then it settles into a small frequency offset.')
disp('You could discard the initial packet to handle the large frequency offset.') 
disp('You can do carrier recovery and/or time-varying channel estimation/equalization to handle the small offset.')
disp(' ')
disp('5) The sampling instants for symbol-rate sampling are not obvious.')
disp('So, you need to do timing recovery.')
disp(' ')
disp('Ideally, timing recovery and carrier recovery need analog signals.')
disp('Fortunately, our radio server returns the received signal at a significantly high sampling rate,')
disp('so that we can treat it as an analog signal.')
disp('Due to Nyquist theorem, you can always upsample it to an even higher sampling rate.')
disp(' ')
disp('6) The received signal is quite noisy.')
disp('So, a filter is recommended.')
disp(' ')



