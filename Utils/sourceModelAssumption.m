function [ Alpha,gainWQ ] = sourceModelAssumption( gain, gridLoc, gridOrient,weightExp,weightLimit )
% needed method for wmne computing

numDipoles=size(gridLoc,1);
Wq = cell(1,numDipoles);
ColNorms2 = sum(gain .* gain);
SourceNorms2 = sum(reshape(ColNorms2,3,[]),1);
Alpha2 = SourceNorms2 .^ weightExp;
AlphaMax2 = max(Alpha2);
Alpha2 = max(Alpha2, AlphaMax2 ./ (weightLimit^2));
Alpha2 = AlphaMax2 ./ Alpha2;
Alpha=sqrt(Alpha2);
blklength=size(gridOrient,2);
gainWQ=zeros(size(gain,1),numDipoles);
for i=1:numDipoles
    tmp = gridOrient(i,:)'; % 3 x 1
    tmp=tmp/norm(tmp); % ensure unity
    tmp=tmp*Alpha(i);
    for line=1:size(gain,1)
        startIndex=((i-1)*blklength)+1;
        endIndex=i*blklength;
        rowGain=gain(line,startIndex:endIndex)';
        gainWQ(line,i)=sum(rowGain.*tmp);
    end
end


end

