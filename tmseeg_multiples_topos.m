% Author: Matthew Frehlich, Ye Mei, Luis Garcia Dominguez,Faranak Farzan
% 2016

% tmseeg_multiples_topos() - displays ICA components
% output by ICA2 step, with topographic maps for each component.  Allows
% analysis and removal of artifacts.
% 
% inputs:  A        - parent GUI structure
%          name     - dataset file name
%          EEGE     - input EEG dataset in .set format
%          step_num - step number of tmseeg_rm_TMS_decay in workflow

% Display window interface:
%       "Scalp Maps" [topoplot] Displays ICA2 topographic plots for
%       each component output from ICA2
%       "Component Tags" [button] - displays current artifact type (if
%       any), opens component analysis when selected
%       "Update" [Button] - reprojects data and displays averaged data
%       with the selected components removed
%       "Save" [Button] - saves and removes the selected components from
%       the EEG dataset


% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

function tmseeg_multiples_topos(EEG,name,A,step_num)
global I comptype backcolor VARS chans_rm
chans_rm=[];
S.topos = figure('menubar','none',...
              'Toolbar','none',...
              'Units','normalized',...
              'tag','TOPOS',...
              'name','ICA2 Components Topo',...
              'numbertitle','off',...
              'resize','off',...
              'color',backcolor,...
              'Position',[0 0.0381 1 0.9152],...
              'DockControls','off');
          
label   = {'TMS','EOG','EMG','AEP','Elect','BShift','EKG','Other'};
S.step_num = step_num;
% Determining layout of subplots based on number of ICA components
fact = [];
for k=1:7
    for j=k:k+3
        fact = [fact; k j j*k];
    end
end
N       = size(EEG.icawinv,2);
n       = find(fact(:,3)>=N,1,'first');

%-----------------kurtosis-based estimation of Electrode artifacts---------
kthre   = VARS.KURTOSIS_THRESH;
t       = EEG.times>0 & EEG.times<1000;
EEGdata = EEG.data(setdiff(1:EEG.nbchan,chans_rm),t,:);


a = icavar(EEGdata(:,:),EEG.icaweights,EEG.icasphere,0);
a = reshape(a,[N size(EEGdata,2) size(EEG.data,3)]);
r = sum(mean(a,3),2);
r       = 100.*r./mean(std(EEGdata(:,:),[],2));
[~,I]   = sort(abs(r),'descend');
tmseeg_displ_comp(comptype,I)

if ~isfield(EEG,'comptype')
    kurt    = kurtosis(EEG.icawinv);
    kurt    = kurt(I)>kthre;
end

%----------------------------EOG artifact estimation-----------------------
blink=zeros(1,size(EEG.icawinv,2));

CBI=zeros(size(EEG.icawinv));

for i=1:size(EEG.icawinv,1)
    for j=1:size(EEG.icawinv,2)
        CBI(i,j)=abs(EEG.icawinv(i,j))/sqrt(sum(EEG.icawinv(i,:).^2));
    end
end

[px,py] = cart2sph([EEG.chanlocs.X],[EEG.chanlocs.Y],[EEG.chanlocs.Z]);
theta = px/pi*180; % azimuth coordinate
phi = py/pi*180; % polar coordinate
frontalelec = (abs(theta) <= 30) & (abs(phi) <= 30);
frontalelec2 = (abs(theta) <= 60) & (abs(theta) > 30) & (abs(phi) <= 30);

%potential_blink
[~,potential_blink]=max(sum(CBI(frontalelec,:)));

%check with frontal activity
feature = mean(abs(EEG.icawinv(frontalelec,potential_blink)))>mean(abs(EEG.icawinv(frontalelec2,potential_blink)));

blink(I==potential_blink)=double(feature);

%----------------------------EMG artifact estimation-----------------------

