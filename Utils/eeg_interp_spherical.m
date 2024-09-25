% eeg_interp_spherical.m
%
% SPARK PROJECT 2020.
%
% eeg_interp_spherical() - interpolate data channels
%
% Based on EEGLAB function eeg_interp, with spherical method
% to allow use without EEG structure
%
% Usage: EEGOUT = eeg_interp(EEG, badchans, method);
% 
% Input:
% EEGdata: matrix containing EEG data nchansXntimepoints
% chanlocs: EEGLab channel location structure, must contain X,Y,Z
% coordinates
% badchans: array of bad channels to interpolate
% 
%
% Copyright (c) 2020 UNIL
% Paolo Ruggeri (paolo.ruggeri@unil.ch)
% Jenifer Miehlbradt (jenifer.miehlbradt@unil.ch)

function EEG_interp = eeg_interp_spherical(EEGdata, chanlocs, badchans)

goodchans = setdiff(1:size(EEGdata,1),badchans);

% get theta, rad of electrodes
% ----------------------------
tmpgoodlocs = chanlocs(goodchans);

% modif for brainstorm pos file from krios
for ngoodch = 1:length(goodchans)
    tmp(:,ngoodch) = tmpgoodlocs(ngoodch).Loc;
end
xelec = tmp(1,:);
yelec = tmp(2,:);
zelec = tmp(3,:);
clear tmp
% otherwise deselect below
%xelec = [ tmpgoodlocs.X ];
%yelec = [ tmpgoodlocs.Y ];
%zelec = [ tmpgoodlocs.Z ];
rad = sqrt(xelec.^2+yelec.^2+zelec.^2);
xelec = xelec./rad;
yelec = yelec./rad;
zelec = zelec./rad;

tmpbadlocs = chanlocs(badchans);
% modif for brainstorm pos file from krios
for nbadch = 1:length(badchans)
    tmp(:,nbadch) = tmpbadlocs(nbadch).Loc;
end
xbad = tmp(1,:)';
ybad = tmp(2,:)';
zbad = tmp(3,:)';
%xbad = [ tmpbadlocs.X ];
%ybad = [ tmpbadlocs.Y ];
%zbad = [ tmpbadlocs.Z ];
rad = sqrt(xbad.^2+ybad.^2+zbad.^2);
xbad = xbad./rad;
ybad = ybad./rad;
zbad = zbad./rad;


% find non-empty good channels
% ----------------------------

% Interpolate
[tmp1 tmp2 tmp3 badchansdata] = spheric_spline( xelec, yelec, zelec, xbad, ybad, zbad, EEGdata(goodchans,:));

% % EEGlab function... but does not really exclude badchans...? 
% datachans = getdatachans(goodchans,badchans);
% [tmp1 tmp2 tmp3 badchansdata] = spheric_spline( xelec, yelec, zelec, xbad, ybad, zbad, EEGdata(datachans,:));

EEG_interp = EEGdata;
EEG_interp(badchans,:) = nan;
EEG_interp(badchans,:) = badchansdata;


%%%%%%%%%%%%%%%%%%%%%%%%%%% From eeg_interp %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -----------------
% spherical splines
% -----------------
function [x, y, z, Res] = spheric_spline_old( xelec, yelec, zelec, values);

SPHERERES = 20;
[x,y,z] = sphere(SPHERERES);
x(1:(length(x)-1)/2,:) = []; x = [ x(:)' ];
y(1:(length(y)-1)/2,:) = []; y = [ y(:)' ];
z(1:(length(z)-1)/2,:) = []; z = [ z(:)' ];

Gelec = computeg(xelec,yelec,zelec,xelec,yelec,zelec);
Gsph  = computeg(x,y,z,xelec,yelec,zelec);

% equations are 
% Gelec*C + C0  = Potential (C unknow)
% Sum(c_i) = 0
% so 
%             [c_1]
%      *      [c_2]
%             [c_ ]
%    xelec    [c_n]
% [x x x x x]         [potential_1]
% [x x x x x]         [potential_ ]
% [x x x x x]       = [potential_ ]
% [x x x x x]         [potential_4]
% [1 1 1 1 1]         [0]

% compute solution for parameters C
% ---------------------------------
meanvalues = mean(values); 
values = values - meanvalues; % make mean zero
C = pinv([Gelec;ones(1,length(Gelec))]) * [values(:);0];

% apply results
% -------------
Res = zeros(1,size(Gsph,1));
for j = 1:size(Gsph,1)
    Res(j) = sum(C .* Gsph(j,:)');
end
Res = Res + meanvalues;
Res = reshape(Res, length(x(:)),1);

function [xbad, ybad, zbad, allres] = spheric_spline( xelec, yelec, zelec, xbad, ybad, zbad, values);

newchans = length(xbad);
numpoints = size(values,2);

%SPHERERES = 20;
%[x,y,z] = sphere(SPHERERES);
%x(1:(length(x)-1)/2,:) = []; xbad = [ x(:)'];
%y(1:(length(x)-1)/2,:) = []; ybad = [ y(:)'];
%z(1:(length(x)-1)/2,:) = []; zbad = [ z(:)'];

Gelec = computeg(xelec,yelec,zelec,xelec,yelec,zelec);
Gsph  = computeg(xbad,ybad,zbad,xelec,yelec,zelec);

% compute solution for parameters C
% ---------------------------------
meanvalues = mean(values); 
values = values - repmat(meanvalues, [size(values,1) 1]); % make mean zero

values = [values;zeros(1,numpoints)];
C = pinv([Gelec;ones(1,length(Gelec))]) * values;
clear values;
allres = zeros(newchans, numpoints);

% apply results
% -------------
for j = 1:size(Gsph,1)
    allres(j,:) = sum(C .* repmat(Gsph(j,:)', [1 size(C,2)]));        
end
allres = allres + repmat(meanvalues, [size(allres,1) 1]);

% compute G function
% ------------------
function g = computeg(x,y,z,xelec,yelec,zelec)

unitmat = ones(length(x(:)),length(xelec));
EI = unitmat - sqrt((repmat(x(:),1,length(xelec)) - repmat(xelec,length(x(:)),1)).^2 +... 
                (repmat(y(:),1,length(xelec)) - repmat(yelec,length(x(:)),1)).^2 +...
                (repmat(z(:),1,length(xelec)) - repmat(zelec,length(x(:)),1)).^2);

g = zeros(length(x(:)),length(xelec));
%dsafds
m = 4; % 3 is linear, 4 is best according to Perrin's curve
for n = 1:7
    if ismatlab
        L = legendre(n,EI);
    else % Octave legendre function cannot process 2-D matrices
        for icol = 1:size(EI,2)
            tmpL = legendre(n,EI(:,icol));
            if icol == 1, L = zeros([ size(tmpL) size(EI,2)]); end
            L(:,:,icol) = tmpL;
        end
    end
    g = g + ((2*n+1)/(n^m*(n+1)^m))*squeeze(L(1,:,:));
end
g = g/(4*pi);  


% get data channels
% -----------------
function datachans = getdatachans(goodchans, badchans)
    datachans = goodchans;
    badchans  = sort(badchans);
    for index = length(badchans):-1:1
        datachans(find(datachans > badchans(index))) = datachans(find(datachans > badchans(index)))-1;
    end