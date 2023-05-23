% ERG ANALYSIS SCRIPT
% Smith and Peters Labs Cardiff University UKDRI
% Originally written by Tim Johnston
% Adapted by Hannah Clarke 

%This code is written based on a 10000 samples per second
%txt files used should have 50000 data points. 

%The different parts of the ERG correspond to different time points:
%0-10000 = delay (no stimulus) 
%10000 = stimulius onset 
%10000-20000 stimulus on (depolarisation stage)
%20000 = stimulus off 
%up to 50000 return to baseline

%% WHAT YOU NEED TO CHANGE 
%1) path to directory of filenames file
%2) path to current file
%3) path "short path"
%4) Change ylim - limits of your y coordinates for graphing
%5) Last line - where to save things 
%6) Change count for how long your filenames txt file is 

%in the output file you will have 5 sets of data in the order of the
%filenames file. Columns in order represent:
%1) on_transient_amplitude_milivolts
%2) depolarisation_amplitude_milivolts at 1.5s
%3) Off transient 
%4) Thalf baseline return 
%5) Baseline return 

%% 1) Change this path to the directory of "filenames" file
id = importdata(''); % CHANGE ME: This file should be a list of all filenames 

for count = 1:n % CHANGE ME: Change n here to however many files you have 
count %this counts progress
part_id = strvcat(id{count});
 
currentfile = ['' part_id '/Ch10_Vin+.TXT']; %2) CHANGE ME: change to directory
shortpath = ['' part_id]; %3) CHANGE ME: change to directory

ChannelA = readmatrix(currentfile);
ChannelA = ChannelA(:,1);

%Calibration - records in Volts --> convert to mV 
ChannelA = ChannelA*100; %times a 1000 to convert into mv but have to componsate for the amplifier 0.1
%IMPORTANT - if amplififer value changes - change this here 

%% Section 1: establishing basic trace parameters 

yygraph = ChannelA; 
yy = smoothdata(yygraph,'movmean',200); %smoothed = yy
trace_start = yy(1:9800); %in the pre-stimulius delay
yyy = yy - mean(trace_start); %This is changing from the raw data to 0 as baseline
yyy_inverted = -yyy;

% This is getting the mean of the new baseline
new_trace_start = yyy(1:9800);
new_mean = mean(new_trace_start); %new mean is the average of the new baseline 

%% Section 2: finding on-transient peaks

on_transient_zone = yyy(9900:11000); % just after the 1s second time point as stimulus onset
stimulus_onset_zone = findchangepts(on_transient_zone,'MaxNumChanges',3,'statistic','linear');
[on_transient_peak,locs_on_transient] = findpeaks(on_transient_zone,'SortStr','descend','NPeaks',1);
location_of_on_transient = 9900 + locs_on_transient;

%% Section 3: finding value of depolarisation at 1.5s

% Have removed this and using half way through value instead 
% IMPORTANT: If you want to look at max depol - uncomment here 
%depolarisation_change_zone = yyy(1110:1980); % from onset to 1980 (just before the off transient) %might need to  change this 
%depolarisation_change_zone_inverted = -depolarisation_change_zone;
% [pks_max_depolarisation,locs_max_depolarisation] = findpeaks(depolarisation_change_zone_inverted,'SortStr','descend','NPeaks',1);
%locs_max_depolarisation = 1109 + locs_max_depolarisation;

locs_max_depolarisation = 15000;
pks_max_depolarisation = yyy(locs_max_depolarisation);

%% Section 4: finding off-transient peaks and values

off_transient_zone = yyy((19990:22000)); 
off_transient_zone_inverted = yyy_inverted((19990:22000)); 
[off_transient_peak,locs_off_transient] = findpeaks(off_transient_zone_inverted,'SortStr','descend','NPeaks',1);
stimulus_offset = mean(yyy(19790:19990)); %mean of what it is at that time
locs_off_transient = locs_off_transient + 19990;

%% Section 5: finding baseline return at the end of the trace 

return_to_baseline_zone = yyy(locs_off_transient:end); 
return_to_baseline_within_zone = find(return_to_baseline_zone >= 0);

if return_to_baseline_within_zone > 0
 return_to_baseline_location = return_to_baseline_within_zone(1) + locs_off_transient;
else
 return_to_baseline_location = 50001; 
end


%% Section 6: finding thalf for the max depolarisation - Uncomment if wish to find thalf 

% depolarisation_change_zone_for_thalf = yyy(location_of_on_transient:locs_max_depolarisation); 
% depolarisation_change_zone_inverted_for_thalf = -depolarisation_change_zone_for_thalf;
% 
% thalf_max_depolarisation_value = pks_max_depolarisation / 2;
% [~,thalf_for_max_depolarisation_location] = min(abs(depolarisation_change_zone_inverted_for_thalf - thalf_max_depolarisation_value));
% thalf_for_max_depolarisation_location = thalf_for_max_depolarisation_location + location_of_on_transient;
% thalf_for_max_depolarisation = yyy(thalf_for_max_depolarisation_location);


%% Section 7: Finding thalf for the baseline return  

thalf_return_to_baseline_zone = yyy(locs_off_transient:end); 
return_to_baseline_half_value = stimulus_offset / 2;

crossedthalf = find(thalf_return_to_baseline_zone>return_to_baseline_half_value);

if isempty(crossedthalf) == 1; % If it doesnt reach the half value  
    doesntreach=1; %used later if doesnt reached = 1 then it doesnt reach the thalf value 
