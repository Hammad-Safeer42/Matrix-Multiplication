fid = fopen('RomCoeff.txt','r');
c = textscan(fid,'%s');
fclose(fid);

coeff14_bin = c{1};          % cell array of 16 binary strings
coeff32 = zeros(16,1,'uint32');

for i = 1:16
    coeff32(i) = uint32(bin2dec(coeff14_bin{i}));
end
