function val = lcm_vector(values)
%% lcm_vector Compute the least common multiplier of a vector 

% deal with remainders 
values_remainder = values - floor(values); 
values_remainder_inv = 1./values_remainder; 
values_remainder_inv(isinf(values_remainder_inv)) = 1;

val_multiplier = lcm(uint32(values_remainder_inv(1)),uint32(values_remainder_inv(2))); 
for j = 3:length(values_remainder_inv)
    val_multiplier = lcm(uint32(val_multiplier),uint32(values_remainder_inv(j))); 
end 

val = lcm(uint32(values(1)*val_multiplier),uint32(values(2)*val_multiplier)); 
for j = 3:length(values)
    val = lcm(uint32(val),uint32(values(j)*val_multiplier)); 
end 

end