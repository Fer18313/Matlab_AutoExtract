function [movements_segment, filtered_emg_data,segment_start, segment_end] = SegmentV2(emg_data, sample_rate, lower_threshold, upper_threshold, min_segment_length, plot_true)
% Segment V2:
% The function will pre-process the input signal using a narrow and 
% band-pass filter combination, afterwards, calculating the absolute mean 
% feature of the signal for segmentation of muscular activity. The detection
% of muscular activity is possible with a double threshold technique, and 
% a minimum segment length to avoid mistaken segments caused by noise/fake 
% threshold triggers.
%
% FUNCTION DEVELOPED BY: FERNANDO SANDOVAL 

%% FILTER DESIGN
    % PRE-PROCESS DATA 
    % Define filter parameters for the bandpass filter
    low_cutoff = 1;  % Adjust this to your desired lower cutoff frequency in Hz
    high_cutoff =30; % Adjust this to your desired higher cutoff frequency in Hz
    % Define notch filter parameters (e.g., for 60 Hz power line interference)
    notch_frequency = 60; % Adjust this to your specific power line frequency
   
    % Maximum order to consider for AR model
    max_order = 30; % Adjust as needed
    
%% PRE-WHITENING FILTER
    % Initialize variables to store the best order and minimum AIC
    best_order = 0;
    min_aic = Inf;
    
    % Initialize arrays to store AIC values
    aic_values = zeros(1, max_order);

    % Calculate AIC for different AR model orders
    for ar_order = 1:max_order
        [coeff_ar, noise_var] = aryule(emg_data, ar_order);
        aic = 2 * ar_order - 2 * log(noise_var);
        aic_values(ar_order) = aic;

        % Update best order if AIC is lower
        if aic < min_aic
            min_aic = aic;
            best_order = ar_order;
        end
    end

    % Apply the pre-whitening filter with the best order
    [coeff_ar, noise_var] = aryule(emg_data, best_order);
    whitened_emg_data = filter(coeff_ar, 1, emg_data) * sqrt(noise_var);

    %% BAND-PASS FILTER
    % Design the Butterworth bandpass filter
    [b_bandpass, a_bandpass] = butter(2, [low_cutoff / (sample_rate / 2), high_cutoff / (sample_rate / 2)], 'bandpass');

    %% NOTCH FILTER
    % Design the notch filter
    wo = notch_frequency / (sample_rate / 2);
    bw = wo / 35; % You can adjust the bandwidth (bw) as needed
    [b_notch, a_notch] = iirnotch(wo, bw);

    %% FILTERING
    % Apply the notch filter to remove power line interference
    emg_data_filtered = filtfilt(b_notch, a_notch, whitened_emg_data);
    % Apply the band-pass filter to the filtered EMG signal
    filtered_emg_data = filtfilt(b_bandpass, a_bandpass, emg_data_filtered);


    %% TIME VECTOR FOR PLOT
    % Create a time vector for plotting
    time = (0:length(emg_data) - 1) / sample_rate;


    %% AUTO-SEGMENT DETECT 
    % Initialize variables to store segment start and end indices
    segment_start = [];
    segment_end = [];
    in_segment = false;
    feature_vectors = [];
    movements_segment = [];

    % Calculate the absolute mean for a window of data points (adjust window size as needed)
    window_size = 5; % Adjust as needed
    for i = 1:(length(filtered_emg_data) - window_size)
        % Calculate the absolute mean for the current window
        window_mean = mean(abs(filtered_emg_data(i:i+window_size-1)));

        if in_segment
            % Check if the window_mean is below the threshold, indicating the end of the segment
            if window_mean <  lower_threshold
                in_segment = false;
                segment_end = [segment_end, i+window_size-1];
                % Check the segment length and exclude it if it's too short
                if (i+window_size-1) - segment_start(end) >= min_segment_length
                    % If the segment is long enough, include it in processing
                    % Extract the segment and calculate the absolute mean
                    segment = filtered_emg_data(segment_start(end):(i+window_size-1));
                    absolute_mean = mean(abs(segment));

                    % Store the feature vector (absolute mean) for this segment
                    feature_vectors = [feature_vectors, absolute_mean];
                    movements_segment = [movements_segment, segment];
                end
                % Clear the segment if it doesn't meet the length criteria
                if (i+window_size-1) - segment_start(end) < min_segment_length
                    segment_start(end) = [];
                    segment_end(end) = [];
                end
            end
        else
            % Check if the window_mean is above the threshold, indicating the start of a new segment
            if window_mean >= upper_threshold
                in_segment = true;
                segment_start = [segment_start, i];
            end
        end
    end
    %% PLOT THE SIGNALS
   if plot_true ==1 % Plot the original, whitened, and filtered EMG signals
    figure;
    subplot(2, 1, 1);
    plot(time, emg_data);
    xlabel('Time (s)');
    ylabel('Original Signal');
    title('Original Signal');

%     subplot(4, 1, 2);
%     plot(time, whitened_emg_data);
%     xlabel('Time (s)');
%     ylabel('Whitened EMG Signal');
%     title('Whitened EMG Signal');

    subplot(2, 1, 2);
    plot(time, filtered_emg_data);
    xlabel('Time (s)');
    ylabel('Signal');
    title('Filtered Signal - Segments');

%     subplot(3, 1, 3);
%     plot(time, filtered_emg_data);
%     xlabel('Time (s)');
%     ylabel('Signal');
%     title('Segments');

    hold on; % Enable overlaying the segments on the same plot
    % Plot segments on the same subplot
    for i = 1:length(segment_end) % Use segment_end for iteration
        start_idx = segment_start(i);
        end_idx = segment_end(i);

        plot(time(start_idx:end_idx), filtered_emg_data(start_idx:end_idx), 'r'); % Use 'r' for red color
    end
    hold off; % Disable overlaying
   else
       %break
   end
end

