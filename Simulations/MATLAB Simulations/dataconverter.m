fname = 'input_stimuli.txt';
lines = string(strtrim(splitlines(fileread(fname))));
lines(lines=="") = [];

data_u8 = uint8(bin2dec(char(lines)));
data_u8 = data_u8(:);

save('stimuli.mat','data_u8');
