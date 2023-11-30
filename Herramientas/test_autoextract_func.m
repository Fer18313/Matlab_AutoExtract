[~] = autoextract_func_inter('headTiltRight_user.xlsx','headDown_user.xlsx'); % CAN MODIFY TO INCLUDE MORE GESTURES

[segmentos_1, filtered_eeg_data,segment_start, segment_end]= SegmentV2EEG(gesto.data, gesto.sampling_frequency, 0.001, 150, 100,1); 
[movements_segment, filtered_emg_data,segment_start, segment_end]= SegmentV2(gesto.data, gesto.sampling_frequency, 0.001,0, 250, 1); 

%%
[vector_gesto_1, ventanadatos_gesto_1, ~] = FeaturesV3023(segmentos_1, 1, size(segmentos_1,2), 1, 6);


%%
[vector_gesto_nuevo, ventanadatos_gesto_nuevo, ~] = FeaturesV2023(gesto.data, 1, length(gesto.data), 1, [1 1 1 1 1 0]);
%%
checkval = isfinite(gesto.data)
index_of_zero = 0;



% Initialize an array to store the indices of zeros
indices_of_zeros = [];

% Loop through the vector to find all zeros
for i = 1:length(checkval)
    if checkval(i) == 0
        indices_of_zeros = [indices_of_zeros, i];
    end
end

if isempty(indices_of_zeros)
    disp('No zeros found in the vector.');
else
    disp(['Zeros found at indices: ', num2str(indices_of_zeros)]);
end
%%
% Define the range of data to plot
start_index = segment_start(3);
end_index = segment_end(3);
data_to_plot = filtered_emg_data(start_index:end_index);
data_to_plot2 = movements_segment(3,:);
figure(1)


% Plot the data
plot(data_to_plot,'DisplayName', 'Segmento Interpolado', 'Color', 'r');
hold on
% Plot the data
plot(data_to_plot2,'DisplayName', 'Segmento Original', 'Color', 'b');
hold off
% Add labels and title
xlabel('N muestras','FontSize', 16);
ylabel('Amplitud (mV)', 'FontSize', 16);
title('Segmento EEG', 'FontSize', 16);
set(gca, 'FontSize', 14); 
legend('Location', 'best', 'FontSize', 18);




%% TEST THRESHOLD VALUES
[delta_wave, beta_wave, alpha_wave, gamma_wave, theta_wave]=extract_brainwaves(filtered_eeg_data, gesto.sampling_frequency, true,true)

%%
fft_result = fft(gesto.data);
n = length(gesto.data); % Número de puntos de datos
f = (0:(n/2 - 1)) * (gesto.sampling_frequency / n); % Vector de frecuencia unilateral

% Calcular la magnitud de la FFT y tomar solo la mitad unilateral
fft_magnitude_unilateral = abs(fft_result(1:n/2));

% Crear el gráfico
figure;

% Graficar el espectro de amplitud unilateral
stem(f, fft_magnitude_unilateral);

% Título con un tamaño de fuente más grande
title('Espectro de Amplitud Unilateral EEG', 'FontSize', 16);

% Etiquetas de ejes con un tamaño de fuente más grande
xlabel('Frecuencia (Hz)', 'FontSize', 14);
ylabel('Magnitud', 'FontSize', 14);

% Aumentar el tamaño de fuente de los números en los ejes
set(gca, 'FontSize', 12); % Ajusta el tamaño de fuente de los números en los ejes


%% PRUEBAS INTERSUJETO
% Load the first .mat file
load('signal_struct_HeadTiltRightP000.mat');
data1 = gesto.data;
data_length_sec1 = gesto.data_length_sec;
% Load the second .mat file
load('signal_struct_HeadTiltRightP001.mat');
data2 = gesto.data;
data_length_sec2 = gesto.data_length_sec;
% Load the third .mat file
load('signal_struct_HeadTiltRightP001.mat');
data3 = gesto.data;
data_length_sec3 = gesto.data_length_sec;


% Concatenate the data fields
concatenatedData = [data1, data2, data3];
data_length_sec = data_length_sec1 + data_length_sec2 + data_length_sec3;

gesto = struct('data', concatenatedData, 'data_length_sec', data_length_sec, 'sampling_frequency', 200);



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



%%
% Extraer características utilizando FeaturesV2 para gesto_1(edf,fs,canales,muestras,c,op)
                    [vector_gesto_1, ventanadatos_gesto_1, ~] = FeaturesV2023(segmentos_1(i,:), app.canales, size(segmentos_1,2), app.c_gesto_1, app.op);
                   
                    % Hacer algo con las características extraídas de gesto_1, por ejemplo, almacenarlas
                    app.Matriz_features_gesto_1 = vector_gesto_1;
                    app.channel_ventana_gesto_1 = ventanadatos_gesto_1;
                    Features_result.Car_gesto_1.VectorCaracteristicas_gesto_1 = [Features_result.Car_gesto_1.VectorCaracteristicas_gesto_1; vector_gesto_1];
                    Features_result.Car_gesto_1.Caracteristicas = [seleccion1,',',seleccion2,',',seleccion3,',',seleccion4,',',seleccion5,',',seleccion6];
                    Features_result.Car_gesto_1.canales = app.c_gesto_1;
                    Features_result.Car_gesto_1.data = [Features_result.Car_gesto_1.data; ventanadatos_gesto_1];
                    Features_result.Car_gesto_1.FMuestreo = app.gesto1Fs;
                    Features_result.Car_gesto_1.Ventana =  size(segmentos_1,2);
                    Features_result.Car_gesto_1.Etiquetas_gesto_1 = ones(length(Features_result.Car_gesto_1.VectorCaracteristicas_gesto_1),1);
                    % Move to the next segment
                    i = i + 1; 
                    
                    
                    
                    
                    
                    