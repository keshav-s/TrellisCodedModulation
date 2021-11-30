function xk_symbs = tcm_encode(bits, zp_by)
% To ensure the last state reached in the trellis is the 0 state, zero fill
zp_bits = [bits; zeros(zp_by,1)];

% t = poly2trellis([1, 4],[1 0 0; 0 13 5]);
% hMod = comm.PSKTCMModulator(t,'ModulationOrder',8);
% coded = step(hMod,zp_bits);

b = reshape(zp_bits, 2, []).';
regs = zeros(4,1);
output = zeros(3,1);
xk_symbs = zeros(size(b,1),1);
symbs = exp(2*pi*j*[0 4 2 6 1 5 3 7]/8);
states = zeros(size(b,1),1);
outs = zeros(size(b,1),1);
for i = 1:size(b,1)
    uc = b(i,:);
    regs = [uc(2); regs(1:end-1)];
    output(3) = mod(uc(1),2);
    output(2) = mod(regs(1) + regs(3) + regs(4),2);
    output(1) = mod(regs(2) + regs(4),2);
    states(i) = bit2int(regs(2:end), 3);

    outs(i) = bin2dec(num2str(output.'));
    symb = symbs(outs(i)+1);
    xk_symbs(i) = symb;
end
end