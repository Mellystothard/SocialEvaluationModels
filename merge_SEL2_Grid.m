function ldat = merge_SEL2_Grid(wrkDir, batchPts, fitVer, dataSetCode, mergedFName)
% merge_SEL2_Grid$$$_$$
% put together the fitted variables from a number of fitting blocks in an array
% and csv file. 

 %% Menu arguments ------------------------------------------------------
    try % dataset worked on - pil01 for the first major pilot Jul23 c. 140 pts
        dataSetCode;
    catch
        dataSetCode = 'pil01';    
    end
    try % Version of the fits being merged - so 04b_01 merges the first iteration ( _01 ) of 
        % the grid fits by SEL2_Grid04b* . 04b is cruciall be. we'll look for it in the fileNames to merge.
        fitVer;
    catch
        fitVer = '04b_01';    
    end
    try % start and end participant in each batch e.g. [1,20; 21,40; 41,60; 61,80; 81,100; 101,120; 121,136] ;
        batchPts;
    catch
        batchPts = [1,20; 21,40; 41,60; 61,80; 81,100; 101,120; 121,136] ;
    end
    fitBatch = 1:size(batchPts,1);
    try 
        mergedFName;
    catch
        % The default ends in _ldat_merged so that we can look for unmerged files ending in just _ldat :
        mergedFName = ['sel_' fitVer '_' num2str(batchPts(1,1)) 'to' num2str(batchPts(end,2)) '_ldat_merged' ];
    end
    
 %% Provided or potential working directories
    cwd = cd;  % make a backup of where we are. Good practice to return to this at the end :)
    try
        cd(wrkDri)
    catch
        warning('Could not change to wrkDir provided - trying alternatives')
    end
    % set wrkDir and load correspondence of data order in A and B waves:
    try
       wrkDir = ['/home/michael/googledirs/MM/SocEvalModels_(not_git)_rough_work/Carlisi_team_work/' dataSetCode '_fit' fitVer];
       cd(wrkDir);
    catch
       error(['Neither wrkDir provided nor the default, ' wrkDir ,' worked.']);
    end
    
    ldatSample = dir(['*' fitVer(1:3) '*_' num2str(batchPts(1,1)) 'to*_ldat.mat']);  % Be careful not to load already merged!
    if length(ldatSample) ~= 1
        disp(ldatSample);
        error('Length of ldatSample should be exactly 1 file.');
    else  % Load sample find and record header, number of columns etc.
        load(ldatSample.name);
        hd4ldat = hd;
    end
    
    ldatNew = [];  % I will be horribly naughty and not preallocate ;)
    disp(' ');
    for batN = fitBatch
    
        newFile = dir(['*' fitVer(1:3) '*_' num2str(batchPts(batN,1)) 'to' num2str(batchPts(batN,2)) '*_ldat.mat']);
        if length(newFile) ~= 1
            disp(' '); warning('newFile appears to be:');
            disp(newFile);
            error('newFile should contain just 1 file - are there missing or left-over files here?');
        end
        load(newFile.name,'ldat');
    
        ldatNew = [ldatNew; ldat];
        disp([newFile.name ' added OK']);
    
    end % end loop over batches (fitting files)
    ldat = ldatNew;
    
    outMatName = [mergedFName '.mat'];
    save(outMatName, 'ldat', 'hd');
    disp([mergedFName '.mat done.']); 
    mat2csv2Dfl(ldat,[mergedFName '.csv'],0,1,hd4ldat)
    disp([mergedFName '.csv done.']); 
    
    cd(cwd)
return; % end function ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

              
