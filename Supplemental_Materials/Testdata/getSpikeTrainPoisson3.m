%% generate artificial spike train (poisson distributed)
% input:    timeStep:           time step in seconds of smallest intervall, typically 1 ms
%           spikeRate:       spike rate (spikes per seconds)
%           duration:           duration of spike train in seconds
%           numTrains:          number of parallel spike trains (=number of electrodes)
% output:   TS:                 time stamps of spikes in seconds
%
%% Explanation
% http://preshing.com/20111007/how-to-generate-random-timings-for-a-poisson-process/
% 
% F(x) = 1 - e^(-lamda * x)
% F(x): cumulative distribution function (F(x) = p(X <= x))
% lambda: rate (e.g. 1/40 earthquakes per minute) 
% -> how likely an earthquake occures within x minutes? F(10 min)=0.22
%
% if you want to know the next time an earthquake will occure if lambda is
% given:
% e^(-lamda *x) = 1 - F(x)
% -lamda *x = ln(1 - F(x))
% x = -ln(1 - F(x)) /lamda
% x = -ln(U) /lamda        U: uniformly distributed random values (???)


function [TS]=getSpikeTrainPoisson3(rate,T,numEl)
    
    TS=cell(numEl); % init TS

    for i=1:numEl
        % init:
        j=1;
        TS{i}(1)=-log(rand(1,1))/rate; % create first time stamp
        
        while TS{i}(j) <= T
            isi =  -log(rand(1,1))/rate;
            TS{i}(j+1) = isi + TS{i}(j);
            j=j+1;
        end
        TS{i}(j)=[]; % erase last value as it is higher than T
        
    end
    
    TS=TS_Cell2M(TS);
    
end