function [segments] = segment_auto_func(signal, alpha, window_size)
% DEV: Fernando Sandoval
% Code for automatic extraction of segments according to muscle activation
% (double threshold values are set inside this function). 
% Feel free to modify as you would best find suitable.

% EXTRACT SINGLE SEGMENTS FROM DETECTED EEG/EMG SIGNALS
% **PD> REQUIRES SegmentV2.m to be in the same file path



eeg_data = signal.data;
sample_rate = signal.sampling_frequency;

%% Segmentation
[segments, eeg1, segment_start, segment_end]= SegmentV2EEG(eeg_data, sample_rate,alpha,window_size,0);

%% N samples
n_sample = 1:segment_end(1) - segment_start(1) + 1;

%% Define the directory where you want to save the individual segment files

% Allow the user to interactively select a folder using a dialog
saveDir = uigetdir('C:\', 'Seleccione dónde desea guardar las señales');

if saveDir == 0
    % The user canceled the folder selection, handle this case as needed
    error('Usuario cancelo acción.');
end

%% Iterate through segments and save them
   gesto_sample = struct();
for i = 1:length(segment_start)
    % Extract a single segment for FistUp
    gestureData = eeg1(segment_start(i):segment_end(i));
    
    % Define a filename for the current segment
    filename = sprintf('gesto_segment_%d.mat', i);
    gesto_sample.data = gestureData;
    gesto_sample.sampling_frequency = sample_rate; %Fs 
    % Save the segment to the specified directory
    save(fullfile(saveDir, filename), 'gesto_sample');
end




