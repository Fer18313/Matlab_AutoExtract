%% DEV FERNANDO SANDOVAL
% V1.0> CURRENTLY ONLY HANDLES 2 CLASSES, 2 DIFFERENT TYPES OF BIOELECTRIC
% SIGNALS ARE CONSIDERED AS CASE-SCENARIOS.

% EXTRACT SINGLE SEGMENTS FROM DETECTED EEG/EMG SIGNALS
% **PD> REQUIRES SegmentV2.m to be in the same file path

% MODIFY TO CONTROL
flag =0;

if flag == 0
%% Variables EMG
    emg_data = emg_struct_FistUp.data;
    emg_data_2 = emg_struct_FistDown.data;
    sample_rate = emg_struct_FistUp.sampling_frequency;
    sample_rate_2 = emg_struct_FistDown.sampling_frequency;
    lower_threshold = 0.0002;
    upper_threshold = 0.002;
    min_segment_length = 100;
else
%% Variables EEG
    emg_data = eeg_struct_Blink.data;
    emg_data_2 = eeg_struct_HeadDown.data;
    sample_rate = eeg_struct_Blink.sampling_frequency;
    sample_rate_2 = eeg_struct_HeadDown.sampling_frequency;
    lower_threshold = 0.0002;
    upper_threshold = 0.002;
    min_segment_length = 100;

end

%% Segmentation
[segments, emg1, segment_start, segment_end]= SegmentV2(emg_data, sample_rate, lower_threshold, upper_threshold, min_segment_length, 0);
[segments_2, emg2, segment_start_2, segment_end_2]= SegmentV2(emg_data_2, sample_rate_2, lower_threshold, upper_threshold, min_segment_length, 0);

%% N samples
n_sample = 1:segment_end(1) - segment_start(1) + 1;
n_sample_2 = 1:segment_end_2(1) - segment_start_2(1) + 1;

%% Define the directory where you want to save the individual segment files

% Allow the user to interactively select a folder using a dialog
saveDir = uigetdir('C:\', 'Seleccione dónde desea guardar las señales');

if saveDir == 0
    % The user canceled the folder selection, handle this case as needed
    error('Usuario cancelo acción.');
end

%% Iterate through segments and save them
if flag ==0
    for i = 1:length(segment_start)
        % Extract a single segment for FistUp
        FistUp_sample = emg1(segment_start(i):segment_end(i));

        % Define a filename for the current segment
        filename = sprintf('FistUp_segment_%d.mat', i);

        % Save the segment to the specified directory
        save(fullfile(saveDir, filename), 'FistUp_sample');
    end

    % Repeat the process for FistDown segments
    for i = 1:length(segment_start_2)
        % Extract a single segment for FistDown
        FistDown_sample = emg2(segment_start_2(i):segment_end_2(i));

        % Define a filename for the current segment
        filename = sprintf('FistDown_segment_%d.mat', i);

        % Save the segment to the specified directory
        save(fullfile(saveDir, filename), 'FistDown_sample');
    end
else 
    for i = 1:length(segment_start)
        % Extract a single segment for FistUp
        Blink_sample = emg1(segment_start(i):segment_end(i));

        % Define a filename for the current segment
        filename = sprintf('Blink_segment_%d.mat', i);

        % Save the segment to the specified directory
        save(fullfile(saveDir, filename), 'Blink_sample');
    end

    % Repeat the process for FistDown segments
    for i = 1:length(segment_start_2)
        % Extract a single segment for FistDown
        HeadDown_sample = emg2(segment_start_2(i):segment_end_2(i));

        % Define a filename for the current segment
        filename = sprintf('HeadDown_segment_%d.mat', i);

        % Save the segment to the specified directory
        save(fullfile(saveDir, filename), 'HeadDown_sample');
    end
    
end