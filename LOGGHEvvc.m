function [tt] = LOGGHEvvc(speed,flow,xco,deltaT,xcoStart,xcoEnd)


sigma = 0.6; % 0.6 km       Zie paper van Helbing & Treiber
teta = 1.1/60; % 1.1 minuut
cfree = 90; % km/u
ccong = -18; % km/u
Vc = 70; % km/u
deltaV = 10; %km/u
tijdsinterval = deltaT/60; % 1/60 van een uur.
aantal_xpunten = 7; % max aantal punten dat links en rechts wordt gebruikt in berekening 
aantal_tpunten = 7; % max aantal punten dat links en rechts wordt gebruikt in berekening 

%timestep between the trajectories that are being calculated: departure
%time
deltaTtt=1;
%timestep for the trajectories that are being calculated
deltaTTraject=0.25;

%direction
direction = 1;
richting = 1;

%invalid speed
invalid = -1;

%calculating trajectories
for Tdep=1:deltaTtt:(size(speed,2)-1)*deltaT
    
    Xpos=xcoStart;                    %position X
    Tpos=Tdep;                      %position T
    
    while direction*(Xpos-xcoEnd)<0
        
        %some code for trajectsections 
        %traject(tr,:,Tdep)=[Tpos,Xpos];
        
        %Speed according to helbing filter
        
        fispeedfreeflow = 0;
        fiflowfreeflow = 0;
        Normfreeflow = 0;
        fispeedcong = 0;
        fiflowcong = 0;
        Normcong = 0;
        tmp1=find(direction*(Xpos-xco)>0); % geeft een kolom met alle posities in x waarvoor voorwaarde geldt
        if isempty(tmp1) 
            tmp1=1; 
        end
        xmin=max(1,tmp1(end)-aantal_xpunten+1);   
        tmp1=find(direction*(Xpos-xco)<0);
        if isempty(tmp1)
            tmp1=length(xco);
        end    % geeft aan bij hoeveelste x-pos we zitten
        xmax=min(length(xco),tmp1(1)+aantal_xpunten-1); % geeft x-interval dat gebruikt wordt vr afvlakking; xmin en xmax zijn nat getallen <= length(x)
        
        % code hieronder wordt dus uitgevoerd voor elk punt dat berekend
        % moet worden
        
        for i = max(1,round(Tpos)-aantal_tpunten):min(length(speed(1,:)),round(Tpos)+aantal_tpunten)  % gaan t-interval af gebruikt vr afvlakking
            
            for j = xmin:xmax   % gaan x-interval af gebruikt vr afvlakking
                
                xverschil = (xco(j) - Xpos);    %afstand tss beschouwde punt en bemeten punt in interval
                tverschilcong =  tijdsinterval* abs(Tpos-i+richting/tijdsinterval* xverschil/ccong); 
                tverschilfreeflow = tijdsinterval *abs(Tpos-i+richting/tijdsinterval *xverschil/cfree); 
                
                if speed(j,i)==invalid    % invalid is hetgeen er staat bij onvolledige gegevens
                    fifree=0;
                    ficong=0;   % vult onvolledige gegevens aan met nullen en rekent deze niet mee hieronder
                elseif flow(j,i)==0           %wanneer er geen tellingen beschikbaar zijn
                    fifree=0;
                    ficong=0;   % vult onvolledige gegevens aan met nullen en rekent deze niet mee hieronder   
                else
                    fifree = exp(-abs(xverschil)/sigma-abs(tverschilfreeflow)/teta);
                    ficong = exp(-abs(xverschil)/sigma-abs(tverschilcong)/teta);
                    fispeedfreeflow = fispeedfreeflow + fifree * 1/speed(j,i);  % Snelheden worden hier gewoon opgeteld; uiteindelijk wordt er een gewogen gemiddelde van genomen
                    fispeedcong = fispeedcong + ficong * 1/speed(j,i);

                    %old method
                    %fispeedfreeflow = fispeedfreeflow + fifree * speed(j,i);  % Snelheden worden hier gewoon opgeteld; uiteindelijk wordt er een gewogen gemiddelde van genomen
                    %fispeedcong = fispeedcong + ficong * speed(j,i);
                 
                    fiflowfreeflow = fiflowfreeflow + fifree * flow(j,i);
                    fiflowcong = fiflowcong + ficong * flow(j,i);
                    Normfreeflow = Normfreeflow + fifree;
                    Normcong = Normcong + ficong;   % Per punt zowel waarde in congestie als vrij verkeer berekend
                 end  
            end
        end
        
        Vfree = 1/(fispeedfreeflow/Normfreeflow);
        Vcong = 1/(fispeedcong/Normcong);
        %old method
%         Vfree = fispeedfreeflow/Normfreeflow;
%         Vcong = fispeedcong/Normcong;
        
        w = .5 * (1 + tanh((Vc-min(Vfree,Vcong))/deltaV));
        
        SpeedSection = w * Vcong + (1-w) * Vfree; 
        
        Xpos = Xpos + direction*deltaTTraject*SpeedSection/60;
        Tpos = Tpos + deltaTTraject;
    end
    
    Tpos = Tpos - abs(Xpos-xcoEnd)*60/SpeedSection;
    tt(Tdep,:) = [Tdep,Tpos-Tdep];
end