comp_count_eeg = 1;
freq_matrix = zeros(length(comptype),2);
for j = 1:length(comptype)
        icaacttmp = (EEG.icaweights(I(j),:)*EEG.icasphere)*reshape(EEG.data(EEG.icachansind,:,:), length(EEG.icachansind), EEG.trials*EEG.pnts);
        [spectra, freqs] = spectopo( icaacttmp, EEG.pnts, EEG.srate, 'mapnorm', EEG.icawinv(:,I(j)), 'freqrange', [2 50],'plot','off' );
       
        spectra_abs = db2pow(spectra);
        range = find(freqs < 50);
        low_range = find(freqs < 10 & freqs > 0);
        high_range = find(freqs < 50 & freqs > 30);
        for k = range
            spectra_abs(1,k) = spectra_abs(1,k)/(squeeze(sum(spectra_abs(1,range))));
        end
%         spectra_db = pow2db(spectra_abs);
        freq_matrix(j,1) = sum(spectra_abs(1,low_range))/length(low_range);
        freq_matrix(j,2) = sum(spectra_abs(1,high_range))/length(high_range);
       
        comp_count_eeg = comp_count_eeg + 1;
        clear icaacttmp spectra freqs p
end

emg_ratio = freq_matrix(:,2)./freq_matrix(:,1);
emg_thresh = 1.1;
emg_tag = emg_ratio > emg_thresh;
%--------------------Plotting the subplot,labels,buttons-------------------

for k = 1:size(EEG.icawinv,2)
    if isfield(EEG,'comptype') && EEG.comptype(I(k))>0
        type = label{EEG.comptype(I(k))};
    elseif ~isfield(EEG,'comptype') && emg_tag(k)
        type = label{3};
        comptype(I(k))=3;
    elseif ~isfield(EEG,'comptype') && kurt(k)
        type = label{5};
        comptype(I(k))=5;
    elseif ~isfield(EEG,'comptype') && blink(k)
        type = label{2};
        comptype(I(k))=2;
    else
        type = '';
    end
    %blank plot for topo map
    icad(k).a = subplot(fact(n,1),fact(n,2),k,'Tag',num2str(k));
    p    = get(gca,'Position');
  
    %Dot showing removal
    icad(k).rb = uicontrol(gcf,'style','radio','units','normalized','Position',[p(1)+0.020 p(2) + (p(4)) 0.015 0.015],...
        'Tag',num2str(k),'value',0,'callback',@place_dot); %'value',kurt(k)
    if isfield(EEG,'comptype') && EEG.comptype(I(k))>0
        set(icad(k).rb,'value',1)
    elseif comptype(I(k))== 5 || comptype(I(k))== 3
        set(icad(k).rb,'value',1)
    end
    
    %Push tag showing ICA component type
    icad(k).pb = uicontrol(gcf,'style','push','units','normalized','Position', [p(1)+0.033 p(2) + (p(4)) 0.03 0.024],...
        'Tag',num2str(k),'String',type);
    
    %Tag showing ICA number
    tag = ['ICA ' num2str(I(k)) ];
    icad(k).tg = uicontrol(gcf,'style','text','units','normalized','Position', [p(1)+0.017 p(2) + (p(4) + 0.023) 0.038 0.022],...
        'Tag',num2str(k),'String',tag);
        
    topoplot(EEG.icawinv(:,I(k)),EEG.chanlocs(setdiff(1:EEG.nbchan,chans_rm)),'colormap',colormap(jet)); %Ch Subplot to blank topography plot
    set(icad(k).pb,'callback',{@disp_call, EEG,icad(k)}) % Setting callback for push button
    
    
end

S.update  = uicontrol(S.topos, 'style','push',...
                'units','normalized',...
                'position',[0.02 0.85 0.08 0.04],...
                'fontsize',12,...
                'string','Update',...
                'callback',{@update_call,EEG,name,A});
S.save  = uicontrol(S.topos, 'style','push',...
                'units','normalized',...
                'position',[0.02 0.78 0.08 0.04],...
                'fontsize',12,...
                'string','Save',...
                'callback',{@save_call,EEG,name,A,step_num});
S.compmat  = uicontrol(S.topos, 'style','push',...
                'units','normalized',...
                'position',[0.02 0.71 0.08 0.04],...
                'fontsize',12,...
                'string','Comp Mat',...
                'callback',{@compmat_call,label});
