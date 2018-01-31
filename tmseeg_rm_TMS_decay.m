% Author: Matthew Frehlich, Ye Mei, Luis Garcia Dominguez, Faranak Farzan
%         2016
%         Ben Schwartzmann 
%         2017

% tmseeg_rm_TMS_decay() - displays largest components
% output by ICA1 step, with topographic maps and a display that show the
% updated pulse based on component removal
% 
% Inputs:  A        - parent GUI structure
%          step_num - step number of tmseeg_rm_TMS_decay in workflow

% Display window interface:
%       "Component Display" [tightsubplot] Displays ICA1 component averaged
%       across trials
%       "Scalp Maps" [topoplot] - Topographic plots of the ICA1 component
%       based on a standard electrode configuration
%       "Save" [Button] - saves and removes the selected ICA1 components
%       "Before Plot" [plot] Left plot, shows the overlain trials
%       averaged across all channels
%       "After Plot" [plot] - updates with selection of ICA1
%       components for removal to display the original plot reprojecteed
%       without the removed ICA1 components

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

function [] = tmseeg_rm_TMS_decay(A, step_num)

%Check if previous steps were done
if tmseeg_previous_step(step_num)
    return
end

global EEG times backcolor VARS xmin xmax
xmin = -150;
xmax = 150 + VARS.PULSE_DURATION;

% Data load
[~, EEG] = tmseeg_load_step(step_num);

if isfield(EEG, 'custom')
    times = EEG.custom.times;
else
    times = EEG.times;
end

%----------------------------GUI Display-----------------------------------

S.fh        = figure('Units','normalized',...
                     'Position',[0.05 0.1 0.9 .85],...
                     'Menubar','none',...                      
                     'Name','plot_ica1',...
                     'Numbertitle','off',...
                     'Color',backcolor,...
                     'Resize','off',...
                     'DockControls','off');
S.axSp      = tight_subplot(2,15,[0 .025],[.5 .01],[.05 .03]);
S.axBef     = axes('Position',[.05 .08 .42 .3]);
S.axAft     = axes('Position',[.53 .08 .42 .3]);
S.pb_save   = uicontrol('Style','push',...
                    'Units','normalized',...
                    'Position',[0.4 0.4060 0.2 0.0499],... 
                    'Fontsize',12,...
                    'String','Save and Remove',...
                    'Callback',{@pb_save_call,S,A,step_num});
tbpos        = .063:.063:1;

% Selection buttons for component removal
for k = 1:15
    S.tb_selc(k) = uicontrol('Style','radiobutton',...
        'Units','normalized',...
        'Position',[tbpos(k) 0.5141    0.0151    0.0416],...
        'Fontsize',12,...
        'Value',0,...
        'Callback',{@pb_selected_ica_call,S});
end


% calculating the variance explained by the components
mact = mean(eeg_getdatact(EEG,'component',1:size(EEG.icawinv,2)),3);
twin = times > xmin & times < xmax; 

for k=1:size(EEG.icawinv,2)
      a = EEG.icawinv(:,k)*mact(k,:);   %project components
      v(k) = max(abs(max(a(:,twin),[],2)-min(a(:,twin),[],2))); %#ok %variance
end

[~, I] = sort(v,'descend'); % sorting in order of variance
S.I = I;

temp_times = min(times):1000/EEG.srate:max(times);
%temp_times = EEG.times; NEED THIS FOR rTMS data ... NOTE
seg = find(temp_times>xmin & temp_times<xmax);
x = temp_times(seg);

%Plot components, topo maps
for k = 1:15
  y = mact(I(k),seg,:);
  plot(S.axSp(k),x,y,'linewidth',1) %Components
  set(S.axSp(k), 'xlim',[xmin xmax])
  axes(S.axSp(k+15)) %#ok
  topoplot(EEG.icawinv(:,I(k)), EEG.chanlocs); %Scalp maps
end

ylabel(S.axSp(1),['Amplitude (' char(0181) 'V)'])
S.component_lbl = uicontrol('style','text',...
                    'units','normalized',...
                    'backgroundcolor',backcolor,...
                    'position',[0.47 0.67 0.07 0.03],...
                    'String','Time (ms)');
y_temp = mean(EEG.data,3);

