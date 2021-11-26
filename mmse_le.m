function vk = mmse_le(zk, mu_init)
    params;
    pk = pilotSymbs;
    pilotsymbolindex = timingT+1;
    Trainlen = pilotT;
    wk = zeros(w_len,1); % Initialize LMS algorithm

    vk = [];
    for i=1:num_packets
        if i==1
            zk_packet = zk(1:end);
        else
            zk_packet = zk(packetLen*(i-1)+1:end);
        end

        mu = gamma_f/mean(abs(zk).^2); % Normalized step-size, normalized by filter input energy
        % Training phase of LMS algorithm for Practical MMSE-LE
        for mm=1:num_train_epochs
            for (ii=pilotsymbolindex:pilotsymbolindex+Trainlen-1)
               zz_past = zk_packet(ii+f_delay:-1:ii+f_delay-w_len+1);
               vv(ii,1) = transpose(wk)*zz_past; % LE Filter output
               ee(ii,1) = vv(ii) - pk(ii-timingT)*1.25; % ek = vk - pk
               wk = wk - mu*ee(ii)*conj(zz_past); % Adapt filter. Use normalized stepsize
            end
            mu = mu*mu_scaling; % Change the mu for next epoch
        end
        
        % Data phase for Practical MMSE-LE
        j = 1;
        for (ii=pilotsymbolindex+Trainlen:length(zk_packet)-f_delay)
           zz_past = zk_packet(ii+f_delay:-1:ii+f_delay-w_len+1); 
           vv(j,1) = transpose(wk)*zz_past; % Output of Practical MMSE-LE filter
           j=j+1;
        end

        if i == num_packets && mod(messageLen, packetT) > 0 
            vk = [vk; vv(1:mod(messageLen, packetT))];
        else
            vk = [vk; vv(1:packetT)];
        end
        % wk = zeros(w_len,1); % Initialize LMS algorithm
    end
end