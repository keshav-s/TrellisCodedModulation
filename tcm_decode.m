function [survive_path, bits_hat] = tcm_decode(vk, zp_by)
t = poly2trellis([1 4],[1 0 0; 0 13 5]);
% hDemod = comm.PSKTCMDemodulator(t,'ModulationOrder',8, ...
%     'TerminationMethod','Truncated');
% bits_hat1 = step(hDemod, vk);

k = 2;
n = 3;
numRegs = 4;
numStates = 2^(numRegs-1);
numPossibleInputs = 2^k;
symbs = exp(2*pi*i*[0 4 2 6 1 5 3 7]/8);

% Create state transitions table and outputs table
% nextStates and outputs should be same as what is created by poly2trellis
nextStates = zeros(numStates, numPossibleInputs);
outputs = zeros(numStates, numPossibleInputs);
opSymbs = zeros(numStates, numPossibleInputs);
output = zeros(n,1);
for ss = 0:numStates-1
    state = int2bit(ss, numRegs-1);
    for ii = 0:numPossibleInputs-1
        ip = int2bit(ii, k);
        
        output(3) = mod(ip(1), 2);
        output(2) = mod(ip(2) + state(2) + state(3), 2);
        output(1) = mod(state(1) + state(3), 2);
        opVal = bin2dec(num2str(output.'));
        outputs(ss+1, ii+1) = opVal;
        opSymbs(ss+1, ii+1) = symbs(opVal+1);

        nextState = [ip(2); state(1:end-1)];
        nextStates(ss+1, ii+1) = bit2int(nextState, size(state,1));
    end
end

% Find the minimum path
vlen = length(vk);
pathMetrics = zeros(numStates, vlen+1) + inf;
pathMetrics(1,1) = 0;
prevState = zeros(numStates, vlen+1);
prevIn = zeros(numStates, vlen+1);
for vv = 1:vlen
    symb = vk(vv)/abs(vk(vv));

    for ip = 0:numPossibleInputs-1
        idealInputs = outputs(:, ip+1);
        idealSymbs = opSymbs(:, ip+1);
        ip2nextState = nextStates(:, ip+1);

        branchMetrics = (abs(idealSymbs - symb)).^2;
        newMetrics = pathMetrics(:, vv) + branchMetrics;

        for state = 0:numStates-1
            nextState = ip2nextState(state+1);

            if newMetrics(state+1) < pathMetrics(nextState+1, vv+1) 
                pathMetrics(nextState+1, vv+1) = newMetrics(state+1);
                prevState(nextState+1, vv+1) = state;
                prevIn(nextState+1, vv+1) = ip;
            end
        end
    end
end

% Due to zero-padding, we know the final state is 0
% Thus, we track minimum path from the 0 state to recover message
state = 0;
bits_hat = zeros(vlen*k, 1);
survive_path = [];
for vv = vlen:-1:1
    ip = prevIn(state+1, vv+1);
    
    bits_hat((vv-1)*k + 1 : vv*k) = int2bit(ip, k);
    state = prevState(state+1, vv+1);
    survive_path = [state; survive_path];
end
bits_hat = bits_hat(1:vlen*k - zp_by);
end