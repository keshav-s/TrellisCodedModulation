function xk_symbs = bits2symbs(bits, coded, B)
    bits = 1*bits;
    M = 2^B;

    extra = mod(size(bits,1), B);
    if extra == 0
        data = bit2int(reshape(bits, B, []), B).';
    else
        bits = [bits; zeros(B-extra,1)];
        data = bit2int(reshape(bits, B, []), B).';
    end
    % Note: QAMMOD outputs the complex conjugate of the mapping in the handout
    if coded
        xk_symbs = pskmod(data, M); 
    else
        xk_symbs = qammod(data, M);
    end
end