function  tmseeg_step_check(files, EEG, S, step_num)
% tmseeg_reset_workflow() - resets the workflow by deleting future
% sequential steps starting from a specified step.  Updates the parent GUI
% to reflect the deleted files.

global basefile basepath
[~,name,ext] = fileparts(files.name);

if exist([basepath '\' name '_' num2str(step_num) ext],'file')
    warningdlg = ['Step ' num2str(step_num) ' already exists, continuing will delete all subsequent steps.  Continue?'];
    choice = questdlg(warningdlg);
    
    switch choice
        case 'Yes'
            tmseeg_reset_workflow(S,step_num,S.num_steps)
            tmseeg_save_step(EEG,S,files,step_num)
    end
else
    tmseeg_save_step(EEG,S,files,step_num)
end
end


