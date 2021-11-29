% input: TS
% |             |               |               |   
% e.g. SIB=2, ISI_fraction=0.3 (= 30% of original ISI), jitter=[0 1] (0: no
% jitter, 1: jitter randomly in the range of [0 jitter]*ISI
% output:
% | |           | |             | |             | |

function [TS_nu] = getBurstsfromTS(TS,SIB,ISI_fraction,jitter)
    

    ISI = (TS(2) - TS(1)) * ISI_fraction;

    TS_nu = zeros(length(TS)*SIB,1);

    for i=1:length(TS)
        i_beg = (i*SIB)-SIB+1;
        i_end = i_beg + SIB-1;
        TS_nu(i_beg:i_end)=TS(i):ISI:TS(i)+ISI*(SIB-1);
        
        % apply jitter:
        TS_nu(i_beg:i_end)=TS_nu(i_beg:i_end) + ((rand(i_end-i_beg+1, 1)*jitter) * ISI); % rand -> [0 jitter]*ISI
    end

end  