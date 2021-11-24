function vk = mmse_le(zk, mu_init)
    params;
    pk = pilotSymbs;
    wk = zeros(mmse_len,1); % Initialize LMS algorithm

    if ~exist('mu_init', 'var')
        mu = gammaMMSE/mean(abs(zk(1:pilotT)).^2); % Normalized step-size, normalized by filter input energy
    else
        mu = mu_init;
    end
    
    vk = [];
    % Training phase of LMS algorithm for Practical MMSE-LE
    for mm=1:num_train_epochs
        for (ii=timingT+1:timingT+pilotT-1)
           zk_past = zk(ii+le_delay:-1:ii+le_delay-mmse_len+1);
           vv(ii,1) = transpose(wk)*zk_past; % LE Filter output
           ek(ii,1) = vv(ii) - pk(ii-timingT+1); % ek = vk - xk
           wk = wk - mu*ek(ii,1)*conj(zk_past); % Adapt filter. Use normalized stepsize
        end
        mu = mu*mu_scaling; % Change the mu for next epoch
    end
    
    % Data phase for Practical MMSE-LE
    for (ii=timingT+pilotT+1:length(zk)-le_delay)
       zk_past = zk(ii+le_delay:-1:ii+le_delay-mmse_len+1); 
       vv(ii-timingT-pilotT+1) = transpose(wk)*zk_past; % Output of Practical MMSE-LE filter
    end
    vk = vv(1:messageLen);
    wk = zeros(mmse_len,1); % Initialize LMS algorithm
%     for i=1:num_packets
%         zk_packet = zk(timingT+le_delay-mmse_len+1+packetLen*(i-1)+1:...
%             timingT+packetLen*i+le_delay);
% 
%         % Training phase of LMS algorithm for Practical MMSE-LE
%         for mm=1:num_train_epochs
%             for (ii=1:timingT+pilotT-1)
%                zk_past = zk_packet(ii+le_delay:-1:ii+le_delay-mmse_len+1);
%                vv(ii,1) = transpose(wk)*zk_past; % LE Filter output
%                ek(ii,1) = vv(ii) - pk(ii-timingT+1); % ek = vk - xk
%                wk = wk - mu*ek(ii,1)*conj(zk_past); % Adapt filter. Use normalized stepsize
%             end
%             mu = mu*mu_scaling; % Change the mu for next epoch
%         end
%         
%         % Data phase for Practical MMSE-LE
%         for (ii=pilotT:length(zk_packet)-le_delay)
%            zk_past = zk_packet(ii+le_delay:-1:ii+le_delay-mmse_len+1); 
%            vv(ii-pilotT+1) = transpose(wk)*zk_past; % Output of Practical MMSE-LE filter
%         end
%         vk = [vk; vv(1:packetT)];
%         wk = zeros(mmse_len,1); % Initialize LMS algorithm
%     end
end