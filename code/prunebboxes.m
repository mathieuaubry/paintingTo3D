function [resbbox,resconf,resid,resov]=prunebboxes(bbox,conf,ovthresh,normthres,max_results)
if ~exist('max_results','var')
    max_results=1000;
end
is1=find(conf>normthres);
bbox=bbox(is1,:);
conf=conf(is1);

[vs,is]=sort(-conf);
bbox=bbox(is,:);
conf=conf(is);

resbbox=[];
resconf=[];
resid=[];
resov=[];
rescount=0;
freeflags=ones(size(conf));
while sum(freeflags)>0 && rescount<max_results
    indfree=find(freeflags);
    [vm,im]=max(conf(indfree));
    
    indmax=indfree(im);
    ov=bboxoverlapval(bbox(indmax,:),bbox(indfree,:));
    indsel=indfree(find(ov>=ovthresh)); 
    if isempty(resov)
        resov(rescount+1,:)=0;
    else
        resov(rescount+1,:)=max(bboxoverlapval(bbox(indmax,:),resbbox ));
    end
    resbbox(rescount+1,:)=bbox(indmax,:);%mean(bbox(indsel,:),1);
    resconf(rescount+1,:)=conf(indmax);
    resid(rescount+1,:)=is1(is(indmax));
   
    rescount=rescount+1;
    freeflags(indsel)=0;
end
