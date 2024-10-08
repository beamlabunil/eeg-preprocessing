function [ kernel ] = ComputeWMNE( noiseCov,gain,gridLoc,gridOrient,weightExp,weightLimit,SNR )
% Compute the kernel matrix by solving the inverse problem
% Inputs -noiseCov: the noise covariance matrix of dimension
%                       [nbElectrodes,nbElectrodes];
%        - gain: the gain Matrix (leadfield matrix ) obtained after
%        computing the head model , dimension [nbElectrodes,3*nbVertices]
%        - gridLoc: the position of the sources ( from the surface file) ,
%        dimension [nbVertices,3]
%        - gridOrient: the orientation of the sources (from the surface
%        file), dimension [nbvertices,3]
%        - weighExp: parameter from brainstorm to compute the wMNE
%        -weightLimit: parameter from brainstorm to compute the wMNE
%        - SNR: signal to noise ratio to compute the wmne
%
% Outputs -kernel: dimension [nbVertices, nbElectrodes]




%% Compute the inverse problem

if(size(noiseCov,2)~= size(gain,1))
    if(size(noiseCov,2)<size(gain,1))
        gain=gain(1:size(noiseCov,2),:);
    else
        error('unmatched dimensions between the gain matrix and the noise covariance');
    end
end
numberOfChannels=size(noiseCov,1);
montageMatrix=eye(numberOfChannels)-(ones(numberOfChannels,numberOfChannels)./numberOfChannels);
CNoise=(montageMatrix*noiseCov)*montageMatrix';
CNoise=(CNoise+CNoise')./2;
gain=montageMatrix*gain;
CNoise=diag(diag(CNoise));

[alpha,gainWQ]=sourceModelAssumption(gain,gridLoc,gridOrient,weightExp,weightLimit);
[~,iW]=TruncateAndRegularizeCovariance(CNoise);
L=iW*gainWQ;
[UL,SL2] = svd((L*L'));
SL2 = diag(SL2);
SL = sqrt(SL2); 
SNR=SNR*SNR;
lambda=SNR/mean(SL.^2);

kernel = lambda * L' * (UL * diag(1./(lambda * SL2 + 1)) * UL');
kernel = kernel * iW;
for line=1:size(kernel,1)
    kernel(line,:)=alpha(line)*kernel(line,:);
end


end

