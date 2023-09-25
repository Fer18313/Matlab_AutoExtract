function [segment_matrix, filtered_eeg_data,segment_start, segment_end] = SegmentV2EEG(eeg_data, sample_rate,alpha, window_size, plot_true)
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
    max_order = 100;
 
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

%% PRE-WHITENING FILTER
    % Initialize variables to store the best order and minimum AIC
    best_order = 0;
    min_aic = Inf;
    
    % Initialize arrays to store AIC values
    aic_values = zeros(1, max_order);

    % Calculate AIC for different AR model orders
    for ar_order = 1:max_order
        [coeff_ar, noise_var] = aryule(eeg_data, ar_order);
        aic = 2 * ar_order - 2 * log(noise_var);
        aic_values(ar_order) = aic;

        % Update best order if AIC is lower
        if aic < min_aic
            min_aic = aic;
            best_order = ar_order;
        end
    end

    % Apply the pre-whitening filter with the best order
    [coeff_ar, noise_var] = aryule(eeg_data, best_order);
    whitened_eeg_data = filter(coeff_ar, 1, eeg_data) * sqrt(noise_var);
    
    
    
    %% FILTERING
    % Apply the notch filter to remove power line interference
    eeg_data_filtered = filtfilt(b_notch, a_notch, whitened_eeg_data);
    % Apply the band-pass filter to the filtered EMG signal
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
    min_segment_length = 100;
    % Initialize adaptive thresholds
    lower_threshold = [];  % Initially empty
    upper_threshold = [];  % Initially empty
 % Initialize cell arrays to store segments and their lengths
segments = {};
segment_lengths = [];

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
            % Check the segment length and exclude it if it's too short
            if (i+window_size-1) - segment_start(end) >= min_segment_length
                % If the segment is long enough, include it in processing
                % Extract the segment
                segment = filtered_eeg_data(segment_start(end):(i+window_size-1));
                
                % Calculate the absolute mean
                absolute_mean = mean(abs(segment));
                feature_vectors = [feature_vectors, absolute_mean];
                
                % Store the segment and its length
                segments{end+1} = segment;
                segment_lengths(end+1) = length(segment);
            end
            % Clear the segment if it doesn't meet the length criteria
            if (i+window_size-1) - segment_start(end) < min_segment_length
                segment_start(end) = [];
                segment_end(end) = [];
            end
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
max_segment_length = mean(segment_lengths);
max_segment_length = round(max_segment_length);
% Initialize a matrix to store the segments
segment_matrix = zeros(length(segments), max_segment_length);

% Fill the matrix with segments, either cutting or zero-padding as needed
for i = 1:length(segments)
    segment = segments{i};
    % Check if the segment length is greater than the maximum desired length
    if length(segment) > max_segment_length
        % Cut the segment to the maximum desired length
        segment = segment(1:max_segment_length);
    elseif length(segment) < max_segment_length
        % Zero-pad the segment to the maximum desired length
        padding_length = max_segment_length - length(segment);
        segment = [segment, zeros(1, padding_length)];
    end
    
    % Store the modified segment in the matrix
    segment_matrix(i, :) = segment;
end

 %% PLOT THE SIGNALS
 
if plot_true == 1
    figure;

    % First Subplot
    subplot(2, 1, 1);
    plot(time, eeg_data, 'b', 'LineWidth', 1.5);
    xlabel('Tiempo (s)');
    ylabel('Amplitud');
    title('Señal original - No Filtrada');
    hold on;
    plot(time, beta_wave, 'g', 'LineWidth', 1.5);
    hold off;
    
    % Add a legend for the first subplot
    legend('EEG', 'Banda Beta');

    % Second Subplot
    subplot(2, 1, 2);
    plot(time, filtered_eeg_data);
    xlabel('Tiempo (s)');
    ylabel('Amplitud');
    title('Señal Filtrada - Segmentos');
    hold on;
    
    % Plot segments on the same subplot
    for i = 1:length(segment_end)
        start_idx = segment_start(i);
        end_idx = segment_end(i);
        plot(time(start_idx:end_idx), filtered_eeg_data(start_idx:end_idx), 'r');
    end
   legend('EEG','segmento EEG');

    hold off;



end


end



