function [] = tmseeg_reset_workflow(S, fromstep, tostep)
% tmseeg_reset_workflow() - resets the workflow by deleting future
% sequential steps starting from a specified step.  Updates the parent GUI
% to reflect the deleted files.

global basefile basepath 
checkext = '';
ext = '.set';

for i = 1:tostep
    checkext = strcat(checkext,['_' num2str(i)]); 
    filetodelete = [basepath '/' basefile checkext ext];
    if exist(filetodelete,'file') && (i >= fromstep)
        delete(filetodelete);
        delete([basepath '/*' basefile checkext '_toDelete.mat']);
        delete([basepath '/*' basefile checkext '_ICA2comp.mat']);
        delete([basepath '/*' basefile '_tmseeg_settings.mat']);
    end    
tmseeg_upd_stp_disp(S, ext, tostep)
end

if exist([basepath '/*' basefile '_tmseeg_settings.mat'],'file')
    delete([basepath '/*' basefile '_tmseeg_settings.mat'])
end

end

