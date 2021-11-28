function xk_symbs = bits2symbs(bits, B)
    bits = 1*bits;
    M = 2^B;
    data = bit2int(reshape(bits, B, []), B).';
    % Note: QAMMOD outputs the complex conjugate of the mapping in the handout
    xk_symbs = qammod(data, M); 
end