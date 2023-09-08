%--------------------------------------------------------------------------
% Función base, tomada de la Epileptic EEG Analysis Toolbox Ver2 de David 
% Vela 2021, para features en dominio del tiempo. 
% Modificada por Camila Lemus, en septiembre 2022 para la obtención de 
% features en el dominio de la frecuencia de señales EEG.
% Universidad del Valle de Guatemala
%
% Features:
% Relative powers of the certain frequency bands are the most used 
% frequency-domain features in all fields of analysis of the EEG signals. 
% Several ratios between frequency bands are widely used as features in 
% the EEG signal analysis, i.e., θ/α, β/α, (θ + α)/β, 
% θ/β, (θ + α)/(α + β), γ/δ and (γ + β)/(δ + α).
%--------------------------------------------------------------------------

function [Matriz_features,channel_ventana,c] = FeaturesV3frecuencia(edf,fs,canales,muestras,c,op)
% ARGUMENTOS DE LA FUNCION
%edf:   archivo .edf con señal EEG a analizar
%canales: número de canales para encontrar features (de 1 a 4 canales)
%muestras: número de muestras para realizar ventanas
%op: vector de opciones

%Se arreglan las dimensiones para que se tengan vectores fila en caso
%la señal venga en vectores columna.
if size(edf,1)>size(edf,2)
    edf = edf';
end
ctot = size(edf,1);
eeg = zeros(length(edf),canales);
if c==0
    %Definir canales a analizar
    canales = ctot;
    eeg = edf';
else
    for i=1:canales
        eeg(:,i)= edf(c(i),:)';
    end
end

%Preprocesamiento: FILTROS
%Se crea un filtro pasa bandas con un filtro Butterworth pasa bajas
%y otro pasa altas.
Fclp = 85; %Frequencia de corte para el pasa bajas
Fchp = 0.5; %Frequencia de corte para el pasa altas
W_blp = Fclp/(fs/2); % Normalización de la frecuencia de corte pasa bajas
W_bhp = Fchp/(fs/2); % Normalización de la frecuencia de corte pasa altas
[blp,alp]= butter(2,W_blp, 'low'); % Filtro pasa bajo de segundo orden.
[bhp,ahp]= butter(2,W_bhp, 'high'); % Filtro pasa bajo de segundo orden.
%Se pasan ambos filtros 2 veces
channelsf1 = filtfilt(blp,alp,eeg);
channels = filtfilt(bhp,ahp,channelsf1);


%Realizar ventana
k=1;        %recorrer canales
j=0;
flag=0;
size_c = length(channels);
channel_ventana = zeros(size_c,canales);
if mod(size_c/muestras,1)~=0 %si es decimal
    if(((size_c/muestras)-round(size_c/muestras))<0)
        size_cint = round(size_c/muestras)-1;
    else
        size_cint = round(size_c/muestras);
    end
else
    size_cint = size_c/muestras;
end

%Subventanas para laz = zeros(length(eeg),canales);
zc = zeros(size_cint,canales);
mav = zeros(size_cint,canales);
desviacion = zeros(size_cint,canales);
Theta = zeros(size_cint,canales);
Beta = zeros(size_cint,canales);
Alpha = zeros(size_cint,canales);
Gamma = zeros(size_cint,canales);
%Ratios - salida features
ratio_1 = zeros(size_cint,canales);
ratio_2 = zeros(size_cint,canales);
ratio_3 = zeros(size_cint,canales);
ratio_4 = zeros(size_cint,canales);
ratio_5 = zeros(size_cint,canales);

curtosis = zeros(size_cint,canales);
lzx = zeros(size_cint,canales);
eac = zeros(size_cint,canales); %EAC
ventana_EA = 10;
%Muestras de cada subventana EAC
muestas_ventana_EA = round(muestras/ventana_EA);
if ((muestras - muestas_ventana_EA*ventana_EA)<0)
    muestas_ventana_EA = muestas_ventana_EA-1;
end
%Zero Crossing index function
max_amplitud = max(abs(channels))*0.02; % 2% de la amplitud de la señal
umbral = max(max_amplitud);
for i=1:canales
    z(:,i) =  ZC(channels(:,i),umbral)'; %Calcular todos los ZC de la señal
end
i=1;
while(1)
    
    channel_ventana(i,k) = channels(i,k);
    i = i+1;
    if(mod(i,(muestras))==0)      %Calcular caracteristicas de cada ventana
        %WindowSignal es un canal de la señal; dimension n x 1
        window_signal = channel_ventana((j*muestras)+1:i,k);
        flag = flag+1;
        
        if op(1) == 1 % θ/β
            Theta = bandpower(channel_ventana(:,k),fs,[4 8]); %theta (θ, 4–8 Hz)
            Beta = bandpower(channel_ventana(:,k),fs,[12 30]); %beta (β, 12–30 Hz
            ratio_1(flag,k) = Theta/Beta; % θ/β
            
        end
        
        if op(2) == 1 % β/α
            Beta = bandpower(channel_ventana(:,k),fs,[12 30]); %beta (β, 12–30 Hz
            Alpha = bandpower(channel_ventana(:,k),fs,[8 12]); %alpha (α, 8–12 Hz)
            ratio_2(flag,k) =  Beta / Alpha; % β/α
            
        end
        
        if op(3) == 1 % (θ + α)/β
            Theta = bandpower(channel_ventana(:,k),fs,[4 8]); %theta (θ, 4–8 Hz)
            Alpha = bandpower(channel_ventana(:,k),fs,[8 12]); %alpha (α, 8–12 Hz)
            Beta = bandpower(channel_ventana(:,k),fs,[12 30]); %beta (β, 12–30 Hz
            ratio_3(flag,k) =  (Theta+Alpha)/Beta; % (θ + α)/β
        end
        
        if op(4) == 1 % θ/α
            Theta = bandpower(channel_ventana(:,k),fs,[4 8]); %theta (θ, 4–8 Hz)
            Alpha = bandpower(channel_ventana(:,k),fs,[8 12]); %alpha (α, 8–12 Hz)
            ratio_4(flag,k) = Theta/Alpha; % θ/α
            
        end
        if op(5) == 1 % (θ + α)/(α + β)
            Theta = bandpower(channel_ventana(:,k),fs,[4 8]); %theta (θ, 4–8 Hz)
            Alpha = bandpower(channel_ventana(:,k),fs,[8 12]); %alpha (α, 8–12 Hz)
            Beta = bandpower(channel_ventana(:,k),fs,[12 30]); %beta (β, 12–30 Hz
            ratio_5(flag,k) = (Theta + Alpha)/(Alpha + Beta);% (θ + α)/(α + β)
            
        end
        
        if op(6) == 1 %Desviación
            desviacion(flag,k) = std(channel_ventana(:,k));
        end
        j= j+1;
    end
    if (i==size_c)
        k=k+1;
        flag=0;
        i=1;
        j=0;
    end
    if(k>canales)
        break;
    end
end
%Concatenar vector de características
a=0;
for i=1:canales
    totfeatures(:,i+a:((i+a)+5)) = [ratio_1(:,i),ratio_2(:,i),ratio_3(:,i),ratio_4(:,i),ratio_5(:,i),desviacion(:,i)];
    a=a+5;
end
resta=1;
%Se establece vfeatures antes para mejorar rendimiento
%vfeatures = zeros(1,4);
for j=1:canales
    for i=1:6
        if op(i)==1
            vfeatures(:,resta) = totfeatures(:,i); %eliminar columna no deseada
            resta=resta+1;
        end
    end
    
end
Matriz_features = vfeatures;
end