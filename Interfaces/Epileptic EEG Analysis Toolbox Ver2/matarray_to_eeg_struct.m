%Esta función permite que un array de datos pueda guardarse como un .mat
%con una estructura con el nombre requerido para poder ser utilizado en la
%Epileptic EEG Analysis Toolbox Ver2

function matarray_to_eeg_struct(varargin)    
    %{1}:savename = Nombre del .mat donde se guardará la estructura 
    %{2}:data_array = array con las señales EEG    
    %{3}:fs = frecuencia de muestreo
    %{4}:inchannels = array de caracteres con los nombres de los canales
    %Opcional:
    %{5}:slength = duración de la señal en segundos, dejar vacío si desea que
    %   la función establesta este dato por el usuario. Si no se indica, se
    %   calcula a partir de la fs y la cantidad de datos.
    savename = varargin{1};
    data_array = varargin{2};
    fs = varargin{3};
    inchannels = varargin{4};
    if length(varargin) == 5
        tiempoduracion = varargin{5};
    else
        tiempoduracion = length(data_array)/fs;
    end
    %Se procura que el arreglo sea vectores fila
    array_dim = size(data_array);
    if array_dim(1)>array_dim(2)
        data_array = data_array';
    end
    eeg_struct.data = data_array;
    eeg_struct.data_length_sec = tiempoduracion;
    eeg_struct.sampling_frequency = fs;
    eeg_struct.channels = inchannels;
    save(savename,'eeg_struct');
end
