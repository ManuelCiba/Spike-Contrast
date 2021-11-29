% This script generates three of four test data sets which were used in the paper 
% "Spike-contrast: A novel time scale independent and multivariate measure
% of spike train synchrony"
% Author: Manuel Ciba
% Year: 2017


clear all
close all
clc

path_full=mfilename('fullpath'); % get path of this script
[path,~] = fileparts(path_full); % separate path from filename
cd(path)

%% Set Parameter
model='Izhikevich_org';         % here, the original Izhkevich model is used, in a previews version also other models were included
SynStrengthMode='nonlinear';    % 'linear': 1:0, 'nonlinear': custom values
networkMode='new';              % 'same', 'new'
fig=0;                          % 1: show figure, don't save results
Smax=1;                         % maximum inhibitory synaptic strength -> the higher the less synchrony
Smin=0;                         % minimum inhibitory synaptic strength -> the lower the more synchrony
Nsteps=20;                      % number of steps (linear) between Smax and Smin
rec_dur=2;                      % signal length ("recording duration") in seconds
numElectrodes=60;               % number of neurons ("electrodes") that are selected from all neurons
rng shuffle                     % default: reproduceable, shuffle: everytime other values

%% several simulation (one folder for each simulation = like MEA-chip)
for sim=1:10
    exp=[model '_recDur' num2str(rec_dur) '_S'  num2str(Smax) 'to' num2str(Smin) '_' SynStrengthMode '_' networkMode]; % 'Ne800_Ni200_recDur6_S1to0';
    chip=['Sim' num2str(sim)]; % the simulated network, here called "chip" in analogy to networks on MEA chips
    path_dst=[path filesep 'Testdata' filesep exp filesep chip]; % path for saving the data
    
    switch SynStrengthMode
        case 'linear'
            SynStrength=linspace(Smax,Smin,Nsteps); % 20 values from 1 (=original parameter) to 0.5 (lower values do not change sync. anymore)
        case 'nonlinear'
            SynStrength=[1 0.871909871909872 0.820492820492821 0.802768802768803 0.788510788510789 0.779654779654780 0.773181773181773 0.767424767424767 0.761883761883762 0.756232756232756 0.750061750061750 0.742362742362742 0.727781727781728 0.705255705255705 0.663204663204663 0.459013459013459 0.320353320353320 0.169570169570170 0.0271510271510272 0];
    end
    
    if fig; SynStrength=[1 0.75 0]; end
    
    for i=1:length(SynStrength)
        
        %% call neuronal model function
        offsetTime=0.2; % ignore first 1000 ms (as signal is not stable yet)
        if strcmp(networkMode,'same')
            if i==1 % only create random network at first time, than only change synStrength
                Ne=800*1; Ni=200*1;
                numNeurons = Ne+Ni;
                idx= randperm(numNeurons, numElectrodes); % select randomly 60 electrodes
                net=getNetwork_Izhikevich_org(Ne,Ni,'default');
            end
        end
        if strcmp(networkMode,'new') % create a random new network in every iteration
            Ne=800*1; Ni=200*1;
            numNeurons = Ne+Ni;
            idx= randperm(numNeurons, numElectrodes); % select randomly 60 electrodes
            net=getNetwork_Izhikevich_org(Ne,Ni,'default');
        end
        w=[ones(Ne+Ni,Ne), ones(Ne+Ni,Ni).*SynStrength(i)];
        net_nu=net;
        net_nu.S=net_nu.S.*w;
        [TS,V]=getSimulatedSpikes_Izhikevich(net_nu,rec_dur+offsetTime,0); % Ne,Ni,signalLength,InhSynStrength,neuronSort,fig
        
        [TS,~]= eraseSpikesFromTS(TS,TS,0,offsetTime); % erase spikes between 0s and offsetTime s
        TS(isnan(TS))=0; % replace NaN with zeros
        TS=TS-offsetTime;
        tmp=V(offsetTime*1000+1:end,:); V=tmp; % erase offsetTime from membrane potential
        
        %% put some TS in structure SPIKEZ
        SPIKEZ.TS=TS(:,idx);
        SPIKEZ.TS( ~any(SPIKEZ.TS,2), : ) = [];  % delete rows that only contain zeros
        SPIKEZ.TS(SPIKEZ.TS==0)=NaN;
        SPIKEZ.PREF.rec_dur=rec_dur;
        SPIKEZ.PREF.SynStrength=SynStrength(i);
        SPIKEZ.PREF.SaRa=1000;
        %SPIKEZ.PREF.net=net_nu; % don't save net as it needs 7 MB!
        SPIKEZ.PREF.SyncValueAllNeurons=NaN; %SyncMeasure_Fluctuation_V(V);   % "true" synchrony of all simulated neurons
        SPIKEZ.PREF.SyncValue=NaN; %SyncMeasure_Fluctuation_V(V(:,idx));      % "true" synchrony of 60 selected simulated neurons
        
        disp(['SynStrength: ' num2str(SynStrength(i)) ' true-Sync (all): ' num2str(SPIKEZ.PREF.SyncValueAllNeurons) ' true-Sync (60): ' num2str(SPIKEZ.PREF.SyncValue)])
        
        %% show plot
        if fig
            h(1)=subplot(2,3,i);
            h(1).Title.String={['synaptic strength: ' num2str(SPIKEZ.PREF.SynStrength)]};
            h(1)=plotSpikeTrain(SPIKEZ.TS.*1000,h(1));
            h(1).XLabel.String='time in ms';
            h(1).XLim=[0 rec_dur*1000];
            h(2)=subplot(2,3,3+i);
            plot(mean(V(:,idx),2))
            h(2).XLabel.String='time in ms';
            h(2).YLabel.String={'Global membrane' 'potential in µV'};
            h(2).XLim=[0 rec_dur*1000];
            h(2).YLim=[-200 700];
            linkaxes(h(:),'x')
            h(2).Title.String={['"true" synchrony: ' num2str(SPIKEZ.PREF.SyncValueAllNeurons)]};
        end
        
        %% save simulated TS
        if ~fig
            folder_name = path_dst;
            if ~exist(folder_name,'dir')
                mkdir(folder_name);
            end
            save([path_dst filesep num2str(i) '_TS' ],'SPIKEZ');
        end
    end
end % end: for each sim
disp('finished')

