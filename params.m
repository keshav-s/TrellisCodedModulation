% Symbol period T=1us

% Create bits
rng(0);

bits = imread('images/shannon1440.bmp');
[h,w] = size(bits);
bits = bits(:);

% Message and System Parameters
rolloff = 0.2;    % Rolloff factor for SRRCR pulse
freqT = 400;      % Number of symbol periods in the frequency preamble
timingT = 100;    % Number of symbol periods in the timing preamble
pilotT = 50;      % Number of symbol periods in pilot sequence
packetT = 200;    % Number of symbol periods in message between pilot inserts 
fsamp = 200;      % Sampling frequency in MHz.  DON'T CHANGE
B = 2;            % Bits per symbol
M = 2^B;          % Symbol order
N = 51;           % Length of filter in symbol periods. Default is 51
packetLen = packetT + pilotT;
num_packets = 1+floor(length(bits)/packetT);
LL = freqT + timingT + num_packets*pilotT + length(bits); % Total number of bits

fs = 20;          % Over-sampling factor (Sampling frequency/symbol rate). Choose 20, so that 
                  % symbol rate = sampling frequency/50 = 200/50 = 4 MHz.
                  % fs is also the number of samples that make up one symbol period
Ex = 0.25;        % Symbol energy.
T = 1/(fsamp/fs); % Sampling period in microseconds
Ns = floor(N*fs); % Number of filter samples

% Choose SRRCR pulse
pt = rcosdesign(rolloff, N, fs);
pt = transpose(pt)/sqrt(1/(fs)); 
lenpt = length(pt);

% Frequency Preamble and Parameters
freqBits = ones(freqT,1)*sqrt(Ex);
freqUp = upsample(freqBits, fs);

% Timing Preamble and Parameters
timingBits = (rand(timingT, 1)) > 0.5;
timingSymbs = encode_bits(timingBits, B)*sqrt(Ex);
% timingSymbs = (2*timingBits - 1)*sqrt(Ex);
timingUp = upsample(timingSymbs, fs);
timingSignal = conv(timingUp,pt,'same');

% Pilot (USE BPSK MODULATION)
pilotBits = (randn(pilotT, 1)) > 0.5;
pilotSymbs = (2*pilotBits - 1)*sqrt(Ex);
pilotUp = upsample(pilotSymbs, fs);