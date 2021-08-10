function [timeTR,timeSlice,sliceVolTR] = PREPAIR_slice_timing(dtTR,nVol,NR,MB,sliceOrder,acqSlice,nSlices,TR)


% sliceTR time
timeTR=0:dtTR:(nVol*NR-1)*dtTR;

% Slice timing
switch(sliceOrder)
    
    case 'asc'
        
        for k=1:NR
            
            tt = (k-1)*dtTR;
            for i=1:MB
                timeSlice(acqSlice(MB*(k-1)+1:k*MB)) = tt;
            end
            
            
        end
        

end
        
for k=1:nSlices
    sliceVolTR(:,k) = timeSlice(k) +[0:TR:(nVol-1)*TR];
end