S.instruct  = uicontrol(S.topos, 'style','text',...
                'units','normalized',...
                'position',[0.2 0.05 0.7 0.04],...
                'fontsize',12,...
                'string',...
                'ICA components organized by weights (Largest to Smallest)');

guidata(S.topos,S);

end

function [] = disp_call(varargin)
%Calls the component analysis window when a specific ICA component button
%is selected

global I
comp   = str2num(get(varargin{1},'Tag'));
EEG    = varargin{3};
A = varargin{4};

set(A.tg,'BackgroundColor','green')
guidata(A.tg,A)

tmseeg_pop_prop_modified(EEG,0,I(comp),[],{'freqrange' [2 50]},A);

end


function [] = save_call(varargin)
%Saves and removes components set for removal by the user

global I comptype basepath existcolor chans_rm
EEG      = varargin{3};
name     = varargin{4};
A        = varargin{5};
step_num = varargin{6};

%Find ICA components tagged for removal
o        = findobj('value',1,'style','radio');
if isempty(o)
    cmp    = [];
elseif numel(o)>1
    for k=1:numel(o)
        cmp(k)    = str2num(get(o(k),'Tag'));
    end
else
    cmp    = str2num(get(o,'Tag'));
end

%Save and remove components
EEG.comp2rem = I(cmp);
EEG.comptype = comptype;
EEG.ref;
for i = 1:EEG.nbchan
    EEG.chanlocs(i).labels;
end

EEG_O = EEG;
EEG_ica = EEG;
EEG_ica.nbchan=EEG.nbchan-length(chans_rm);
EEG_ica.data=EEG.data(setdiff(1:EEG.nbchan,chans_rm),:,:);
EEG_ica.chanlocs=EEG.chanlocs(setdiff(1:EEG.nbchan,chans_rm));
EEG_ica          = pop_subcomp(EEG_ica,EEG.comp2rem,0); 
EEG=EEG_ica;
EEG.data=EEG_O.data;
EEG.chanlocs=EEG_O.chanlocs;
EEG.nbchan=EEG_O.nbchan;
EEG.data(setdiff(1:EEG.nbchan,chans_rm),:,:)=EEG_ica.data;

EEG          = eeg_checkset( EEG );


% EEG         = pop_subcomp(EEG,EEG.comp2rem,0); 
EEG          = eeg_checkset( EEG );
ICA2comp = comptype;

%Save data, update main GUI
[files, ~] = tmseeg_load_step(step_num);
tmseeg_step_check(files, EEG, A, step_num)
save(fullfile(basepath,[name '_' num2str(step_num) '_ICA2comp.mat']), 'ICA2comp');


close
tmseeg_clear_figs()
end


function [] = update_call(varargin)
%Displays the EEG dataset with selected components removed

global I comptype basepath existcolor VARS chans_rm
EEG    = varargin{3};
name   = varargin{4};
A      = varargin{5};

%Find components tagged for removal
o      = findobj('value',1,'style','radio');
if isempty(o)
    cmp    = [];
elseif numel(o)>1
    for k=1:numel(o)
        cmp(k)    = str2num(get(o(k),'Tag'));
    end
else
    cmp    = str2num(get(o,'Tag'));
end

%Remove components
EEG.comp2rem = I(cmp);
EEG.comptype = comptype;
ICA2comp     = comptype;
tmseeg_displ_comp(comptype,I)
EEG_O = EEG;
EEG_ica = EEG;
EEG_ica.nbchan=EEG.nbchan-length(chans_rm);
EEG_ica.data=EEG.data(setdiff(1:EEG.nbchan,chans_rm),:,:);
EEG_ica.chanlocs=EEG.chanlocs(setdiff(1:EEG.nbchan,chans_rm));
EEG_ica = pop_subcomp(EEG_ica,EEG.comp2rem,0); 
EEG=EEG_ica;
EEG.data=EEG_O.data;
EEG.chanlocs=EEG_O.chanlocs;
EEG.nbchan=EEG_O.nbchan;
EEG.data(setdiff(1:EEG.nbchan,chans_rm),:,:)=EEG_ica.data;
% EEG          = pop_subcomp(EEG,EEG.comp2rem,0); 
EEG = eeg_checkset( EEG );

