% Pruebas de tesis 2023
% Fernando Sandoval
% Señales EMG - 3 sujetos - Puño cerrado
% Interfaz Biomedica Epilepsia 
%% EMG SIGNALS ONLY 
clear;clc;

% % Extraccion de datos Biopac (Gesto 1)
dataStructs1 = extract_data_from_excel('fistupFer.xlsx');
%dataStructs1 = extract_data_from_excel('fistUp_user.xlsx');
% dataStructs1 = extract_data_from_excel('kate-punioarriba.xlsx');
% dataStructs1 = extract_data_from_excel('Mario-Punio_arriba.xlsx');
% 
% % Extraccion de datos Biopac (Gesto 2)
dataStructs2 = extract_data_from_excel('Fist_Up(Reverse).xlsx');
%dataStructs2 = extract_data_from_excel('fistDown_user.xlsx');
% dataStructs2 = extract_data_from_excel('kate_Punioabajo.xlsx');
% dataStructs2 = extract_data_from_excel('Mario-Punio_abajo.xlsx');

% Extraccion de datos Biopac (Gesto 3) 
dataStructs3 = extract_data_from_excel('FISTCLOSED.xlsx');
%dataStructs3 = extract_data_from_excel('fistClosed_user.xlsx');
%dataStructs2 = extract_data_from_excel('kate-Punio.xlsx');
%dataStructs3 = extract_data_from_excel('Mario-Punio.xlsx');

% SIGNAL MIXED
signals =  {dataStructs1,dataStructs2,dataStructs3};


%% SAVE ALL SAMPLES
baseFileName = 'emg_struct_';

% podemos cambiar la variable folderPath para guardar en diferente localizacion los .mats creados.
folderPath = 'C:\Users\fersa\Desktop\UVG\Sem2_1\Estudio-Epilepsia-2023\Pruebas\Interfaces biomedicas\Roberto Cáceres\Códigos\DatosBiopac\EMG_Signals\Fernando\';

% variableNames depende de como nosotros tenemos el codigo dentro de la aplicacion en App Designer, pues estos van a ser los nombres que tendran las variables
variableNames = {'emg_struct_FistUp', 'emg_struct_FistDown', 'emg_struct_Fist'};

for signalIndex = 1:length(signals)
    currSignal = signals{signalIndex};
    variableName = variableNames{signalIndex};
    
    for structIndex = 1:length(currSignal)
        currStruct = currSignal{structIndex};
        
        % Reshape the 'data' field
        currStruct.data = reshape(currStruct.data', 1, []);
        
        % Generate the full file name with index
        fileName = [baseFileName, num2str(signalIndex), '_', num2str(structIndex), '.mat'];
        fullFilePath = fullfile(folderPath, fileName);
        
        % Save the current struct under the specific variable name
        eval([variableName, ' = currStruct;']);
        save(fullFilePath, variableName);
        
    end
end




