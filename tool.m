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
% Define the possible endings for baseFileName
baseFileNameEndings = {'FistUp', 'FistDown', 'Fist'}; % Add your desired options

% podemos cambiar la variable folderPath para guardar en diferente localizacion los .mats creados.
folderPath = 'C:\Users\fersa\Desktop\UVG\Sem2_1\Estudio-Epilepsia-2023\Pruebas\Interfaces biomedicas\Roberto Cáceres\Códigos\DatosBiopac\EMG_Signals\Fernando\';

% variableNames depende de como nosotros tenemos el codigo dentro de la aplicacion en App Designer, pues estos van a ser los nombres que tendran las variables
variableNames = {'emg_struct_FistUp', 'emg_struct_FistDown', 'emg_struct_FistUp'};

for signalIndex = 1:length(signals)
    currSignal = signals{signalIndex};
    variableName = variableNames{signalIndex};
    currBaseFileNameEnding = baseFileNameEndings{signalIndex}; % Get the corresponding ending
    for structIndex = 1:length(currSignal)
        currStruct = currSignal{structIndex};
        
        % Reshape the 'data' field
        currStruct.data = reshape(currStruct.data', 1, []);
        
        % Generate the full file name with index
        fileName = [baseFileName, currBaseFileNameEnding, '_', num2str(structIndex), '.mat'];
        fullFilePath = fullfile(folderPath, fileName);
        
        % Save the current struct under the specific variable name
        eval([variableName, ' = currStruct;']);
        save(fullFilePath, variableName);
        
    end
end

%% ONLY RUN IF YOU KNOW WHAT YOU ARE DOING
baseFileName = 'emg_struct_';
% Define the possible endings for baseFileName
baseFileNameEndings = {'FistUp', 'FistDown', 'Fist'}; % Add your desired options

% Define the folder path to save the concatenated data
folderPath = 'C:\Users\fersa\Desktop\UVG\Sem2_1\Estudio-Epilepsia-2023\Pruebas\Interfaces biomedicas\Roberto Cáceres\Códigos\DatosBiopac\EMG_Signals\Fernando\';

% Define variable names according to the gesture
variableNames = {'emg_struct_FistUp', 'emg_struct_FistDown', 'emg_struct_FistUp'};

for signalIndex = 1:length(signals)
    currSignal = signals{signalIndex};
    currBaseFileNameEnding = baseFileNameEndings{signalIndex}; % Get the corresponding ending
    
    % Initialize an array to store data from the current gesture
    gestureData = [];
    totalDataLength = 0;
    
    for structIndex = 1:length(currSignal)
        currStruct = currSignal{structIndex};
        
        % Reshape the 'data' field
        currStruct.data = reshape(currStruct.data', 1, []);
        
        % Append the current data to the gestureData array
        gestureData = [gestureData, currStruct.data];
        totalDataLength = totalDataLength + currStruct.data_length_sec;

    end
    
    % Create a struct with a 'data' field and save it as a .mat file
    gestureDataStruct.data = gestureData;
    gestureDataStruct.data_length_sec = totalDataLength;
    gestureDataStruct.sampling_frequency = length(gestureData)/totalDataLength;
    gestureDataStruct.channels = 'Canal 1';
    
    % Save the current gesture data as a .mat file with the appropriate variable name
    fileName = [baseFileName, currBaseFileNameEnding, '.mat'];
    fullFilePath = fullfile(folderPath, fileName);
    
    % Save the current struct under the specific variable name
    eval([variableNames{signalIndex}, ' = gestureDataStruct;']);
    save(fullFilePath, variableNames{signalIndex});
end
