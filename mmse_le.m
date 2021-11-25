function vk = mmse_le(zk, mu_init)
    params;
    pk = pilotSymbs;
    wk = zeros(mmse_len,1); % Initialize LMS algorithm
    
    vk = [];
    for i=1:num_packets
        if i==1
            zk_packet = zk(1:end);
        else
            zk_packet = zk(packetLen*(i-1)+1:end);
        end

        mu = gammaMMSE/mean(abs(zk(timingT+1:timingT+pilotT)).^2); % Normalized step-size, normalized by filter input energy

        % Training phase of LMS algorithm for Practical MMSE-LE
        for mm=1:num_train_epochs
            for (ii=timingT+1:timingT+pilotT-1)
               zk_past = zk_packet(ii+le_delay:-1:ii+le_delay-mmse_len+1);
               vv(ii,1) = transpose(wk)*zk_past; % LE Filter output
               ek(ii,1) = vv(ii) - pk(ii-timingT+1); % ek = vk - xk
               wk = wk - mu*ek(ii,1)*conj(zk_past); % Adapt filter. Use normalized stepsize
            end
            mu = mu*mu_scaling; % Change the mu for next epoch
        end
        
        % Data phase for Practical MMSE-LE
        j = 1;
        for (ii=timingT+pilotT:length(zk_packet)-le_delay)
           zk_past = zk_packet(ii+le_delay:-1:ii+le_delay-mmse_len+1); 
           vv(j,1) = transpose(wk)*zk_past; % Output of Practical MMSE-LE filter
           j=j+1;
        end
        vk = [vk; vv(1:packetT,1)];
        wk = zeros(mmse_len,1); % Initialize LMS algorithm
    end
end