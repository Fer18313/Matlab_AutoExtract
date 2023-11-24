function [segment_matrix, filtered_eeg_data,segment_start, segment_end] = SegmentV2EEG(eeg_data, sample_rate, alpha, min, window_size, plot_true)
% Segment V2 for EEG:
% The function will pre-process the input signal using a narrow and 
% band-pass filter combination, afterwards, calculating the alpha and beta brainwaves 
% as features of the signal for segmentation of brain activity. The detection
% of activity is possible with an adaptive threshold technique.
%
% FUNCTION DEVELOPED BY: FERNANDO SANDOVAL 
%% FILTER DESIGN
    % PRE-PROCESS DATA 
    % Define filter parameters for the bandpass filter
    wn = 45/(sample_rate/2); %normalizada
    wn2 = 0.5/(sample_rate/2);
    wn_banda = [wn2 wn];
    
    % Define notch filter parameters (e.g., for 60 Hz power line interference)
    notch_frequency = 50; % Adjust this to your specific power line frequency
    
    %% BAND-PASS FILTER
    % Design the Butterworth bandpass filter
    % FILTRO BUTTERWORTH
    orden = 4; %orden
    [b_bandpass, a_bandpass] = butter(orden,wn_banda,'bandpass'); 
    
    %% NOTCH FILTER
    % Design the notch filter
    wo = notch_frequency / (sample_rate / 2);
    bw = wo / 35; % You can adjust the bandwidth (bw) as needed
    [b_notch, a_notch] = iirnotch(wo, bw);

    
    %% FILTERING
    % Apply the notch filter to remove power line interference
    eeg_data_filtered = filtfilt(b_notch, a_notch, eeg_data);
    % Apply the band-pass filter to the filtered eeg signal
    filtered_eeg_data = filtfilt(b_bandpass, a_bandpass, eeg_data_filtered);
    


    %% TIME VECTOR FOR PLOT
    % Create a time vector for plotting
    time = (0:length(eeg_data) - 1) / sample_rate;


   %% AUTO-SEGMENT DETECT 
    [beta_wave,~ , ~, ~, ~] = extract_brainwaves(filtered_eeg_data, sample_rate, false);
   % Initialize variables to store segment start and end indices
    segment_start = [];
    segment_end = [];
    in_segment = false;
    feature_vectors = [];
    
    % Initialize adaptive thresholds
    lower_threshold = [];  % Initially empty
    upper_threshold = [];  % Initially empty
    
    % Initialize cell arrays to store segments and their lengths
    segments = {};
    
    for i = 1:(length(beta_wave) - window_size)
        % Calculate the absolute mean for the current window
        window_mean = mean(abs(beta_wave(i:i+window_size-1)));
        
        % Calculate adaptive thresholds based on a moving average of window_mean
        if i == 1
            % Initialize thresholds for the first window
            lower_threshold = window_mean;
            upper_threshold = window_mean;
        else
            % Update thresholds with a moving average approach
            lower_threshold = (1 - alpha) * lower_threshold + alpha * window_mean;
            upper_threshold = (1 - alpha) * upper_threshold + alpha * window_mean;
        end
        
        if in_segment
            % Check if the window_mean is below the lower_threshold, indicating the end of the segment
            if window_mean < lower_threshold
                in_segment = false;
                segment_end = [segment_end, i+window_size-1];
                
                % Extract the segment
                segment = filtered_eeg_data(segment_start(end):(i+window_size-1));
                
                % Calculate the absolute mean
                absolute_mean = mean(abs(segment));
                feature_vectors = [feature_vectors, absolute_mean];
                
                % Store the segment
                segments{end+1} = segment;
            end
        else
            % Check if the window_mean is above the upper_threshold, indicating the start of a new segment
            if window_mean >= upper_threshold
                in_segment = true;
                segment_start = [segment_start, i];
            end
        end
    end

    % Find the maximum segment length
    max_segment_length = max(cellfun(@length, segments));
    
    % Initialize a cell array to store the segments with uniform length
    filtered_segments = {};
    
    % Loop through the segments and filter them based on length
    for i = 1:length(segments)
        segment = segments{i};
        
        % Interpolate the segment to match the maximum segment length
        interpolated_segment = interpolateSegment(segment, max_segment_length);
        filtered_segments{end+1} = interpolated_segment;
    end

    % Initialize a matrix to store the segments with uniform length
    segment_matrix = zeros(length(filtered_segments), max_segment_length);

    % Fill the matrix with segments
    for i = 1:length(filtered_segments)
        segment = filtered_segments{i};
        % Cut the segment to the maximum desired length
        segment = segment(1:max_segment_length);
        % Store the modified segment in the matrix
        segment_matrix(i, :) = segment;
    end

    % PLOTS
    if plot_true == 1
        figure;

        % First Subplot
        subplot(2, 1, 1);
        plot(time, filtered_eeg_data, 'b', 'LineWidth', 1.5);
        xlabel('Time (s)');
        ylabel('Amplitude (mV)');
        title('Original Signal - Filtered');
        hold on
        plot(time, beta_wave, 'g','LineWidth',0.5);
        legend('eeg', 'banda beta');

        % Second Subplot
        subplot(2, 1, 2);
        plot(time, filtered_eeg_data);
        xlabel('Time (s)');
        ylabel('Amplitude');
        title('Filtered Signal - Segments');
        hold on;

        % Plot segments on the same subplot
        for i = 1:length(segment_end)
            start_idx = segment_start(i);
            end_idx = segment_end(i);
            plot(time(start_idx:end_idx), filtered_eeg_data(start_idx:end_idx), 'r');
        end
        legend('eeg', 'eeg Segments');

        hold off;
    end
end
