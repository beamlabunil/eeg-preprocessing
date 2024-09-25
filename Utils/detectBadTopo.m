% detectBadTopo.m
%
% SPARK PROJECT 2020.
%
% Function to identify "bad topologies" based on steep gradient (> thr)
% between datamax and datamin
% Inteded to be used on max GFP window
%
%
% Copyright (c) 2020 UNIL
% Jenifer Miehlbradt (jenifer.miehlbradt@unil.ch)

function isBadTopo = detectBadTopo(topoVals,thr)
% topoVals from [~,topoVals, ~, ~, ~] = topoplot(ppe(:,idx_max), chanlocs,'noplot','on')

M = max(max(topoVals));
m = min(min(topoVals));
[idx_My, idx_Mx] = find(topoVals == M);
[idx_my, idx_mx] = find(topoVals == m);
d = pdist([idx_Mx,idx_My;idx_mx,idx_my]);
grad = (M-m)/d;

isBadTopo = grad > thr ;