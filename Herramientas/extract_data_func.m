function data = extract_data_func(filename, sheetName)
    [num, txt, raw] = xlsread(filename, sheetName);
    headers = txt(1, :);
    data = struct();
    stopIndex = numel(headers) - 3; % por estructura
    
    for i = 1:size(headers, 2)
        field = headers{i};
        if i <= stopIndex
            values = num(:, i);
        elseif i == stopIndex + 3
            values = raw{2, 4}; % Use curly braces for cell indexing
        else
            values = num(1, i);
        end
        data.(field) = values;
    end
end
