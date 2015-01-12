%triac dimming
%create arbitrary waveform profiles for california instruments 751ix

clc
clear all
close all
format compact

percent_area = 0:.1:1;
dim_levels = acos(-(percent_area*2-1))/pi;
% path_name = '"C:\CI-PROGS\ixwavlib\Modulation.ABW"," "';
path_name = '"C:\CI-PROGS\ixwavlib\';

pts = 1024;
x = (0:1:1023)/1023*2*pi;
for i = 1:length(dim_levels)-1
    
    filename = sprintf('dim%02d.ABW',dim_levels(i)*100);
    
    fid = fopen(filename, 'wt');
    fprintf(fid, '%s\n',[path_name filename '"," "']);
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
        
        fprintf(fid, '%d,%d\n', j-1,wave(j));
    end
    figure
    plot(x,wave,x,-cos(x)+1)
    fclose(fid);
end



