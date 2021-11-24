% Symbol period T=1us

% Create bits
rng(0);

img_path = 'images/shannon1440.bmp';
bits = imread(img_path);
[h,w] = size(bits);
bits = bits(:);
one_tap = 0;

% Message and System Parameters
B = 2;            % Bits per symbol
M = 2^B;          % Symbol order
rolloff = 0.2;    % Rolloff factor for SRRCR pulse
freqT = 200;      % Number of symbol periods in the frequency preamble
timingT = 100;    % Number of symbol periods in the timing preamble
pilotT = 50;      % Number of symbol periods in pilot sequence
packetT = 400;    % Number of symbol periods in message between pilot inserts 
fsamp = 200;      % Sampling frequency in MHz.  DON'T CHANGE
N = 51;           % Length of filter in symbol periods. Default is 51
packetLen = packetT + pilotT;
messageLen = length(bits)/B;
num_packets = 1+floor(messageLen/packetT);
LL = freqT + timingT + num_packets*pilotT + messageLen; % Total number of symbols

fs = 16;          % Over-sampling factor (Sampling frequency/symbol rate). Choose 20, so that 
                  % symbol rate = sampling frequency/20 = 200/20 = 10 MHz.
                  % fs is also the number of samples that make up one symbol period
Ex = 0.25;        % Symbol energy.
T = 1/(fsamp/fs); % Sampling period in microseconds
Ns = floor(N*fs); % Number of filter samples

% MMSE LE Parameters
mmse_len = 10; % Number of taps in Practical MMSE-LE filter. Try 5
gammaMMSE = 0.01; % Step-size normalization constant of LMS algorithm. Try 0.01.  
num_train_epochs = 41; % Run over the same pilot sequence repeatedly this many times, to use the pilot more comprehensively
mu_scaling = 0.98; % Reduce the mu by this factor each epoch
le_delay =  2; % To allow noncausal Practical MMSE-LE filter design, let filter predict a **past** symbol


% Choose SRRCR pulse
pt = rcosdesign(rolloff, N, fs);
pt = transpose(pt)/sqrt(1/(fs)); 
lenpt = length(pt);

% Frequency Preamble and Parameters
freqBits = ones(freqT,1)*sqrt(Ex);
freqUp = upsample(freqBits, fs);

% Timing Preamble and Parameters
timingBits = (rand(timingT, 1)) > 0.5;
timingSymbs = encode_bits(timingBits, 1)*sqrt(Ex);
% timingSymbs = (2*timingBits - 1)*sqrt(Ex);
timingUp = upsample(timingSymbs, fs);
timingSignal = conv(timingUp,pt,'same');

% Pilot (USE BPSK MODULATION)
pilotBits = (randn(pilotT, 1)) > 0.5;
pilotSymbs = encode_bits(pilotBits, 1)*sqrt(Ex);
pilotUp = upsample(pilotSymbs, fs);