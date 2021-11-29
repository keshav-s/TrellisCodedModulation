% Symbol period T=1us

% Create bits
rng(0);

img_path = ['images/shannon8208.bmp'];
bits = imread(img_path);
[h,w] = size(bits);
bits = bits(:);
use_one_tap = 0;
coded = 1;

% Message and System Parameters
pilotT = 73;
if coded
    B = 3;
    M = 2^B;
    packetT = 228;
    messageLen = length(bits)/2;
else
    B = 4;            % Bits per symbol
    M = 2^B;          % Symbol order
    packetT = 270;
end
packetLen = packetT + pilotT;
rolloff = 0.2;    % Rolloff factor for SRRCR pulse
freqT = 400;      % Number of symbol periods in the frequency preamble
timingT = 100;    % Number of symbol periods in the timing preamble
fsamp = 200;      % Sampling frequency in MHz.  DON'T CHANGE
N = 50;           % Length of filter in symbol periods. Default is 51

pilotT = 73;
packetT = 270;
packetLen = packetT + pilotT;
if mod(messageLen,packetT) > 0
    num_packets = 1+floor(messageLen/packetT);
else
    num_packets = floor(messageLen/packetT);
end
LL = freqT + timingT + num_packets*pilotT + messageLen; % Total number of symbols

% MMSE Parameters
w_len = 7; % Number of taps in Practical MMSE-LE filter. Try 5
b_len  = 5;
gamma_f = 0.08; % Step-size normalization constant of LMS algorithm. Try 0.01.  
gamma_b = 0.08; % Step-size normalization constant of LMS algorithm. Try 0.01.  
num_train_epochs = 10; % Run over the same pilot sequence repeatedly this many times, 
mu_scaling = 0.98; % Reduce the mu by this factor each epoch
f_delay =  3; % let filter predict a **past** symbol for practical feedforward adaptive filtering


fs = 11;          % Over-sampling factor (Sampling frequency/symbol rate). Choose 20, so that 
                  % symbol rate = sampling frequency/fs = 200/14 = 10 MHz.
                  % fs is also the number of samples that make up one symbol period
T = 1/(fsamp/fs); % Sampling period in microseconds
Ns = floor(N*fs); % Number of filter samples

% Choose SRRCR pulse
pt = rcosdesign(rolloff, N, fs);
pt = transpose(pt)/sqrt(1/(fs)); 
lenpt = length(pt);

% Frequency Preamble and Parameters
freqBits = ones(freqT,1);
freqUp = upsample(freqBits, fs);

% Timing Preamble and Parameters
timingBits = (rand(timingT*B, 1)) > 0.5;
timingSymbs = bits2symbs(timingBits, coded, B);
% timingSymbs = (2*timingBits - 1)*sqrt(Ex);
timingUp = upsample(timingSymbs, fs);
timingSignal = conv(timingUp,pt,'same');

% Pilot
pilotBits = (randn(pilotT*B, 1)) > 0.5;
pilotSymbs = bits2symbs(pilotBits, coded, B);
pilotUp = upsample(pilotSymbs, fs);