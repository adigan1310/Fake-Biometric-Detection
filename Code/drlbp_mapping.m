function mapping = drlbp_mapping(Nhdpoints)

%%%%Creates mapping table for Uniform LBP Codes 
map_table = 0:2^Nhdpoints-1;
newMax  = 0; 
index   = 0;

newMax = 2*floor((Nhdpoints*(Nhdpoints-1) + 4)/2); 
for i = 0:2^Nhdpoints-1
    j = bitset(bitshift(i,1,Nhdpoints),1,bitget(i,Nhdpoints));
    snum = sum(bitget(bitxor(i,j),1:Nhdpoints)); 
                                          
    if snum <= 2
      map_table(i+1) = index;
      index = index + 1;
    else
      map_table(i+1) = newMax - 1;
    end
end

mapping.map_table = map_table;
mapping.Nhdpoints = Nhdpoints;
mapping.Mbins = newMax;

return;

