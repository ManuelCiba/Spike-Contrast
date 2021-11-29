function [TS_nu, AMP_nu] = eraseSpikesFromTS(TS,AMP,t_start,t_end)

    mask = TS >= t_start & TS <= t_end;
    TS(mask)=NaN;
    AMP(mask)=NaN;

    %% sort TS and AMP
    for n=1:size(TS,2)
        [TS_nu(:,n), Index]=sort(TS(:,n));
        AMP_nu(:,n)=AMP(Index,n);
    end
end