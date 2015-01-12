%triac dimming
%create arbitrary waveform profiles for california instruments 751ix

clc
clear all
close all
format compact

% percent_area = [0 .25 .5 .75 .95];
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

vrms_mins = [20
    25
    30
    35
    40
    65];

vrms_mins_ratio = vrms_mins/120;

% initial_dim_levels = acos((percent_area2*2-1))/pi

% vpeak = 120*sqrt(2);
% eqn = ((1/2*(pi-sin(2*pi)/2)-1/2*(x-sin(2*x)/2))/(pi-0)).^(1/2)*2.^(1/2)-V_percent_area(i);

% h = @(u)((1/2*(pi-sin(2*pi)/2)-1/2*(u-sin(2*u)/2))/(pi-0)).^(1/2)*2.^(1/2)-V_percent_area(i);


% eqn := ((1/2*(-sin(2*PI)/2)-1/2*(x-sin(2*x)/2))/(PI-0)).^(1/2)*2.^(1/2)-.5


syms t
% h2 = @(u)((1/2*(pi-sin(2*pi)/2)-1/2*(u-sin(2*u)/2))/(pi-0)).^(1/2)*2.^(1/2)

% V_percent_area = [.005 .5 .995];

%% ---------determine sine wave cut in times based on Vrms-------
guess = (1-vrms_mins_ratio)*pi;
for i = 1:length(vrms_mins_ratio)
    
    %     ts(i) = solve(vpeak*sqrt(1/2-(1/(2*pi))*(t-sin(2*t)/2))-vrms_mins(i))
    % ts(i) = solve(((1/2*(pi-sin(2*pi)/2)-1/2*(x-sin(2*x)/2))/(pi-0)).^(1/2)*2.^(1/2)-V_percent_area(i))
%     vrms_eqn = @(t)((1/2*(pi-sin(2*pi)/2)-1/2*(t-sin(2*t)/2))/(pi-0)).^(1/2)/2.^(1/2)-vrms_mins_ratio(i); %original
    vrms_eqn = @(t)((1/2*(pi-sin(2*pi)/2)-1/2*(t-sin(2*t)/2))/(pi-0)).^(1/2)*2.^(1/2)-vrms_mins_ratio(i); %with * instead of 0. why pi-0 and not pi-t???
    
    cut_in_times_V(i) = fzero(vrms_eqn,guess(i))     %time when the wave cuts from zero to sine based on Vrms
end

%% ----------determine initial power based on v(t) with cut in----------
%p=v^2=sin(t)^2
v(t) = sin(t);
p = v^2;
% p = @(t)sin(t).^2;
% p = sin(t).^2;
% p(t) = sin(t)^2
pwr_int = int(p,t,t,pi); %integral of power from t to pi

for i = 1:length(vrms_mins_ratio)
%     power_mins(i) = double(int(p,t,cut_in_times_V(i),pi)*(1/(pi-cut_in_times_V(i)))); %integrate power and evaluate between cut in time and pi   
%     power_avg_mins(i) = double(int(p,t,cut_in_times_V(i),pi)*(1/(pi-0))); %integrate power and evaluate between cut in time and pi   

    power_mins2(i) = double(int(p,t,cut_in_times_V(i),pi)); %integrate power and evaluate between cut in time and pi   (don't need average power because it's a linear factor that comes back out and messes up other calcs. Also, no R factor so not real power anyways)
    %     p2(i) = int(p,t,cut_in_times_V(i),pi); %integrate power and evaluate between cut in time and pi
end

%% ---------determine linear intervals in power between min and max ----------
dum = 0;
pmax = double(int(p,t,0,pi));
num_points = 4;
for i = 1:length(vrms_mins_ratio)
    i
    for j = 0:num_points
        j
        dum=dum+1;
        power_all(dum,1) = ((pmax-power_mins2(i))/num_points*j+power_mins2(i));  %quartiles of power to test at
    end
end

unique_power_all = unique(power_all);
%% --------- determine voltage sine wave cut off corresponding to integrated power ---
guess = (pi/2-unique_power_all)*1.8;

pwr_int = int(p,t,t,pi); %integral of power from t to pi


