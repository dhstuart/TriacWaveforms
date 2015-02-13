clear all
close all
clc

syms t
c = .1:.1:1;
for i = 1:length(c)
    cutInTimesP(i) = double(solve(t/2-1/4*sin(2*t)+pi/2*(c(i)-1)==0,t));
end

pts = 1024;
x = (0:1:pts-1)/(pts-1)*2*pi;
v(t) = sin(t);
for i = 1:length(cutInTimesP)
    for j = 1:pts
        if j<(round(pts/(2*pi)*cutInTimesP(i)))
            wave(j) = 0;
        elseif (j>pts/2) && (j<(pts/2+(round(pts/(2*pi)*cutInTimesP(i)))))
            wave(j) = 0;
        else
            wave(j) = sin(2*pi*(j-1)/pts);%*.99;
        end
    end
    rms4(i) = rms(wave*120*sqrt(2));
    filename = sprintf('dim%04d.ABW',round(rms4(i)/100*1000));
    fid = fopen(filename, 'wt');
    fprintf(fid, '%s\n',[filename '"," "']);
    
    for j = 1:pts
        fprintf(fid, '%d,%d\n', j-1,wave(j));
    end
    
    figure
    plot(x,wave)
    fclose(fid);
    wave2(i,:) = wave;
end
% for i = 1:length(cut_in_times_P)
% trapz(x(1:end/2),wave2(i,1:end/2).^2)./(trapz(x(1:end/2),wave2(end,1:end/2).^2))
%
% end
fclose all