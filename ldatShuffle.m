function ldatSh = ldatShuffle(sourceDir,ldatFName,randSeed)

try
    sourceDir
catch
    warning();
    sourceDir = '/home/michael/googledirs/MM/SocEvalModels_(not_git)_rough_work/Carlisi_team_work/pil01_fit04b_01/'
end

try
    ldatFName;
catch
    warning();
    ldatFname = 'sel_04b_01_1to136_ldat_merged.mat'
end

try
    randSeed;
catch
    randSeed = [];
end
if isempty(randSeed)
    rng('shuffle');
else % for reproducible sequences of random numbers; 'shuffle' bases on time.
    rng(randSeed, 'twister');
    warning([scriptName ' running with rng(randSeed,''twister''']);
end 

load([sourceDir ldatFname]);   % should load both the data and the headers.
rowN = size(ldat,1);
newRows = randperm(rowN);
ldat = ldat(newRows,:);
ldatSh = ldat;

save(['shufl_' ldatFname],'ldat','hd');
mat2csv2Dfl(ldat,['shufl_' ldatFname(1:(end-3)) 'csv'],0,1,hd);

return; % end of 
