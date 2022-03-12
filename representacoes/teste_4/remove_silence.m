% function [outputArg1,outputArg2] = remove_silence(inputArg1,inputArg2)
% %REMOVE_SILENCE Summary of this function goes here
% %   Detailed explanation goes here
% outputArg1 = inputArg1;
% outputArg2 = inputArg2;
% end

[data, fs] = audioread('../base_portuguese/2/p0984402b6241414d970ef97c4afba121_s00_a01.wav');
data = mean(data,2);
f_dur=0.1;
f_len=f_dur*fs;
N = length(data);
no_frames=ceil(N/f_len);
new_data = zeros(N,1);
count=0;
frame = zeros(f_len,1);
for k=1:no_frames
    frame=data((k-1)*f_len+1:f_len*k);
    
    max_val=max(frame);
    if(max_val>0.005)
        count=count+1;
        new_data((count-1)*f_len+1:count*f_len)=frame;
    end
end
figure(1);
plot(data);
figure(2);
plot(new_data);
sound(data,32000,8);
pause(5);
sound(new_data,32000,8);