function  tmseeg_save_step(EEG, S, files, step_num)
% tmseeg_save_step() - saves the current step with the right extension name
% in the basepath

global basepath

[~,name,ext] = fileparts(files.name);
pop_saveset( EEG, 'filename',[name '_' num2str(step_num) '.set'],'filepath',basepath,'savemode','onefile'); % no pop-up
tmseeg_upd_stp_disp(S, ext, step_num);

end

