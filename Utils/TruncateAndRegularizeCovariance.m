function [ newCov,iW ] = TruncateAndRegularizeCovariance( Cov )
% needed method for wMNE computing

newCov = (Cov + Cov')/2;
[Un,Sn2] = svd(newCov,'econ');
Sn = sqrt(diag(Sn2)); % singular values
tol = length(Sn) * eps(single(Sn(1))); % single precision tolerance
Rank_Noise = sum(Sn > tol);
Un = Un(:,1:Rank_Noise);
Sn = Sn(1:Rank_Noise);
newCov = Un*diag(Sn.^2)*Un';

%diag method
% newCov = diag(diag(newCov)); % strip to diagonal
% iW = diag(1./sqrt(diag(newCov)));

%reg Method
NoiseReg=0.1;
RidgeFactor = mean(diag(Sn2)) * NoiseReg;
newCov = newCov + RidgeFactor * eye(size(newCov,1));
iW = Un*diag(1./sqrt(Sn.^2 + RidgeFactor))*Un'; 
end

