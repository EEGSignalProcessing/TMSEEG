% Author: Matthew Frehlich, Ye Mei, Luis Garcia Dominguez, Faranak Farzan
%         2016
%         Ben Schwartzmann
%         2017

% tmseeg_ica2() - runs ICA round 2 on input EEG dataset
% 
% Inputs:  S        - parent GUI structure
%          step_num - step number of tmseeg_rm_TMS_decay in workflow

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.


function [] = tmseeg_ica2(S, step_num)

%Check if previous steps were done
if tmseeg_previous_step(step_num) 
    return 
end

global VARS

%Data Load
[files, EEG] = tmseeg_load_step(step_num);
VARS.ICA2_COMP_NUM = ceil(EEG.nbchan*VARS.ICA_COMP_PCT/100);
    
%Run ICA2
h1 = msgbox('Running ICA2,now!');
EEG = pop_runica( EEG, 'icatype' ,'fastica','g','tanh',...
        'approach','symm','lasteig',VARS.ICA2_COMP_NUM);
    
tmseeg_step_check(files, EEG, S, step_num);
close(h1);

end

