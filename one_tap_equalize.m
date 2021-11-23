function [vk, zk_full_eq] = one_tap_equalize(zk)
    params;

    pilotSignal = conv(pilotUp,pt,'same');
    pk = pilotSignal(1:fs:end);
    zk_full_eq = [];
    vk = [];
    for i=1:num_packets
        if length(zk(packetLen*(i-1)+1:end)) > packetLen
            zk_packet = zk(packetLen*(i-1)+1:packetLen*i);
        else
            zk_packet = zk(packetLen*(i-1)+1:end-1);
        end
    
        pk_hat = zk_packet(1:pilotT);
        zk_message = zk_packet(pilotT+1:end);
        eq = (pk_hat.' * pk)/ (pk' * pk);
        zk_full_eq = [zk_full_eq; zk_packet/eq];
        vk = [vk; zk_message/eq];
    end
end