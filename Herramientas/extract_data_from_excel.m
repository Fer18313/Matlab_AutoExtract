function dataStructs = extract_data_from_excel(filename)
    % Get sheet names from the Excel file
    sheetNames = sheetnames(filename);
    
    % Initialize a cell array to store data structs from each sheet
    dataStructs = cell(1, numel(sheetNames));
    
    % Loop through each sheet and extract data
    for sheetIndex = 1:numel(sheetNames)
        sheetName = sheetNames{sheetIndex};
        
        % Extract data for the current sheet
        data = extract_data_func(filename, sheetName);
        
        % Store the data struct in the cell array
        dataStructs{sheetIndex} = data;
    end
end


