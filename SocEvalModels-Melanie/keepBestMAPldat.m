function ldatBest = keepBestMAPldat(ldatFull1,ldatFull2,outDir)

try
    outDir;
catch
    warning();
    outDir = cd
end

load(ldatFull1);   ldat1 = ldat; hd1 = hd;
load(ldatFull2);   ldat2 = ldat; hd2 = hd;

if sum(abs(size(ldat1)-size(ldat2)))
    error('The two ldat objects loaded have different sizes');
else
    rowTotN = size(ldat1,1);
    colTotN = size(ldat1,2);
    LPcol = 0;
    for co=1:colTotN
        if strcmp(hd{co},'LP')
            LPcol = co;
        end
    end

    ldatBest = ldat1;
    for ro=1:rowTotN
        if ldat2(ro,LPcol) > ldat1(ro,LPcol)
            ldatBest(ro,:) = ldat2(ro,:);
        end
    end
end
ldat = ldatBest;

cwd = cd;
cd(outDir);
save('ldatBest.mat','ldat','hd');
mat2csv2Dfl(ldat,['ldatBest.csv'],0,1,hd);
cd(cwd);

return; % end of 
