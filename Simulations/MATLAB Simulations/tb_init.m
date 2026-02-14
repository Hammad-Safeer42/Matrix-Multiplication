% tb_init.m  (run once before sim)
lines = strtrim(readlines("input_stimuli.txt"));
lines(lines=="") = [];
stim = uint8(bin2dec(lines));      % 2048x1 expected

assignin('base','stim',stim);      % put in base workspace
