% Werking: de gemeten waarden worden op een raster (tijd, ruimte) ingegeven 
% als input. Er wordt een nieuw raster gekozen dat niet noodzakelijk de
% punten uit het oorspronkelijke raster bevat. De waarden voor dit nieuwe raster worden
% berekend uit de waarden van het oude raster, waarbij gewichten worden
% toegekend afhankelijk van de afstand tot het nieuwe punt (exponentieel
% dalend). Onvolledige data uit het oorspronkelijk raster worden weliswaar
% vervangen door nullen, MAAR er worden geen gewichten aan toegekend. Merk
% ook op dat zelfs als punten uit het oude raster ook in het nieuwe liggen,
% dat deze niet dezelfde waarde zullen behouden.


function [gefilterdeflow,gefilterdespeed,xen,woverzicht] = helbingFilter(flowmatrix, speedmatrix,x,invalid,richting)

flowmatrix(isnan(flowmatrix))=0;
speedmatrix(isnan(speedmatrix))=0;
% flowmatrix(speedmatrix>150)=0;
% speedmatrix(speedmatrix>150)=0;


sigma = 0.6; % 0.6 km       Zie paper van Helbing & Treiber
teta = 1.1/60; % 1.1 minuut
cfree = 105; % km/u
ccong = -20; % km/u 
Vc = 90; % km/u 65
deltaV = 20; %km/u  20
tijdsinterval = 1/60; % 1/60 van een uur.
aantal_xpunten = 10; % max aantal punten dat links en rechts wordt gebruikt in berekening 
aantal_tpunten = 3*12; % max aantal punten dat links en rechts wordt gebruikt in berekening 

xafstand = x(end)-x(1);
dx = sign(xafstand)*.1; % grootte van de stappen; tijdstap is niet meegegeven, standaard op 1 min
aantalxposities= fix(xafstand/dx)+1;

xen(1) = x(1);
for i = 2:aantalxposities
    xen(i) = xen(i-1)+dx;
end

gefilterdeflow = zeros(length(flowmatrix(:,1)),aantalxposities);  % +1 om bovenaan x-pos te zetten
gefilterdespeed = gefilterdeflow;% zeros(boventijd-ondertijd+1,round((bovenx-onderx)/deltax) +1);
woverzicht= gefilterdeflow;
stoppen = 0;        % Om te checken voor fouten

wait = waitbar(0,'Please be patient, the data is being filtered...');
for tstap = 1:length(gefilterdeflow(:,1))
    waitbar(tstap/length(flowmatrix(:,1)))
    xenindex = 0;
    
    for ii = 1:aantalxposities %onderx:deltax:bovenx; % Merk op dat hier NIET expliciet van aflopende rijrichting met x wordt uitgegaan !!
        xstap = xen(ii);
        xenindex = xenindex+1;  % per tijdstap gaan we alle x'en af
        fispeedfreeflow = 0;
        fiflowfreeflow = 0;
        Normfreeflow = 0;
        fispeedcong = 0;
        fiflowcong = 0;
        Normcong = 0;
        tmp1=find(xstap>x); % geeft een kolom met alle posities in x waarvoor voorwaarde geldt
        if isempty(tmp1); tmp1=1; end
        xmin=max(1,tmp1(end)-aantal_xpunten+1);   
        tmp1=find(xstap<x);
        if isempty(tmp1); tmp1=length(x);end    % geeft aan bij hoeveelste x-pos we zitten
        xmax=min(length(x),tmp1(1)+aantal_xpunten-1); % geeft x-interval dat gebruikt wordt vr afvlakking; xmin en xmax zijn nat getallen <= length(x)
        
        % code hieronder wordt dus uitgevoerd voor elk punt dat berekend
        % moet worden
        st_t=max(1,tstap-aantal_tpunten);
        ed_t=min(length(speedmatrix(:,1)),tstap+aantal_tpunten);
        for i = st_t:ed_t  % gaan t-interval af gebruikt vr afvlakking
            
            for j = xmin:xmax   % gaan x-interval af gebruikt vr afvlakking
                
                xverschil = richting*(x(j) - xstap);    %afstand tss beschouwde punt en bemeten punt in interval
                tverschilcong =  tijdsinterval* abs(i-tstap-1/tijdsinterval* xverschil/ccong); 
                tverschilfreeflow = tijdsinterval *abs(i-tstap-1/tijdsinterval *xverschil/cfree); 
                xverschil =abs(xverschil );
                if speedmatrix(i,j)==invalid || flowmatrix(i,j)==invalid  || speedmatrix(i,j) > 249  % invalid is hetgeen er staat bij onvolledige gegevens
                    % vult onvolledige gegevens aan met nullen en rekent deze niet mee hieronder
                else
                    fifree = exp(-abs(xverschil)/sigma-abs(tverschilfreeflow)/teta);
                    ficong = exp(-abs(xverschil)/sigma-abs(tverschilcong)/teta);
                    fispeedfreeflow = fispeedfreeflow + fifree * speedmatrix(i,j);  % Snelheden worden hier gewoon opgeteld; uiteindelijk wordt er een gewogen gemiddelde van genomen
                    fispeedcong = fispeedcong + ficong * speedmatrix(i,j);
                    fiflowfreeflow = fiflowfreeflow + fifree * flowmatrix(i,j);
                    fiflowcong = fiflowcong + ficong * flowmatrix(i,j);
                    Normfreeflow = Normfreeflow + fifree;
                    Normcong = Normcong + ficong;   % Per punt zowel waarde in congestie als vrij verkeer berekend
                end
            end
        end
        
        if Normfreeflow==0|Normcong==0
            stoppen =1;
            Normfreeflow = 1;
            Normcong = 1;
        end    
        Vfree = fispeedfreeflow/Normfreeflow;
        Vcong = fispeedcong/Normcong;
        w = .5 * (1 + tanh((Vc-min(Vfree,Vcong))/deltaV));
        woverzicht(tstap,xenindex) = w; % geeft surf plot met waarden tussen 0 en 1 om congestie aan te duiden
        gefilterdespeed(tstap,xenindex)= w * Vcong + (1-w) * Vfree; 
        gefilterdeflow(tstap,xenindex)= w * fiflowcong/Normcong + (1-w) * fiflowfreeflow/Normfreeflow;
        %gefilterdespeed(tstap-ondertijd+1,round((xstap-onderx)/deltax)+1) = w * Vcong + (1-w) * Vfree;         
        %gefilterdeflow(tstap-ondertijd+1,round((xstap-onderx)/deltax)+1) = w * fiflowcong/Normcong; + (1-w) * fiflowfreeflow/Normfreeflow;;         
        %round((xstap-onderx)/deltax)+1
        %((xstap-onderx)/deltax)+1
    end
end
if stoppen == 1
    display('Er is een fout opgetreden tijdens de berekeningen omdat er niet genoeg gegevens waren.')   % Wanneer er links en rechts alleen maar nullen zijn, gaat hij normaal delen door 0.
    display('Vergroot het meetinterval, of gebruik andere gegevens.')
end
display('Data is interpolated in a space time grid of 100 meter by 1 minute')
close(wait)


% Opmerking: de output bestaat uit equidistante punten; de waarden op de
% meetpunten zitten hier dus niet noodzakelijk meer in. 

