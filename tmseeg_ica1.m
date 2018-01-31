% Author: Matthew Frehlich, Ye Mei, Luis Garcia Dominguez, Faranak Farzan
%         2016
%         Ben Schwartzmann 
%         2017

% tmseeg_ica1() - Runs Independent Component Analysis using the pop_runica
% EEGLAB function and the fastica algorithm
%
% Inputs: S        - parent GUI information (structure)
%         step_num - Step number for current cleaning step in workflow

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.


function [] = tmseeg_ica1(S, step_num)

%Check if previous steps were done
if tmseeg_previous_step(step_num)
    return
end 
 
%Data Load
[files, EEG] = tmseeg_load_step(step_num);

%Run ICA, save new dataset
h1 = msgbox('Running ICA,now!');
EEG = pop_runica(EEG, 'icatype' ,'fastica','g','tanh','approach','symm');
EEG = eeg_checkset(EEG);

tmseeg_step_check(files, EEG, S, step_num);
close(h1);

end

