function bits_hat = tcm_decode(vk)
t = poly2trellis([1, 4],[1 0 0; 0 13 5]);
hDemod = comm.PSKTCMDemodulator(t,'ModulationOrder',8, ...
    'TerminationMethod','Truncated');
bits_hat = step(hDemod, vk);
end