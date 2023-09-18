[~] = autoextract_func_inter('FistUp.xlsx','FistDown.xlsx'); % CAN MODIFY TO INCLUDE MORE GESTURES
[~]= SegmentV2(gesto.data, gesto.sampling_frequency, 0.0002, 0.002, 100, 1); 

[~,~] = segment_auto_func(gesto_1, gesto_2)

% para segmentos 0.00005, 0.0002, 10, 1


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