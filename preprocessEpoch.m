% preprocessEpoch.m
% BMT project - UNIL 2023

function [ preprocessedEpoch] = preprocessEpoch(originalEpoch,chanlocs,rejected,reRef)

%% Initialize   

chan128 = 1:128;

eog_channels = sort([129 130 131 132]);
eeg_channels = setdiff(chan128, eog_channels);
tobeExcludedChans = setdiff(1:136, union(chan128, eog_channels));

%% Remove unwanted Electrodes and EOG data
EEG_data=originalEpoch(eeg_channels,:);
EOG_data=originalEpoch(eog_channels,:);

%% Filter and remove DC offset
% Already done in previous step
[numberOfChannels,nbSamples]=size(EEG_data);

%% EOG regression
eeg = EEG_data';
eog = EOG_data';

eegClean =  eeg - eog * (eog \ eeg);
eegClean=eegClean';

%eegplot(EEG_data, 'data2', eegClean, 'srate',1024,'title','Filtered vs EOG removed','winlength',5,'dispchans',32)


%% Interpolate using eeglab's spherical spline
if ~isempty(rejected) % PR: I modified a lot of things!! to check

     % remove electrode flat (i.e., used to re-Ref at import) from channel list. The channel should not be used to interpolate 
     chanlocs_wo_reref = chanlocs;
     chanlocs_wo_reref(reRef) = [];
     % get index of the electrodes to interpolate w.r.t. this new channel list
     for el_int = 1:length(rejected)
            ind_el_rej(el_int,1) = find(strcmp({chanlocs_wo_reref.Name}, rejected{el_int}) == 1);
     end     
     % get the clean data without the reRef electrode at import
     eegClean_wo_reref = eegClean(setdiff(chan128,reRef),:);
     % interpolate (without the reref electrode at import)
     EEG_interp = eeg_interp_spherical(eegClean_wo_reref, chanlocs_wo_reref,ind_el_rej); 
     
     % add now back the (flat) electrode used for reref at import
     EEG_interp_temp = eegClean;
     EEG_interp_temp(setdiff(chan128,reRef),:) = EEG_interp;
     EEG_interp = EEG_interp_temp;

     %disp(['Rejected/interpolated channels: ', num2str(ind_el_rej')])
 else 
     EEG_interp = eegClean;
 end
 

%eegplot(eegClean, 'data2',EEG_interp , 'srate',1024,'title','EOG cleaned vs interp','winlength',5,'dispchans',32)

preprocessedEpoch=EEG_interp;

%% Reref to average
% the reref electrode should be back after avg ref ! 
preprocessedEpoch = preprocessedEpoch - ones(size(preprocessedEpoch,1),1)*mean(preprocessedEpoch);  

%eegplot(preprocessedEpoch, 'data2',EEG_interp , 'srate',1024,'title','avg ref vs interp','winlength',5,'dispchans',32)

end

