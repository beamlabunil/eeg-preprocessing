function idxleft = getEpochOrder(EEG,Marker)

% get order of appearence of the corresponding marker in the original list of markers before epoching
cont = 0;
for nevents = 1:length(EEG.urevent)
    if EEG.urevent(nevents).type == Marker
        cont = cont + 1;
        OrigEpochs(cont,1) = nevents;
    end
end

% get those remaining after epoch rejection
LeftEpochs = extractfield( EEG.event , 'urevent' )';

% get those missing
RejEpochs = setdiff(OrigEpochs,LeftEpochs);

% create a sequential list (1 to number of marker of the same type)
idxleft = (1:length(OrigEpochs))';

if ~isempty(RejEpochs)
    % get the position of the rejected epochs of the corresponding marker
    for nepochsrej = 1:length(RejEpochs)
        idxremove(nepochsrej) = find(OrigEpochs == RejEpochs(nepochsrej));
    end

    % remove those indexes from the complete list. This vector inform about in which order the kept epochs appeared in the task
    idxleft(idxremove) = [];
else
    idxleft = [];
end



end