% Double Pulse Paradigm case
if(isfield(EEG,{'TMS_period2remove_b'}))
    ix = min(EEG.TMS_period2remove_b);
    EEG_temp = y_temp;
    rm_pulse_fill = NaN(size(EEG_temp,1),length(EEG.TMS_period2remove_b));
    y_temp = cat(2,EEG_temp(:,1:ix-1),rm_pulse_fill,EEG_temp(:,ix:end));
end

%Insert NaN values to fill space where TMS pulse was removed
ix = min(EEG.TMS_period2remove_1);
EEG_temp = y_temp; 
rm_pulse_fill = NaN(size(EEG_temp,1),length(EEG.TMS_period2remove_1));
y_temp = cat(2,EEG_temp(:,1:ix-1),rm_pulse_fill,EEG_temp(:,ix:end));
y = y_temp(:,seg)';


%Plot Data channels overlain, averaged across trials
plot(S.axBef,x,y)
set(S.axBef, 'xlim',[xmin xmax],'ylim',[min(min(y))-20 max(max(y))+20])
title(S.axBef,'Before component removal')
title(S.axAft,'After component removal')
xlabel(S.axBef, 'Time (ms)')
xlabel(S.axAft, 'Time (ms)')
ylabel(S.axBef, ['Amplitude (' char(0181) 'V)'])
guidata(S.fh,S);
end


function [] = pb_selected_ica_call(varargin)
% Called by selection of an ICA component radio button.  Based on
% components selected by user, removes components from data and plots on
% S.axAft.

global EEG times VARS
xmin = -150;
xmax = 150 + VARS.PULSE_DURATION;


S = varargin{3};  % Get the structure.
S = guidata(S.fh);
ind = S.I;
selected = find(cell2mat(get(S.tb_selc,'value')));  % Get the users choice.
projection = eeg_getdatact(EEG,'rmcomps',ind(selected)); %#ok

%Insert NaN values to fill space where TMS pulse was removed

temp_times = min(times):1000/EEG.srate:max(times);
seg = find(temp_times>xmin & temp_times<xmax);
x = temp_times(seg);

proj_temp = mean(projection,3);

% Double Pulse Paradigm case
if(isfield(EEG,{'TMS_period2remove_b'}))
    ix = min(EEG.TMS_period2remove_b);
    rm_pulse_fill = NaN(size(proj_temp,1),length(EEG.TMS_period2remove_b));
    proj_temp = cat(2,proj_temp(:,1:ix-1),rm_pulse_fill,proj_temp(:,ix:end));
end

%Insert NaN values to fill space where TMS pulse was removed
ix = min(EEG.TMS_period2remove_1);
rm_pulse_fill = NaN(size(proj_temp,1),length(EEG.TMS_period2remove_1));
proj_temp = cat(2,proj_temp(:,1:ix-1),rm_pulse_fill,proj_temp(:,ix:end));
y = proj_temp(:,seg)';

% Plot updated data with component removed
plot(S.axAft,x,y)
title(S.axAft,'After component removal')
set(S.axAft, 'xlim',[xmin xmax])
ylabel(S.axAft, ['Amplitude (' char(0181) 'V)'])
xlabel(S.axAft, 'Time (ms)')
guidata(S.fh,S);
end

function [] = pb_save_call(varargin)
%Called by selecting the S.pb_save button object.  Saves original ica
%weight matrix as EEG.decay_winv, removes components based off the user
%selection.  Saves deleted component indices as EEG.decaycomp_removed.

global EEG

%Data Load
S           = varargin{3};  % Get the structure.
S           = guidata(S.fh);
A           = varargin{4}; %Get main GUI info
step_num    = varargin{5};
ind         = S.I;
selected    = find(cell2mat(get(S.tb_selc,'value'))); 
disp(S.I(1:5))

%Save, remove selected components
EEG.decay_icawinv     = EEG.icawinv;
EEG = pop_subcomp( EEG, ind(selected), 0); % remove components
EEG.decaycomp_removed = ind(selected);
disp(ind(selected))
EEG = eeg_checkset( EEG );

[files, ~] = tmseeg_load_step(step_num);
tmseeg_step_check(files, EEG, A, step_num);
close;

end

