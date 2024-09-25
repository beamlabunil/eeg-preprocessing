function repeatProcessing = checkFolderForExistingFiles(folder, extension)

% Short function to verify if a folder already contains files (e.g. for the
% next preprocessing step) and ask the users if they want to repeat the
% corresponding preprocessing step.

if ~isempty(dir([folder,extension]))
    proceed = questdlg(sprintf('Some files already found in %s, do you want to start over?',folder), ...
        '', ...
        'Yes','No','No');
    if strcmp(proceed,'No')
        fprintf('Files in %s will be ignored \n \n',folder)
        repeatProcessing = false;
    else
        fprintf('Files in %s will be reprocessed \n \n',folder)
        repeatProcessing = true;
    end
else
    repeatProcessing = true;
end