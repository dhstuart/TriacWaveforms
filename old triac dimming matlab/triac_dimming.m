%triac dimming
%create arbitrary waveform profiles for california instruments 751ix

clc
clear all
close all
format compact

percent_area = [0 .25 .5 .75 .95];
% percent_area = [120
%     109.5
%     102
%     100.5
%     99
%     97.5
%     96
%     88.5
%     84
%     81
%     78
%     75
%     72
%     66
%     61.5
%     57
%     52.5
%     48
%     42
%     36
%     30
%     24]/120;

%percent dimmed (really percent light) is defined as a percentage of power to the lamp where 100%
%is full on, and 0% is full off

% mins = [20
% 25
% 30
% 35
% 40
% 65]/120;
% 
% num_points = 4;
% dum=0;
% for i= 1:length(mins)
%     for j = 0:num_points
%         dum=dum+1;
%         percent_area(dum) = ((1-mins(i))/num_points*j+mins(i));
%     end
% end
% percent_area2 = unique(percent_area);
% 
% percent_area2 = (0:.2:100)/100;
dim_levels = acos(-(percent_area*2-1))/pi;      %calculates time cutoff in sinewave corresponding to percent area dimmed.l
% dim_levels = acos((percent_area2*2-1))/pi;      %calculates time cutoff in sinewave corresponding to percent area dimmed.l

% path_name = '"C:\CI-PROGS\ixwavlib\Modulation.ABW"," "';
path_name = '"C:\CI-PROGS\ixwavlib\';

pts = 1024;
x = (0:1:1023)/1023*2*pi;
for i = 1:length(dim_levels)
    
    filename = sprintf('dim%04d.ABW',round(percent_area(i)*1000));
    
%     fid = fopen(filename, 'wt');
%     fprintf(fid, '%s\n',[path_name filename '"," "']);
    %     sprintf('%s\n',[path_name filename '"," "'])
    
    for j = 1:pts
        if j<(round(pts/2*dim_levels(i)))
            wave(j) = 0;
        elseif (j>pts/2) && (j<(pts/2+(round(pts/2*dim_levels(i)))))
            wave(j) = 0;
        else
            wave(j) = sin(2*pi*(j-1)/pts)*.99;
        end
        %         sprintf('%d,%d\n', j-1,wave(j))
        
%         fprintf(fid, '%d,%d\n', j-1,wave(j));
    end
    rms2(i) = rms(wave*171.5);
%     rms2(i) = rms(wave*169.7);

    %     figure
%     plot(x,wave,x,-cos(x)+1)
%     fclose(fid);
end


crest_factor = max(wave)/rms(wave)


