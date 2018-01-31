function [EEG] = tmseeg_addTMSTimeBack(EEGkk, EpochSecs)
    
EEG = EEGkk;
discon_low = []; 
discon_high = []; 

for i=1:(size(EEGkk.times,2)-1) % find discontinuity in times array

    if( (EEGkk.times(i+1)-(EEGkk.times(i)+1000/EEGkk.srate)) >= (1000/EEGkk.srate))
        discon_low = [discon_low; EEGkk.times(i)]; %#ok
        discon_high = [discon_high; EEGkk.times(i+1)]; %#ok
    end

end

discon = [discon_low discon_high];

for i=1:size(discon,1) % sometimes finds a discontinuity at end of epoch (i.e., 998ms -> 999.0000ms for epochs (-1000ms to +1000ms))

    if(discon(i,1)>EEGkk.times(size(EEGkk.times,2)-5))
        discon(i,:) = [];
    end

end

ch = size(EEGkk.data,1);
tr = size(EEGkk.data,3);
EEG.data = zeros(ch,EEGkk.srate*EpochSecs,tr);

if size(discon,1) == 2 % paired pulse paradigm

    w1 = find(EEGkk.times==discon(1,1));
    w2 = find(EEGkk.times==discon(1,2));
    gap = (discon(1,2) - discon(1,1))*(EEGkk.srate/1000)-1;

    EEG.pnts = EEGkk.pnts + gap ;
    EEG.data(:,1:w1,:) = EEGkk.data(:,1:w1,:);
    EEG.data(:,w1+gap+1:EEG.pnts,:) = EEGkk.data(:,w2:EEGkk.pnts,:);
    EEG.data(:,w1+1:w1+gap,:) = NaN;

    EEG.times = zeros(1,EEG.pnts);
    EEG.times(1,1:w1) = EEGkk.times(:,1:w1);
    EEG.times(1,w1+gap+1:EEG.pnts) = EEGkk.times(1,w2:EEGkk.pnts);
    EEG.times(1,w1:w1+gap+1)= EEGkk.times(1,w1):(1000/EEGkk.srate):EEGkk.times(1,w2);
    EEGkk.times = EEG.times;


    sp_low = discon(2,1);
    sp_high = discon(2,2);
    EEGkk = EEG;
    EEG.data = zeros(ch,EEGkk.srate*EpochSecs,tr);
else
    sp_low = discon(1,1);
    sp_high = discon(1,2);
end

% single pulse paradigm
w1 = find(EEGkk.times==sp_low);
w2 = find(EEGkk.times==sp_high);
gap = (sp_high - sp_low)*(EEGkk.srate/1000) - 1;

EEG.pnts = EEGkk.pnts + gap ;
EEG.data(:,1:w1,:) = EEGkk.data(:,1:w1,:);
EEG.data(:,w1+gap+1:EEG.pnts,:) = EEGkk.data(:,w2:EEGkk.pnts,:);
EEG.data(:,w1+1:w1+gap,:) = NaN;
EEG.times = floor(EEGkk.times(1)):(1000/EEGkk.srate):ceil(EEGkk.times(end));
    
end

