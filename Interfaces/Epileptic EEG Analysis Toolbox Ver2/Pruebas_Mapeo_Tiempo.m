t1 = hours(23.4167):seconds(60):hours(25);
t = hours(t1);
y = rand(1,length(t));
% for i=1:length(t)
%     if(t1(i)>= hours(24))
%         t(i) = t(i)+(24)
%     end
% end
plot(t,y);
xticks([hours(t1(1)),hours(t1(48)),hours(t1(95))])
xticklabels({datestr(t1(1),'HH:MM:SS'),datestr(t1(48),'HH:MM:SS'),datestr(t1(95),'HH:MM:SS')})


%%
[h, edf] = edfread('S013R13.edf');
eeg=edf(1,:);
tinicio=h.starttime;
fs = h.frequency(1);
ventana = 1;%Segundos
tchar = strsplit(tinicio,'.');
to_num = hours((str2double(tchar{1})+str2double(tchar{1})/60+str2double(tchar{1})/3600));
t = linspace(to_num,to_num+seconds(ventana),ventana*fs);
to_num = hours(to_num)+seconds(ventana);
figure (1)
t2 = hours(t);
plot(t2,eeg(1:fs*ventana));
midlab = t(1,round(length(t)/2));
endlab = t(1,length(t));
xticks([hours(t(1,1)),hours(midlab),hours(endlab)])
xticklabels({datestr(t(1,1),'HH:MM:SS'),datestr(midlab,'HH:MM:SS'),datestr(endlab,'HH:MM:SS')})
xlim([t2(1) t2(length(t2))])

muestraf_anterior = fs*ventana+1;

figure (2)
t = linspace(to_num,to_num+seconds(ventana),ventana*fs);
plot(t,eeg(muestraf_anterior:muestraf_anterior+fs*ventana));
to_num = hours(to_num)+seconds(ventana);
muestraf_anterior = muestraf_anterior+fs*ventana+1;
figure (3)
t = linspace(to_num,to_num+seconds(ventana),ventana*fs);
plot(t,eeg(1:fs*ventana));
xtickformat('hh:mm:ss')