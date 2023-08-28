
source('/media/sf_mmpsy/Nextcloud/MM/localgit/mmutils/gen_ut.R')
setwd("/media/sf_mmpsy/Nextcloud/MM/googledirs/SocEvalModels_(not_git)_rough_work/dataFits/fittingTests/synRepDictCIs")

source('/home/mmoutou/localgit/mmutils/gen_ut.R')
setwd("/home/mmoutou/googledirs/MM/SocEvalModels_(not_git)_rough_work/dataFits")



g <- ldatGen100; colnames(g) <- paste(colnames(g),'g',sep='.'); f <- selGrid04a26May23; gf <- data.frame(g,f);

print(colnames(f)); 
v <- 'mem';
vg <- paste(v,'g',sep='.');  
co <- pcor(na.omit(gf[,c(vg,v)]));
ti <- paste(v, '  r=',round(co$est[2,1],3),'  p=',round(co$p.value[2,1],6));
plot(g[,vg],f[,v], main=ti,
     xlab=paste('generative',v),ylab=paste('refitted',v)); 
abline(0,1)
