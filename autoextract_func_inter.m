function [signals] = autoextract_func_inter(gesto1,gesto2) % CAN MODIFY TO INCLUDE MORE GESTURES
% Dev: Fernando Sandoval
% Function takes input arguments as .xlsx name of file. For the purpose of
% ordering data in database, the files have to be inside the folderPath.

    numGestures = nargin; 

     % Initialize an empty cell array to store dataStructs for each gesture
    signals = {};
    
    % Process gesto1
    if numGestures >= 1
        dataStructs1 = extract_data_from_excel(gesto1);
        signals{end+1} = dataStructs1;
    end
    
    % Process gesto2
    if numGestures >= 2
        dataStructs2 = extract_data_from_excel(gesto2);
        signals{end+1} = dataStructs2;
    end
   

%% NAME, SAVE DIR

baseFileName = 'signal_struct_';

% Allow the user to enter baseFileNameEndings using an input dialog
    prompt = 'Ingrese los nombres de los gestos(separados por coma):';
    dlgtitle = 'Input baseFileNameEndings';
    dims = [1 35]; 
    definput = {'FistUp, FistDown'}; % Default value
    baseFileNameEndings = inputdlg(prompt, dlgtitle, dims, definput);
    baseFileNameEndings = strsplit(baseFileNameEndings{1}, ', ');
    
  if numGestures == 2
    variableNames = {'gesto_1', 'gesto_2'};
  else
    variableNames = {'gesto_1'};
  end
    
    % podemos cambiar la variable folderPath para guardar en diferente localizacion los .mats creados.
    % Allow the user to interactively select a folder using a dialog
    folderPath = uigetdir('C:\', 'Seleccione dónde desea guardar las señales');

    if folderPath == 0
        % The user canceled the folder selection, handle this case as needed
        error('Usuario cancelo acción.');
    end
%% ALGORITHM - SINGLE .MAT
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

%% ALGORITHM FOR CONCATENATION 
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



end



