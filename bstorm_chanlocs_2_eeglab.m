% function to read the chanlocs used in brainstorm and save them in .xyz to import in eeglab 
% BMT project - UNIL 2023

function [] = bstorm_chanlocs_2_eeglab(filepath,filenameChannel,Channel)


fid = fopen([filepath,filenameChannel(1:end-4),'.xyz'],'w');
for i = 1:128
     fprintf(fid,'%d %1.4f %1.4f %1.4f %s \n',i,-Channel(i).Loc(2),Channel(i).Loc(1),Channel(i).Loc(3), Channel(i).Name);
end
fclose(fid);



% clear all
% close all
% 
% load('channel_6T1S_EEG1.mat');
% 
% 
% fid = fopen('prova.xyz','w');
% 
% for i = 1:128
%     fprintf(fid,'%d %1.4f %1.4f %1.4f %s \n',i,-Channel(i).Loc(2),Channel(i).Loc(1),Channel(i).Loc(3), Channel(i).Name);
% end
% 
% fclose(fid);