[~] = autoextract_func_inter('FistUp.xlsx','FistDown.xlsx'); % CAN MODIFY TO INCLUDE MORE GESTURES
[~,~] = segment_auto_func(gesto_1, gesto_2)

% para segmentos 0.00005, 0.0002, 10, 1

[~]= SegmentV2(gesto.data, gesto.sampling_frequency, 0.0002, 0.002, 100, 1); 
