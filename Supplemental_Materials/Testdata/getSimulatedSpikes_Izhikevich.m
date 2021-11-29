%% generates spike trains according to Izhikevich 2003
% we choose the ratio of excitatory to inhibitory neurons to be 4 to 1, and
% we make inhibitory synaptic connections stronger. Besides the synaptic
% input, each neuron receives a noisy thalamic input.
% In principle, one can use RS cells to model all excitatory neurons
% and FS cells to model all inhibitory neurons. The best way to achieve
% heterogeneity (so that different neurons have different dynamics), is
% to assign each excitatory cell 
% (ai, bi) = (0.02, 0.2) 
% and 
% (ci , di ) = (-65, 8) + (15, -6)ri^2
%  , where ri is a random variable uniformly dis-
% tributed on the interval [0,1], and i is the neuron index. Thus, ri = 0
% corresponds to regular spiking (RS) cell, and ri = 1 corresponds to
% 2the chattering (CH) cell. We use ri to bias the distribution toward RS
% cells. Similarly, each inhibitory cell has (ai ; bi ) = (0:02; 0:25) +
% (0:08; 00:05)ri and (ci ; di ) = (065; 2).
% The model belongs to the class of pulse-coupled neural networks
% (PCNN): The synaptic connection weights between the neurons are
% given by the matrix S = (sij ), so that firing of the j th neuron in-
% stantaneously changes variable vi by sij .
%
% Input:    numNeurons:     number of simulated neurons in network (e.g. 1000)
%           ExcInhRatio:    ratio between excitatory and inhibitory neurons (typ. 4/1)
%           SignalLength:   length of simulated signal in seconds
%           fig:            flag=1: show spike raster plot, flag=0: no plot
% Output:   


function [TS,V]=getSimulatedSpikes_Izhikevich(net,signalLength,fig)

    if nargin <= 5
       fig=0; 
    end
    
    T=signalLength*1000; % this model requires milli seconds
    
    %% init typical parameter
    % excitatory:
    % RS (regular spiking):         a=0.02  b=0.2   c=-65   d=8
    % IB (intrinsically bursting):  a=0.02  b=0.2   c=-55   d=4
    % CH (chattering: IBImin=25ms): a=0.02  b=0.2   c=-50   d=2
    % inhibitory:
    % FS (fast spiking):            a=0.1   b=0.2   c=-65   d=2
    % LTS (low thresh. spiking):    a=?     b=0.25  c=?     d=?
    Ne=net.Ne;
    Ni=net.Ni;
    a=net.a;
    b=net.b;
    c=net.c;
    d=net.d;
    S=net.S;
    v=net.v;
    u=net.u;
    
    V=zeros(T,Ne+Ni);       % Initial values of V

    numNeurons=Ni+Ne;
    firings=[];             % spike timings

    for t=1:T            % simulation of 1000 ms
        I=[5*randn(Ne,1);2*randn(Ni,1)]; % thalamic input
        fired=find(v>=30);    % indices of spikes
        firings=[firings; t+0*fired,fired];
        v(fired)=c(fired);
        u(fired)=u(fired)+d(fired);
        I=I+sum(S(:,fired),2);
        v=v+0.5*(0.04*v.^2+5*v+140-u+I); % step 0.5 ms
        v=v+0.5*(0.04*v.^2+5*v+140-u+I); % for numerical
        u=u+a.*(b.*v-u);                 % stability

        V(t,:)=v; % save membrane potential over time
    end
    if fig; plot(firings(:,1),firings(:,2),'.'); end
    
    %% transform to TS (Dr.Cell format containing time stamps)
    TS=zeros(size(firings,1), numNeurons);
    for n=1:numNeurons
        temp = firings(firings(:,2)==n,1);
        TS(1:length(temp),n)=temp;
    end
    TS=TS./1000; % in seconds

end