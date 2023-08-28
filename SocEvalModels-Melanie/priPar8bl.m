function [priPar, prHd] = priPar8bl(col2keep, col2ch,colVal)
%PRIPAR8BL provide array of priors on parametes in native space.
%   This should work with dens = dbetasc(x,a,b,lo,hi) as used in e.g. sel8bl03
%   Usually all arguments can be kept blank, to use defaults. 
%   Defaults are weak (regularizing) except for lapse rate, where there is
%       and informative prior that it is quite rare for it to be >0.5
%   col2keep columns can be selected from the full array, if less than all are needed.
%   col2ch is the columns to be replaced from their default values
%   colVal is an 4 x col2ch array with the new values. 
%
%   priPar is the output array, prHd its column labels/headings. 


prHd = {'posiSelf','posiOther','dEvSelf','dEvOther','aEvSelf','aEvOther','alphaPrec',...
        'genLR', ...
        'repLR', ...
        'wp0','wAttr',...
        'mem',...
        'lps'};  % lapse rate, new in Grid05 fitting  
    
try
    col2keep;
catch
    col2keep = 1:length(prHd);
end
try 
    col2ch;
catch
    col2ch = [];
    colVal = [];
end


%        1       2        3      4         5        6       7        8     9     10      11     12    13     
%   posiSelf posiOther dEvSelf dEvOther aEvSelf aEvOther alphaPrec genLR repLR wp0    wAttr  lrnR   lps
%                      <-  max             at 1                 >            <SD ~10><max at 4> 
priP=[[1.01,  1.01,     1.01,    1.01,  1.01,    1.01,     1.01,   1.01, 1.01,  10,    1.2,   1.01,  2]; ...  % a
      [1.01,  1.01,      2,       2,      2,       2,        2,    1.01, 1.01,  10,    5.8,   1.01, 10]; ...  % b
      [ 0,     0,        0,       0,      0,       0,        0,     0,   0,    -46,     0,     0,    0]; ...  % lo
      [ 1,     1,        100,    100,    100,     100,     100,     1,   1,     46     100,    1,    1]];     % hi

if ~isempty(col2ch)
    priP(:,col2ch) = colVal;
end

priPar = priP(:,col2keep);

return;  % end function priPar8bl


