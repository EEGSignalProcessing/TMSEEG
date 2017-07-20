function [] = tmseeg_reset_workflow(S, fromstep, tostep)
% tmseeg_reset_workflow() - resets the workflow by deleting future
% sequential steps starting from a specified step.  Updates the parent GUI
% to reflect the deleted files.

global basefile basepath 
ext = '.set';
checkext = '';
for i = 1:tostep

    checkext = [checkext '_' num2str(i)];
    if (i >= fromstep) %&& exist([basepath '\' basefile checkext ext],'file') 
            strevaldel = ['delete ' ,'''',[basepath '\' basefile checkext ext],''''];
            strevaldel1 = ['delete(','''',[basepath '\*' checkext '_toDelete.mat'],'''',')'];
            strevaldel2 = ['delete(','''',[basepath '\*' checkext '_ICA2comp.mat'],'''',')'];
            evalc(strevaldel);
            evalc(strevaldel1);
            evalc(strevaldel2);
            
    end   
tmseeg_upd_stp_disp(S, ext, tostep)

end
end

