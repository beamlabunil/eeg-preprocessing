% BMT project - UNIL 2023

clc
clearvars
close all

%% Initialize the script
addpath('..');
initEEGprepr;

%% 1. Re-ref at import and Filter
% load set Files list
markerfiles = dir([conf.markersFold,'*.set']);
markerfiles = {markerfiles.name};
markerfiles = markerfiles(~startsWith(markerfiles,'.'));

for ii = 1:length(markerfiles)

    filename = markerfiles{ii};
    filenameChannel = ['channel_',filename(1:9),'.mat'];   
    filenameElReref = [filename(1:9),'.txt'];

    % Verify if this file has already been filtered
    if exist([conf.filteredFold,filename(1:end-4),'_filtered.set'],'file') == 2
        filter_bool = false;
        disp('File already processed. Erase it to process again')
    else
        filter_bool = true;
    end

    if filter_bool

        fprintf('Processing file %s ......... \n', filename)

        % load set
        EEG = pop_loadset('filename',filename,'filepath',conf.markersFold );
        
        %% remove external channels
        EEG = pop_select( EEG, 'rmchannel',{'EXG1','EXG2','EXG3','EXG4','EXG5','EXG6','EXG7','EXG8','GSR1','GSR2','Erg1','Erg2','Resp','Plet','Temp'});

        % load channel locs mat from brainstorm structure
        load([conf.elPosition filenameChannel])

        % transform channel locs from brainstorm in .xyz for eeglab and load it to EEG data structure
        bstorm_chanlocs_2_eeglab(conf.elPosition,filenameChannel,Channel);
        EEG.chanlocs = readlocs([conf.elPosition,filenameChannel(1:end-4),'.xyz']);

        % load electrode to use as a reref at import before any pre-processing
        el_reRef = importdata([conf.elToReref filenameElReref]);
        ind_el_reRef = find(strcmp({Channel.Name}, el_reRef{1}) == 1);

        % select reference (e.g., A1 == position 1) to gain 40 dB SNR.
        EEG_reref  = pop_reref( EEG, ind_el_reRef,'keepref','on');

        % downsample ?
        if conf.dslog
            EEG_downsample = pop_resample(EEG_reref, conf.srate/conf.dsfactor);
        else
            EEG_downsample = EEG_reref;
        end

        % Remove DC offset
        data = EEG_downsample.data;
        nChannels = size(data,1);
        for k = 1:nChannels
            data(k,:) = data(k,:)-mean(data(k,:));
        end

        % EEGLAB Highpass filter & notch
        EEG_dc_offset = EEG_downsample;
        EEG_dc_offset.data = data;

        EEG_filt = pop_eegfiltnew(EEG_dc_offset, 'locutoff',conf.fHP,'plotfreqz',0);
        
        EEG_filt = pop_eegfiltnew(EEG_filt, 'locutoff',conf.fNl,'hicutoff',conf.fNh,'revfilt',1,'plotfreqz',0);



        % save dataset
        pop_saveset(EEG_filt, 'filename', [filename(1:end-12),'_filtered.set'], 'filepath',conf.filteredFold,'version','7.3');

    end
end

