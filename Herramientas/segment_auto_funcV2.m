function [segments] = segment_auto_func(signal, alpha,min_window, window_size)
% DEV: Fernando Sandoval
% Code for automatic extraction of segments according to muscle activation
% (double threshold values are set inside this function). 
% Feel free to modify as you would best find suitable.

% EXTRACT SINGLE SEGMENTS FROM DETECTED EEG/EMG SIGNALS
% **PD> REQUIRES SegmentV2.m to be in the same file path

% SEGMENTATION DETECTION
emg_data = signal.data;
sample_rate = signal.sampling_frequency;

%% Segmentation
[segments, emg1, segment_start, segment_end]= SegmentV2(emg_data, sample_rate,alpha, min_window,window_size,0);

%% Define the directory where you want to save the individual segment files

% Allow the user to interactively select a folder using a dialog
saveDir = uigetdir('C:\', 'Seleccione dónde desea guardar las señales');

if saveDir == 0
    % The user canceled the folder selection, handle this case as needed
    error('Usuario cancelo acción.');
end

%% Iterate through segments and save them
   gesto = struct();
for i = 1:size(segments,1)
    gestureData = segments(i,:);
    
    % Define a filename for the current segment
    filename = sprintf('gesto_segment_%d.mat', i);
    gesto.data = gestureData;
    gesto.sampling_frequency = sample_rate; %Fs 
    gesto.data_length_sec = length(gestureData)/sample_rate;
    % Save the segment to the specified directory
    save(fullfile(saveDir, filename), 'gesto');
end




