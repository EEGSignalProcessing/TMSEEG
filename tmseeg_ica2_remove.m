% Author: Matthew Frehlich, Ye Mei, Luis Garcia Dominguez, Faranak Farzan
%         2016
%         Ben Schwartzmann
%         2017

% tmseeg_ica2_remove() - loads dataset from ICA2 step, checks for previously
% labelled components, and calls the tmseeg_multiple_topos() function for ICA2
% component analysis
% 
% Inputs:  S        - parent GUI structure
%          step_num - step number of tmseeg_ica2_remove in workflow

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

function [] = tmseeg_ica2_remove(S, step_num)

%Check if previous steps were done
if tmseeg_previous_step(step_num) 
    return 
end 

global basepath
global comptype

%Load Data
[files, EEG] = tmseeg_load_step(step_num);
[~,name,~] = fileparts(files.name);

%Check for existing ICA2 removal data
if exist(fullfile(basepath,[name '_' num2str(step_num) '_ICA2comp.mat']))
    load(fullfile(basepath,[name '_' num2str(step_num) '_ICA2comp.mat']));
    comptype = ICA2comp;
    EEG.comptype = comptype;
else
    comptype = zeros(1,size(EEG.icawinv,2));
end
 
tmseeg_multiples_topos(EEG,name,S,step_num);

end
