function acqSlice = PREPAIR_slice_order(nSlices,MB, sliceOrder)

NR = nSlices/MB;

switch(sliceOrder)   
    case 'asc'
        
        id =1;
        for k=1:NR
            
            acqSlice(id) = k;            
            for i=2:MB
                acqSlice((id-1)+i) = acqSlice((id-1)+i-1) + NR;
            end            
            id = MB + id;
            
        end
        

end