wdw_start = VARS.UPD_WDW_STRT;
wdw_end   = VARS.UPD_WDW_END;

close(findobj('type','figure','name','Before ICA 2 Component Removal'))
close(findobj('type','figure','name','After ICA 2 Component Removal'))


data_temp = squeeze(nanmean(EEG.data,3));
data_orig_temp = squeeze(nanmean(EEG_O.data,3));

% % Double pulse paradigm case
% if(isfield(EEG,{'TMS_period2remove_b'}))
%     ix = min(EEG.TMS_period2remove_b);
%     rm_pulse_fill = NaN(size(data_temp,1),length(EEG.TMS_period2remove_b));
%     data_temp = cat(2,data_temp(:,1:ix-1),rm_pulse_fill,data_temp(:,ix:end));
%     
%     rm_pulse_fill_orig = NaN(size(data_temp,1),length(EEG.TMS_period2remove_b));
%     data_orig_temp = cat(2,data_orig_temp(:,1:ix-1),rm_pulse_fill_orig,data_orig_temp(:,ix:end));
% end

%Insert NaN values to fill space where TMS pulse was removed
% ix       = min(EEG.TMS_period2remove_1);
% rm_pulse_fill = NaN(size(data_temp,1),length(EEG.TMS_period2remove_1));
% data_temp = cat(2,data_temp(:,1:ix-1),rm_pulse_fill,data_temp(:,ix:end));
% 
% rm_pulse_fill_orig = NaN(size(data_orig_temp,1),length(EEG.TMS_period2remove_1));
% data_orig_temp = cat(2,data_orig_temp(:,1:ix-1),rm_pulse_fill_orig,data_orig_temp(:,ix:end));
% 
ymin = VARS.UPD_WDW_YMIN;
ymax = VARS.UPD_WDW_YMAX;
EEGtimes    =  min(EEG.times):1000/EEG.srate:max(EEG.times);
data_orig   = data_orig_temp(:,EEGtimes>=wdw_start & EEGtimes<=wdw_end);
data        = data_temp(:,EEGtimes>=wdw_start & EEGtimes<=wdw_end);

%Before removal of components Plot
before_fig = figure('units','normalized',...
        'menubar','none',...
        'numbertitle','off',...
        'toolbar','none',...
        'name','Before ICA 2 Component Removal',...
        'position',[0.05 0.1 0.45 0.45]);
b4ax = axes('Position',[0.2 0.2 0.7 0.8]);
timtopo(data_orig, EEG_O.chanlocs,...
    'plottimes',[100],...
    'limits',[wdw_start wdw_end ymin ymax])

%After removal of selected components Plot
after_fig = figure('units','normalized',...
        'menubar','none',...
        'numbertitle','off',...
        'toolbar','none',...
        'name','After ICA 2 Component Removal',...
        'position',[0.5 0.1 0.45 0.45]);
afax = axes('Position',[0.2 0.2 0.7 0.8]);
timtopo(data, EEG.chanlocs,...
    'plottimes',[100],...
    'limits',[wdw_start wdw_end ymin ymax])

end

function compmat_call (varargin)
% Uses comptype list to create a visual display of the components tagged
% for removal
global comptype backcolor
label  = varargin{3};

% Create Image of Component Matrix
image=zeros(length(comptype),length(label));
if ~isempty(find(comptype))
    for k=1:length(comptype)
        if comptype(k)
            image(k,comptype(k)) = 1;
        end
    end
end

%Plot component matrix
figure('menubar','none','Toolbar','none','Color',backcolor);
imagesc(image);
xlabel('Component Type')
ylabel('Component #')
set(gca,'XTickLabel',label)
title('Component Tags (Yellow = marked for deletion)')

end


function place_dot(varargin)
%updates radiobutton display when a component is selected for deletion
global I comptype
obj = varargin{1};
if ~get(obj,'value')
    o = findobj('tag',get(obj,'tag'),'style','push');
    set(o,'string','');
    comptype(I(str2num(get(obj,'tag'))))=0;
end
end

