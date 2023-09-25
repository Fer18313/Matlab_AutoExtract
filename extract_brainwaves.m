function [delta_wave, beta_wave, alpha_wave, gamma_wave, theta_wave] = extract_brainwaves(eeg_data, sample_rate, plot_true)
    % Preprocess EEG data to extract alpha and beta power.

    % Define filter parameters for the alpha and beta bands
    low_cutoff_alpha = 8 / (sample_rate / 2);    % Alpha band (8-12 Hz)
    high_cutoff_alpha = 12 / (sample_rate / 2);
    wn_alpha = [low_cutoff_alpha high_cutoff_alpha];
    
    low_cutoff_beta = 12 / (sample_rate / 2);     % Beta band (13-30 Hz)
    high_cutoff_beta = 30 / (sample_rate / 2);
    wn_beta = [low_cutoff_beta high_cutoff_beta];
   
     % Define filter parameters for the alpha and beta bands
    low_cutoff_gamma = 30 / (sample_rate / 2);    % Alpha band (8-12 Hz)
    high_cutoff_gamma = 100 / (sample_rate / 2);
    wn_gamma = [low_cutoff_gamma high_cutoff_gamma];
    
    low_cutoff_delta = 1 / (sample_rate / 2);     % Beta band (13-30 Hz)
    high_cutoff_delta = 3 / (sample_rate / 2);
    wn_delta = [low_cutoff_delta high_cutoff_delta];
   
   
     % Define filter parameters for the alpha and beta bands
    low_cutoff_theta = 4 / (sample_rate / 2);    % Alpha band (8-12 Hz)
    high_cutoff_theta = 7 / (sample_rate / 2);
    wn_theta = [low_cutoff_theta high_cutoff_theta];
    
  
    
    % Filter the EEG data
    % FILTRO BUTTERWORTH
    orden = 4; %orden
    [b_bandpass, a_bandpass] = butter(orden,wn_alpha,'bandpass');
    [d_bandpass, c_bandpass] = butter(orden,wn_beta,'bandpass');
    [f_bandpass, e_bandpass] = butter(orden,wn_gamma,'bandpass');
    [h_bandpass, g_bandpass] = butter(orden,wn_delta,'bandpass');
    [j_bandpass, i_bandpass] = butter(orden,wn_theta,'bandpass');
    
    
    alpha_wave = filtfilt(b_bandpass, a_bandpass, eeg_data);
    beta_wave = filtfilt(d_bandpass, c_bandpass, eeg_data);
    gamma_wave = filtfilt(f_bandpass, e_bandpass, eeg_data);
    delta_wave = filtfilt(h_bandpass, g_bandpass, eeg_data);
    theta_wave = filtfilt(j_bandpass, i_bandpass, eeg_data);

    % Plot the filtered signals if requested
    if plot_true
        t = (0:length(eeg_data) - 1) / sample_rate;
        figure;
        subplot(3, 1, 1);
        plot(t, eeg_data, 'DisplayName', 'EEG filtrada');
        hold on
        plot(t, alpha_wave, 'DisplayName', 'Banda Alpha');
        plot(t, beta_wave, 'DisplayName', 'Banda Beta');
        plot(t, gamma_wave, 'DisplayName', 'Banda Gamma');
        plot(t, delta_wave, 'DisplayName', 'Banda Delta');
        plot(t, theta_wave, 'DisplayName', 'Banda Theta');
        hold off
        title('EEG Data');
        xlabel('Time (s)');
        ylabel('Amplitude');
        legend('Location', 'best');

        subplot(3, 1, 2);
        plot(t, delta_wave, 'DisplayName', 'Banda Delta');
        title('Delta Band Filtered EEG');
        xlabel('Time (s)');
        ylabel('Amplitude');
        legend('Location', 'best');

        subplot(3, 1, 3);
        plot(t, beta_wave, 'DisplayName', 'Banda Beta');
        title('Beta Band Filtered EEG');
        xlabel('Time (s)');
        ylabel('Amplitude');
        legend('Location', 'best');
    end
end





  