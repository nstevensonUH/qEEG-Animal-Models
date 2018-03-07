function [fid, val1, val2] = read_header(filename);
%
%
%
%
%
%

fid = fopen(filename, 'r');
s1 = []; hdr = fread(fid, 9, 'char')';       
% FINDER '_HEADER_'
while strcmp(s1, '_HEADER_') == 0
    dum = fread(fid, 1, 'char');       
    hdr = [hdr dum];
    s1 = char(hdr(end-7:end));
end
% Unsigned INT8 gives the number of <int> variables in header
 dum1 = fread(fid, 1, 'uint8');     
 % Read in <int> variables and values (assuming variables are all string value where value is an unsigned int16)
 str1 = cell(1, dum1); val1 = zeros(1, dum1);
 for ii = 1:dum1
 dum2 = fread(fid, 1, 'uint8');        % PASCAL FORMAT
 str1{ii} = fread(fid, dum2, 'char');
 val1(ii) = fread(fid, 1, 'uint16');
 end

 % Unsigned INT8 gives the number of <float> variables in header
 dum1 = fread(fid, 1, 'uint8');     
 % Read in <int> variables and values (assuming variables are all string value where value is an unsigned int16)
 str2 = cell(1, dum1); val2 = zeros(1, dum1);
 for ii = 1:dum1
 dum2 = fread(fid, 1, 'uint8');        % PASCAL FORMAT
 str2{ii} = fread(fid, dum2, 'char');
 val2(ii) = fread(fid, 1, 'single');
 end
 
 % Unsigned INT8 gives the number of <string> variables in header
 dum1 = fread(fid, 1, 'uint8');     
 % Read in <sring> variables and values (assuming variables are all string value where value is an unsigned int16)
 str3 = cell(1, dum1); val3 = str3;
 for ii = 1:dum1
 dum2 = fread(fid, 1, 'uint8');        % PASCAL FORMAT
 str3{ii} = fread(fid, dum2, 'char');
 dum3 = fread(fid, 1, 'uint8');        % PASCAL FORMAT
 val3{ii} = fread(fid, dum3, 'char');
 end
 
while strcmp(s1, '_DATA_') == 0
    dum = fread(fid, 1, 'char');       
    hdr = [hdr dum];
    s1 = char(hdr(end-5:end));
end