else
    doesntreach = 0; %Does reach thalf value
    xcoordcrossedthalf = crossedthalf(1); % X coord of this half value (first point)
    thalf_for_baseline_return_location = locs_off_transient + xcoordcrossedthalf;
    thalf_for_baseline_return = yyy(thalf_for_baseline_return_location);
end;


%% Section 8: finding the same parameters with the raw data
%if the peaks in the smoothed trace are significantly different from
%those in the raw trace, the programme will automatically revert to using those
%from the raw trace. Therefore, the same parameters need to be calculated
%for the raw data.

raw_trace_start = yygraph(1:9800);
raw_yyy = yygraph - mean(raw_trace_start);
raw_yyy_inverted = -raw_yyy;

raw_on_transient_zone = raw_yyy(9900:11000);
[raw_on_transient_peak,raw_locs_on_transient] = findpeaks(raw_on_transient_zone, 'SortStr','descend','NPeaks',1);
raw_location_of_on_transient = 9900 + raw_locs_on_transient;

raw_off_transient_zone = raw_yyy((19990:22000)); 
raw_off_transient_zone_inverted = raw_yyy_inverted((19990:22000)); 
[raw_off_transient_peak,raw_locs_off_transient] = findpeaks(raw_off_transient_zone_inverted, 'SortStr','descend','NPeaks',1); 
raw_locs_off_transient = raw_locs_off_transient + 19990;

%% Section 9: The aforementioned rules determining which peaks should be used
% (A rule has also been made to determine when the smoothed or raw traces
% should be used for these calculations

if on_transient_peak < (0.95*(raw_on_transient_peak))
 on_transient_employed = raw_on_transient_peak;
else on_transient_employed = on_transient_peak;
end

if on_transient_peak < (0.95*(raw_on_transient_peak))
 on_transient_location_employed = raw_location_of_on_transient;
else on_transient_location_employed = location_of_on_transient;
end

if off_transient_peak < (0.95*(raw_off_transient_peak))
 off_transient_employed = raw_off_transient_peak;
else off_transient_employed = off_transient_peak;
end

if off_transient_peak < (0.95*(raw_off_transient_peak))
 off_transient_location_employed = raw_locs_off_transient;
else off_transient_location_employed = locs_off_transient;
end


 
%% Section 10: creating the trace, with rules that will only plot the points if certain criteria are met

figure
hold on
plot((raw_yyy),'color','[0.851,0.851,0.851]')
plot((yyy),'color','[0.451,0.451,0.451]')
xticks([1000 2000 3000 4000 5000]);
xticklabels({'1','2','3','4','5'});
ylim([-25 5]); %IMPORTANT: Change limits here for plotting 
ax = gca;
ax.FontSize = 14;

% Creating an easily-visible baseline:
hlinebase = refline(0,new_mean);
hlinebase.Color = 'k';
hlinebase.LineStyle = '--';
hlinebase.DisplayName = 'min amplitude';
xlabel('Time (s)','fontsize', 14);
ylabel('Voltage (mV)','fontsize', 14);

%For legend raw 1, smooth 2, baseline 3

if on_transient_employed > new_mean
plot(on_transient_location_employed,on_transient_employed,'v','MarkerFaceColor','[0.95686,0.42745,0.26275]','MarkerEdgeColor','k','MarkerSize', 8)
end 

plot(locs_max_depolarisation,yyy(locs_max_depolarisation),'o','MarkerFaceColor','[0.99608,0.87843,0.56471]','MarkerEdgeColor','k','MarkerSize', 8)


if -off_transient_employed < -stimulus_offset
 plot(off_transient_location_employed,-off_transient_employed,'^','MarkerFaceColor','[0.56863,0.74902,0.85882]','MarkerEdgeColor','k','MarkerSize', 8)
end 

if doesntreach == 0;
plot(thalf_for_baseline_return_location,return_to_baseline_half_value,'o','MarkerFaceColor','[0.27059,0.45882,0.70588]','MarkerEdgeColor','k','MarkerSize', 8)
end;


%Plot stimulus offset
plot(19790:19990,yyy(19790:19990),'x','MarkerFaceColor','[0.004,0.4,0.369]')

saveas(figure(count),[shortpath '']); %CHANGE ME: path to save as a matlab fig
saveas(figure(count),[shortpath '']); %CHANGE ME: path to save as a tif image 

%Legend
legend('Location','southeast','fontsize', 14)
legend('Raw ERG','Smoothed ERG','Baseline','On-transient peak','Depolarisation at 1.5s','Off-transient peak','Thalf baseline return', 'Pre off-transient')

saveas(figure(count),[shortpath '']); %CHANGE ME: path figure as a matlab fig
saveas(figure(count),[shortpath '']); %CHANGE ME: path save figure as a tif image 


%% Section 11: Calculations saving as a dot vector 

if on_transient_employed > new_mean %on_transient_amplitude_milivolts position 1
 all_results(count,1) = (on_transient_employed - new_mean); 
end

if new_mean > pks_max_depolarisation %depolarisation_amplitude_milivolts position 2
 all_results(count,2) = (pks_max_depolarisation -new_mean);
end

all_results(count,3) = -(off_transient_employed - abs(stimulus_offset)); %pos3 = off transient

 if doesntreach ==0; %If it does reach
all_results(count,4) = thalf_for_baseline_return_location / 10000; 
else %If it doesnt reach
all_results(count,4) = 0; %Make it equal 0
end; %Pos 4 = thalf baseline return

if return_to_baseline_location < 5001 %time_to_reach_baseline_seconds positon 5
all_results(count,5) = return_to_baseline_location / 10000;
else
end


end; %ends the for loop This makes the calculations and graphs for all of them 

save('', 'all_results'); %CHANGE ME: path for saving 

