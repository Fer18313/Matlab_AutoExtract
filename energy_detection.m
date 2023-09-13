%%SERIAL COM

% Define the COM port
comPort = 'COM3';

% Create a serial object
s = serial(comPort, 'BaudRate', 9600); % Use the same baud rate as in your Arduino code



%% DEBUG, ENERGIA 
% Open the serial connection
fopen(s);


% Initialize a struct to store the data
data_com = struct('data', []);

% Flag to indicate whether to collect data
collectData = false;

% Define a timeout period in seconds
timeoutInSeconds = 50; % Set your desired timeout value here

% Get the current time
startTime = now;

while true
    % Read one line of data
    dataLine = fgetl(s);

    % Check for end of data
    if isempty(dataLine) || strcmp(dataLine, 'END_DATA')
        % End of data sequence
        collectData = false;
        break; % Exit the loop when "END_DATA" is received
    elseif strcmp(dataLine, 'START_DATA')
        % Start collecting data
        collectData = true;

        % Initialize the struct's data field
        data_com.data = [];
    else
        % Try to extract and store the data point
        try
            dataPoint = str2double(dataLine);

            % Check if dataPoint is a valid number (not NaN)
            if ~isnan(dataPoint)
                % Append the data point to the struct's data field
                data_com.data = [data_com.data, dataPoint];
            else
                % Handle the case where the data is not a valid number
                disp(['Invalid data in line: ', dataLine]);
            end
        catch
            % Handle any errors that occur during data extraction
            disp(['Error processing line: ', dataLine]);
        end
    end

    % Check for a timeout
    currentTime = now;
    if (currentTime - startTime) * 24 * 3600 > timeoutInSeconds
        disp('Timeout: No data received for the specified time.');
        break; % Exit the loop on timeout
    end
end

% Display the received data
disp('Data received:');
disp(data_com.data);
% Close the serial connection
fclose(s);
