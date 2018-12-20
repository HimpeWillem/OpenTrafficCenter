function data = collectData_noDB(route,detectors,varargin)

%% Disclaimer
% This file is part of the matlab package OpenTrafficCenter
% developed by the KULeuven. 
%
% Copyright (C) 2018  Himpe Willem, Leuven, Belgium
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
% More information at: https://github.com/HimpeWillem/OpenTrafficCenter
% or contact: willem.himpe {@} kuleuven.be


fprintf('Collecting data ...')
tic
if nargin==4
    str_time=varargin{1};
    end_time=varargin{2};
else
    str_time=floor(now)-1;
    end_time=floor(now);
end

files=dir('road_sensor_*.csv');
dataArray_temp = [];
for i=1:size(files,1)
    date_t = strrep(strrep(files(i).name,'.csv',''),'road_sensor_','');
    date_t = datenum(date_t,'yyyy-mm-dd_HH-MM-SS');
    if str_time-2/24<=date_t && date_t<=end_time+4/24
        filename = files(i).name;
        delimiter = ',';
        startRow = 2;
        
        %% Format string for each line of text:
        % For more information, see the TEXTSCAN documentation.
        formatSpec = '%s%f%s%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';
        
        %% Open the text file.
        fileID = fopen(filename,'r');
        
        %% Read columns of data according to format string.
        % This call is based on the structure of the file used to generate this
        % code. If an error occurs for a different file, try regenerating the code
        % from the Import Tool.
        dataArray_temp = [dataArray_temp;textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false)];
        
        %% Close the text file.
        fclose(fileID);
    end      
end

for i=1:size(dataArray_temp,2);
	dataArray{1,i}=cat(1,dataArray_temp{:,i});
end

if isempty(dataArray)
    disp('No data selected');
    return;
end

active_rows = datenum(dataArray{:,3},'yyyy-mm-ddTHH:MM:SS')+1/24>str_time & datenum(dataArray{:,3},'yyyy-mm-ddTHH:MM:SS')+1/24<end_time;

active_detectors=arrayfun(@(x)any(route.edge==x),detectors.link_id);
active_detectors=detectors.detector_id(active_detectors);
active_rows=active_rows&arrayfun(@(x)any(active_detectors==x),dataArray{:,2});

data=cell2table([num2cell(dataArray{:,2}(active_rows)),dataArray{:,3}(active_rows),num2cell(dataArray{:,9}(active_rows)),num2cell(dataArray{:,12}(active_rows)),num2cell(dataArray{:,15}(active_rows)),num2cell(dataArray{:,18}(active_rows)),num2cell(dataArray{:,21}(active_rows)),num2cell(dataArray{:,10}(active_rows)),num2cell(dataArray{:,13}(active_rows)),num2cell(dataArray{:,16}(active_rows)),num2cell(dataArray{:,19}(active_rows)),num2cell(dataArray{:,22}(active_rows)),num2cell(dataArray{:,11}(active_rows)),num2cell(dataArray{:,14}(active_rows)),num2cell(dataArray{:,17}(active_rows)),num2cell(dataArray{:,20}(active_rows)),num2cell(dataArray{:,23}(active_rows)),num2cell(dataArray{:,24}(active_rows)),num2cell(dataArray{:,25}(active_rows)),num2cell(dataArray{:,26}(active_rows))],'VariableNames',{'unieke_id','tijd_waarneming','verkeersintensiteit_1','verkeersintensiteit_2','verkeersintensiteit_3','verkeersintensiteit_4','verkeersintensiteit_5','voertuigsnelheid_rekenkundig_1','voertuigsnelheid_rekenkundig_2','voertuigsnelheid_rekenkundig_3','voertuigsnelheid_rekenkundig_4','voertuigsnelheid_rekenkundig_5','voertuigsnelheid_harmonisch_1','voertuigsnelheid_harmonisch_2','voertuigsnelheid_harmonisch_3','voertuigsnelheid_harmonisch_4','voertuigsnelheid_harmonisch_5','bezettingsgraad','beschikbaarheidsgraad','onrustigheid'});

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

end
