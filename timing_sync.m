function [tau, theta] = timing_sync(zt,timingSignal)
    params;

    [corrs,lags] = xcorr(zt,timingSignal); % pilot upsampled
    [~,I] = max(abs(corrs));
    theta = angle(corrs(I));
    tau = lags(I);
end

