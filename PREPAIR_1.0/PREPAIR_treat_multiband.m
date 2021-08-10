function group = PREPAIR_treat_multiband(nSlices, MB, acqSlice, acqSlice2, slice2keep)

if MB >1
    NR = nSlices/MB;
else
    id = find(acqSlice2~=0);
    NR=size(acqSlice2(id),2);
end

group = zeros(MB,NR);

for k=1:NR
    found = 0;
    
    for i=(k-1)*MB+1:k*MB
        
        for j=1:length(acqSlice2)
            if acqSlice(i) == acqSlice2(j)
                found = found +1;
                gg(k) = found;
            end
        end
    end
end

nn=0;
for i=1:MB
    b=0;
    for k=1:NR
        if nn>=length(acqSlice2)
            break
        end
        
       if (b+i)<=length(acqSlice2)
            nn=nn+1;
            group(i,k) = acqSlice2(b +i);
            %pos(i,k) = b+i;
            b= b +gg(k);
            
       end
        
        
    end
end

%pos2=zeros(MB,NR);

for i=1:MB
    %b=0;
    for k=1:NR
        for j=1:length(slice2keep)
            if group(i,k) == slice2keep(j)
              %  pos2(i,k) = pos(i,k);
            end
        end
    end
end

% aa=0;
% for k=1:size(pos2,2)
%     id = find(pos2(:,k)~=0);
%     
%     if length(id)~=0
%         aa=aa+1;
%         n(aa) =aa;
%         pos3(:,aa) = pos2(:,k);
%     end
%     
% end
