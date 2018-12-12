function data = collectData(route,varargin)

if nargin==3
    str_time=datestr(varargin{1}-1/24,'yyyy-mm-ddTHH:MM');
    end_time=datestr(varargin{2}-1/24,'yyyy-mm-ddTHH:MM:SS');
else
    str_time=datestr(floor(now)-1,'yyyy-mm-ddTHH:MM');
    end_time=datestr(floor(now),'yyyy-mm-ddTHH:MM:SS');
end

global conn_KUL conn_type;

fprintf('Collecting data ...')
tic;

quer = ['SELECT miv.loopdata.unieke_id,tijd_waarneming,verkeersintensiteit_1,verkeersintensiteit_2,verkeersintensiteit_3,verkeersintensiteit_4,verkeersintensiteit_5,',...
        'voertuigsnelheid_rekenkundig_1,voertuigsnelheid_rekenkundig_2,voertuigsnelheid_rekenkundig_3,voertuigsnelheid_rekenkundig_4,voertuigsnelheid_rekenkundig_5,',...
        'voertuigsnelheid_harmonisch_1,voertuigsnelheid_harmonisch_2,voertuigsnelheid_harmonisch_3,voertuigsnelheid_harmonisch_4,voertuigsnelheid_harmonisch_5,',...
        'bezettingsgraad,beschikbaarheidsgraad,onrustigheid FROM miv.loopdata ',...
        'INNER JOIN public.miv_config ON miv.loopdata.unieke_id = public.miv_config.unieke_id ',... 
        'WHERE public.miv_config.link_id IN(',sprintf('%.0f,' , route.edge(1:end-1)'),num2str(route.edge(end)),') ',...
        'AND miv.loopdata.tijd_waarneming >= ',char(39),str_time,char(39),' ',...
        'AND miv.loopdata.tijd_waarneming <= ',char(39),end_time,char(39),' '...
        'ORDER BY miv.loopdata.tijd_waarneming;' ];
  
    
curs = exec(conn_KUL, [quer]);
curs = fetch(curs);
data=curs.Data;
if conn_type == 'odbc'
    data=cell2table(data,'VariableNames',{'unieke_id','tijd_waarneming','verkeersintensiteit_1','verkeersintensiteit_2','verkeersintensiteit_3','verkeersintensiteit_4','verkeersintensiteit_5','voertuigsnelheid_rekenkundig_1','voertuigsnelheid_rekenkundig_2','voertuigsnelheid_rekenkundig_3','voertuigsnelheid_rekenkundig_4','voertuigsnelheid_rekenkundig_5','voertuigsnelheid_harmonisch_1','voertuigsnelheid_harmonisch_2','voertuigsnelheid_harmonisch_3','voertuigsnelheid_harmonisch_4','voertuigsnelheid_harmonisch_5','bezettingsgraad','beschikbaarheidsgraad','onrustigheid'});
end
data.tijd_waarneming=datenum(data.tijd_waarneming,'yyyy-mm-ddTHH:MM:SS')+1/24;
data.Properties.VariableNames{'tijd_waarneming'}='time_epoch';
data.Properties.VariableNames{'verkeersintensiteit_1'}='intensity1';
data.Properties.VariableNames{'verkeersintensiteit_2'}='intensity2';
data.Properties.VariableNames{'verkeersintensiteit_3'}='intensity3';
data.Properties.VariableNames{'verkeersintensiteit_4'}='intensity4';
data.Properties.VariableNames{'verkeersintensiteit_5'}='intensity5';
data.Properties.VariableNames{'voertuigsnelheid_rekenkundig_1'}='speed_average1';
data.Properties.VariableNames{'voertuigsnelheid_rekenkundig_2'}='speed_average2';
data.Properties.VariableNames{'voertuigsnelheid_rekenkundig_3'}='speed_average3';
data.Properties.VariableNames{'voertuigsnelheid_rekenkundig_4'}='speed_average4';
data.Properties.VariableNames{'voertuigsnelheid_rekenkundig_5'}='speed_average5';
data.Properties.VariableNames{'voertuigsnelheid_harmonisch_1'}='speed_harmonic1';
data.Properties.VariableNames{'voertuigsnelheid_harmonisch_2'}='speed_harmonic2';
data.Properties.VariableNames{'voertuigsnelheid_harmonisch_3'}='speed_harmonic3';
data.Properties.VariableNames{'voertuigsnelheid_harmonisch_4'}='speed_harmonic4';
data.Properties.VariableNames{'voertuigsnelheid_harmonisch_5'}='speed_harmonic5';
data.Properties.VariableNames{'bezettingsgraad'}='occupancy';
data.Properties.VariableNames{'beschikbaarheidsgraad'}='availability';
data.Properties.VariableNames{'onrustigheid'}='anxiety';
time=toc;
fprintf(['  done (',num2str(time),'sec)\n',]);
close(curs);

end