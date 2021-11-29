function net=getNetwork_Izhikevich_org(Ne,Ni,neuronSort)
       
    switch neuronSort
        case 'default'
            % Excitatory neurons are typ RS over IB to CH
            % Inhibitory neurons are typ FS to LTS
            % Excitatory neurons    Inhibitory neurons
            re=rand(Ne,1);          ri=rand(Ni,1);
            a=[0.02*ones(Ne,1);     0.02+0.08*ri];
            b=[0.2*ones(Ne,1);      0.25-0.05*ri];
            c=[-65+15*re.^2;        -65*ones(Ni,1)];
            d=[8-6*re.^2;           2*ones(Ni,1)];
            S=[0.5*rand(Ne+Ni,Ne),  -1*rand(Ne+Ni,Ni)];
            v=-65*ones(Ne+Ni,1);    % Initial values of v
            u=b.*v;                 % Initial values of u
        case 'constSynapses'
            % Excitatory neurons are typ RS over IB to CH
            % Inhibitory neurons are typ FS to LTS
            % Excitatory neurons    Inhibitory neurons
            re=rand(Ne,1);          ri=rand(Ni,1);
            a=[0.02*ones(Ne,1);     0.02+0.08*ri];
            b=[0.2*ones(Ne,1);      0.25-0.05*ri];
            c=[-65+15*re.^2;        -65*ones(Ni,1)]; % exc: c=-65: RS, c=-50: CH,   re^2 to bias towards RS
            d=[8-6*re.^2;           2*ones(Ni,1)]; % exc: d=8: RS, d=2: CH;         re^2 to bias towards RS
            S=[.5*rand(Ne+Ni,Ne),  -1*ones(Ne+Ni,Ni)]; % weight connection matrix, exc. connections are only 0.5 times as strong as inh. conn.
            v=-65*ones(Ne+Ni,1);    % Initial values of v
            u=b.*v;                 % Initial values of u   
    end
    
    net.Ne=Ne;
    net.Ni=Ni;
    net.a=a;
    net.b=b;
    net.c=c;
    net.d=d;
    net.S=S;
    net.v=v;
    net.u=u;
end