function [delta_wave, beta_wave, alpha_wave, gamma_wave, theta_wave] = extract_brainwaves(eeg_data, sample_rate, plot_true, zoom_in)
    % Preprocess EEG data to extract alpha and beta power.
    
    if nargin < 4
        zoom_in = false;
    end

    % Define filter parameters for the alpha, beta, gamma, delta, and theta bands
    low_cutoff_alpha = 8 / (sample_rate / 2);    % Alpha band (8-12 Hz)
    high_cutoff_alpha = 12 / (sample_rate / 2);
    wn_alpha = [low_cutoff_alpha high_cutoff_alpha];
    
    low_cutoff_beta = 12 / (sample_rate / 2);     % Beta band (13-30 Hz)
    high_cutoff_beta = 30 / (sample_rate / 2);
    wn_beta = [low_cutoff_beta high_cutoff_beta];
   
    low_cutoff_gamma = 30 / (sample_rate / 2);    % Gamma band (30-100 Hz)
    high_cutoff_gamma = 100 / (sample_rate / 2);
    wn_gamma = [low_cutoff_gamma high_cutoff_gamma];
    
    low_cutoff_delta = 1 / (sample_rate / 2);     % Delta band (1-3 Hz)
    high_cutoff_delta = 3 / (sample_rate / 2);
    wn_delta = [low_cutoff_delta high_cutoff_delta];
   
    low_cutoff_theta = 4 / (sample_rate / 2);    % Theta band (4-7 Hz)
    high_cutoff_theta = 7 / (sample_rate / 2);
    wn_theta = [low_cutoff_theta high_cutoff_theta];
    
    % Filter the EEG data
    orden = 4; % Order of the Butterworth filter
    [b_alpha, a_alpha] = butter(orden, wn_alpha, 'bandpass');
    [b_beta, a_beta] = butter(orden, wn_beta, 'bandpass');
    [b_gamma, a_gamma] = butter(orden, wn_gamma, 'bandpass');
    [b_delta, a_delta] = butter(orden, wn_delta, 'bandpass');
    [b_theta, a_theta] = butter(orden, wn_theta, 'bandpass');
    
    alpha_wave = filtfilt(b_alpha, a_alpha, eeg_data);
    beta_wave = filtfilt(b_beta, a_beta, eeg_data);
    gamma_wave = filtfilt(b_gamma, a_gamma, eeg_data);
    delta_wave = filtfilt(b_delta, a_delta, eeg_data);
    theta_wave = filtfilt(b_theta, a_theta, eeg_data);


    % Calculate the unilateral amplitude spectra
    delta_spectrum = abs(fft(delta_wave));
    beta_spectrum = abs(fft(beta_wave));
    alpha_spectrum = abs(fft(alpha_wave));
    gamma_spectrum = abs(fft(gamma_wave));
    theta_spectrum = abs(fft(theta_wave));

    % Frequency vector
    n = length(delta_wave);
    f = (0:(n/2 - 1)) * (sample_rate / n);

    % Plot the unilateral amplitude spectra with hold on
    if plot_true
        figure(1);
        if zoom_in
            xlim([0 30]); % Zoom in to the first 0-30 Hz
        end
        
        plot(f, delta_spectrum(1:n/2), 'DisplayName', 'Banda Delta');
        hold on
        plot(f, beta_spectrum(1:n/2), 'DisplayName', 'Banda Beta');
        plot(f, alpha_spectrum(1:n/2), 'DisplayName', 'Banda Alpha');
        plot(f, gamma_spectrum(1:n/2), 'DisplayName', 'Banda Gamma');
        plot(f, theta_spectrum(1:n/2), 'DisplayName', 'Banda Theta');
        
        hold off
        title('Espectro de Amplitud Unilateral Ondas Cerebrales', 'FontSize', 16);
        xlabel('Frecuencia (Hz)',  'FontSize', 16);
        ylabel('Amplitud',  'FontSize', 16);
        legend('Location', 'best', 'FontSize', 18);
        set(gca, 'FontSize', 14); 
    end
    % Plot the filtered signals if requested
    if plot_true
        t = (0:length(eeg_data) - 1) / sample_rate;
        if zoom_in
            % Zoom in to the first 0-5 seconds
            t_zoomed = t(t <= 2);
            alpha_zoomed = alpha_wave(1:length(t_zoomed));
            beta_zoomed = beta_wave(1:length(t_zoomed));
            gamma_zoomed = gamma_wave(1:length(t_zoomed));
            delta_zoomed = delta_wave(1:length(t_zoomed));
            theta_zoomed = theta_wave(1:length(t_zoomed));
        else
            t_zoomed = t;
            alpha_zoomed = alpha_wave;
            beta_zoomed = beta_wave;
            gamma_zoomed = gamma_wave;
            delta_zoomed = delta_wave;
            theta_zoomed = theta_wave;
        end
        
        figure(2);
        plot(t_zoomed, eeg_data(1:length(t_zoomed)), 'DisplayName', 'EEG filtrada', 'LineWidth', 1.5);
        hold on
        plot(t_zoomed, alpha_zoomed, 'DisplayName', 'Banda Alpha', 'LineWidth', 1.5);
        plot(t_zoomed, beta_zoomed, 'DisplayName', 'Banda Beta', 'LineWidth', 1.5);
        plot(t_zoomed, gamma_zoomed, 'DisplayName', 'Banda Gamma', 'LineWidth', 1.5);
        plot(t_zoomed, delta_zoomed, 'DisplayName', 'Banda Delta', 'LineWidth', 1.5);
        plot(t_zoomed, theta_zoomed, 'DisplayName', 'Banda Theta', 'LineWidth', 1.5);
        hold off
        
        title('EEG Data',  'FontSize', 16);
        xlabel('Tiempo (s)',  'FontSize', 16);
        ylabel('Amplitud (mV)',  'FontSize', 16);
        set(gca, 'FontSize', 14); 
        legend('Location', 'best', 'FontSize', 18);
    end
end
