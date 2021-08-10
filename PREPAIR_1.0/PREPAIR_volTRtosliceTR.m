function xSliceTR = PREPAIR_volTRtosliceTR(xVolTR,nVol,pos,MB,NR,N,slice2)

x_mean=zeros(size(pos,2),nVol);

if MB==1
    id=find(slice2==0);
    for k=1:length(id)
        if id(k)==N
            xVolTR(:,id(k)) = xVolTR(:,id(k)-1);
        elseif id(k)==1
            xVolTR(:,id(k)) = xVolTR(:,id(k)+1);
        else
            xVolTR(:,id(k)) = (xVolTR(:,id(k)-1)+xVolTR(:,id(k)+1))/2.0;
        end
    end
end

for k=1:NR
    if MB>1       
        id = pos(:,k)~=0;
        x_mean(k,:) = (mean(xVolTR(:,pos(id,k)),2));
    else
        x_mean(k,:) = xVolTR(:,k)';
    end
end

for k=1:nVol
    xSliceTR((k-1)*NR+1:k*NR) = x_mean(:,k);
end
