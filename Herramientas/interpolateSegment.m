% Interpolación de un segmento de señal
% DEV: Fernando Sandoval, 2023

% interpolated_segment = interpolateSegment(segment, target_length)
% Input:
%   - segment: El segmento de señal que se va a interpolar.
%   - target_length: La longitud deseada para el segmento interpolado.
% Output:
%   - interpolated_segment: El segmento de señal interpolado con la longitud especificada.
function interpolated_segment = interpolateSegment(segment, target_length)

    % Calcula el factor de interpolación en función de la longitud deseada
    interpolation_factor = target_length / length(segment);
    
    % Crea un vector de tiempo original normalizado de 0 a 1
    original_time = linspace(0, 1, length(segment));    
    
    % Crea un vector de tiempo interpolado normalizado de 0 a 1 con la longitud deseada
    interpolated_time = linspace(0, 1, target_length);    
    
    % Aplica la interpolación cúbica utilizando la función interp1
    interpolated_segment = interp1(original_time, segment, interpolated_time, 'spline');
end