for i = 1:length(unique_power_all)
%         pwr_eqn = @(t)((1/2*(pi-sin(2*pi)/2)-1/2*(t-sin(2*t)/2))/(pi-0))-power_values(i);
%         cut_in_times_P(i) = fzero(pwr_eqn,guess(i));
    cut_in_times_P(i) = double(solve(pwr_int-(unique_power_all(i))));     %have to multiply unique_power_values*pi to get from avg to area under curve
end


%% ---------- create arbitrary waveform file -----------
path_name = '"C:\CI-PROGS\ixwavlib\';

pts = 1024;
x = (0:1:pts-1)/(pts-1)*2*pi;
for i = 1:length(cut_in_times_P)
        temp =  int((v*120*sqrt(2))^2,t,t,pi);      
    rms2 = sqrt(1/(pi-0)*temp);    
    rms3(i) = double(rms2(cut_in_times_P(i)));      %check to see if get same answer back
    filename = sprintf('dim%04d.ABW',round(rms3(i)/100*1000))
    
        fid = fopen(filename, 'wt');
%         fprintf(fid, '%s\n',[path_name filename '"," "']);
        fprintf(fid, '%s\n',[filename '"," "']);

        %         sprintf('%s\n',[path_name filename '"," "'])
    
    for j = 1:pts
        if j<(round(pts/(2*pi)*cut_in_times_P(i)))
            wave(j) = 0;
        elseif (j>pts/2) && (j<(pts/2+(round(pts/(2*pi)*cut_in_times_P(i)))))
            wave(j) = 0;
        else
            wave(j) = sin(2*pi*(j-1)/pts)*.99;
        end
%                 sprintf('%d,%d\n', j-1,wave(j))
        
                fprintf(fid, '%d,%d\n', j-1,wave(j));
    end
    
    
    %rmss = sqrt(1/(pi-t)*int(v^2,t,t,pi))
%   / pi   t   sin(2 t) \1/2 
%   | -- - - + -------- | 
%   | 2    2      4     | 
%   | ----------------- | 
%   \      pi - t       /
    

    rms4(i) = rms(wave*171.5);
    %     rms2(i) = rms(wave*169.7);
    
%         figure
%         plot(x,wave,x,-cos(x)+1)
        fclose(fid);
end
fclose all









%% ----------- determine Vrms to run at -----------------




% num_points = 4;
% dum=0;
% for i= 1:length(vrms_mins)
%     for j = 0:num_points
%         dum=dum+1;
%         percent_area(dum) = ((1-vrms_mins(i))/num_points*j+vrms_mins(i));
%     end
% end
% percent_area2 = unique(percent_area);
% 
% percent_area2 = (0:.2:100)/100;
% % dim_levels = acos(-(percent_area*2-1))/pi;      %calculates time cutoff in sinewave corresponding to percent area dimmed.l
% dim_levels = acos((percent_area2*2-1))/pi;      %calculates time cutoff in sinewave corresponding to percent area dimmed.l
% 
% % path_name = '"C:\CI-PROGS\ixwavlib\Modulation.ABW"," "';
% path_name = '"C:\CI-PROGS\ixwavlib\';
% % eqn = (1/2(t-sin(2*t)/2)-.064)
% 
% pts = 1024;
% x = (0:1:pts-1)/(pts-1)*2*pi;
% for i = 1:length(dim_levels)
%     
%     filename = sprintf('dim%04d.ABW',round(percent_area2(i)*1000));
%     
%     %     fid = fopen(filename, 'wt');
%     %     fprintf(fid, '%s\n',[path_name filename '"," "']);
%     %     sprintf('%s\n',[path_name filename '"," "'])
%     
%     for j = 1:pts
%         if j<(round(pts/2*dim_levels(i)))
%             wave(j) = 0;
%         elseif (j>pts/2) && (j<(pts/2+(round(pts/2*dim_levels(i)))))
%             wave(j) = 0;
%         else
%             wave(j) = sin(2*pi*(j-1)/pts)*.99;
%         end
%         %         sprintf('%d,%d\n', j-1,wave(j))
%         
%         %         fprintf(fid, '%d,%d\n', j-1,wave(j));
%     end
%     rms2(i) = rms(wave*171.5);
%     %     rms2(i) = rms(wave*169.7);
%     
%     %     figure
%     %     plot(x,wave,x,-cos(x)+1)
%     %     fclose(fid);
% end
% 
% 
% crest_factor = max(wave)/rms(wave)
% 
% 
