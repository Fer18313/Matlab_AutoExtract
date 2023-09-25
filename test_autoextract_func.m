[~] = autoextract_func_inter('headTiltRight_user.xlsx','headDown_user.xlsx'); % CAN MODIFY TO INCLUDE MORE GESTURES

[movements_segment, filtered_eeg_data,segment_start, segment_end]= SegmentV2EEG(gesto.data, gesto.sampling_frequency, 0.01, 100,1); 
[movements_segment, filtered_emg_data,segment_start, segment_end]= SegmentV2(gesto.data, gesto.sampling_frequency, 0,10, 1); 

%% TEST THRESHOLD VALUES
[~, beta_wave, ~, ~]=extract_brainwaves(filtered_eeg_data, gesto.sampling_frequency, true)

%%
    fft_result = fft(gesto.data)
    n = length(gesto.data); % Number of data points
    f = (0:(n-1)) * (gesto.sampling_frequency / n); % Frequency vector

    % Calculate the magnitude of the FFT
    fft_magnitude = abs(fft_result);

    % Plot the FFT
    figure;
    plot(f, fft_magnitude);
    title('FFT EEG Data');
    xlabel('Frequencia (Hz)');
    ylabel('Magnitud');

%% PRUEBAS INTERSUJETO
% Load the first .mat file
load('signal_struct_Fist_Fer.mat');
data1 = gesto.data;
data_length_sec1 = gesto.data_length_sec;
% Load the second .mat file
load('signal_struct_Fist_Katie.mat');
data2 = gesto.data;
data_length_sec2 = gesto.data_length_sec;
% Load the third .mat file
load('signal_struct_Fist_mario.mat');
data3 = gesto.data;
data_length_sec3 = gesto.data_length_sec;

% Concatenate the data fields
concatenatedData = [data1, data2, data3];
data_length_sec = data_length_sec1 + data_length_sec2 + data_length_sec3;

gesto = struct('data', concatenatedData, 'data_length_sec', data_length_sec, 'sampling_frequency', 500);



function robot = puma560()

    % Parámetros DH del Puma 560
    L1 = Link('d', 0.675, 'a', 0, 'alpha', pi/2, 'offset', 0, 'qlim', [-160 160]*deg);
    L2 = Link('d', 0, 'a', 0.35, 'alpha', 0, 'offset', -pi/2, 'qlim', [-45 225]*deg);
    L3 = Link('d', 0, 'a', 1.25, 'alpha', 0, 'offset', 0, 'qlim', [-225 45]*deg);
    L4 = Link('d', 0, 'a', -0.054, 'alpha', pi/2, 'offset', -pi/2, 'qlim', [-110 170]*deg);
    L5 = Link('d', 0.96, 'a', 0, 'alpha', -pi/2, 'offset', 0, 'qlim', [-100 100]*deg);
    L6 = Link('d', 0.193, 'a', 0, 'alpha', 0, 'offset', 0, 'qlim', [-266 266]*deg);

    % Crear la estructura del robot
    robot = SerialLink([L1 L2 L3 L4 L5 L6], 'name', 'Puma560');

end