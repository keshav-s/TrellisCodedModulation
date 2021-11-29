function xk_symbs = tcm_encode(bits)
% t = poly2trellis([1, 4],[1 0 0; 0 13 5]);
% hMod = comm.PSKTCMModulator(t,'ModulationOrder',8);
% xk_symbs = step(hMod,bits);

b = reshape(bits, 2, []).';
regs = zeros(4,1);
pstate = zeros(3,1);
output = zeros(3,1);
xk_symbs = zeros(size(b,1),1);
symbs = exp(2*pi*j*[0 4 2 6 1 5 3 7]/8);
for i = 1:size(b,1)
    if i == 52
        a = 1;
    end
    uc = b(i,:);
    pstate = regs(2:end);
    regs = [uc(2); regs(1:end-1)];
    output(3) = mod(uc(1),2);
    output(2) = mod(regs(1) + regs(3) + regs(4),2);
    output(1) = mod(regs(2) + regs(4),2);

    symb = symbs(bin2dec(num2str(output.'))+1);
    xk_symbs(i) = symb;
end
end