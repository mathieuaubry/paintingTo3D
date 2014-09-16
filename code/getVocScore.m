function [real_score] =getVocScore(patch2d,positionDetection,patchSizeDetection)
% compute the voc distance between two patches patch2d (with fields isVali
% x1 x2 x3 and x4) and one from  positionDetection
% topositionDetection+patchSizeDetection with the hypothesis that patch2d
% is a rectangle (! not true in general, this is an approximation!)


if(~patch2d.isValid)
    real_score=0;
    return;
end
%dxGT=patch2d.x4(1)-patch2d.x1(1);
%dyGT=patch2d.x4(2)-patch2d.x1(2);
areaD=patchSizeDetection(1)*patchSizeDetection(2);

x_minGT=(patch2d.x1(1)+patch2d.x3(1))/2;
x_maxGT=(patch2d.x2(1)+patch2d.x4(1)-2)/2;
y_minGT=(patch2d.x1(2)+patch2d.x2(2))/2;
y_maxGT=(patch2d.x3(2)+patch2d.x4(2)-2)/2;
areaGT=(x_maxGT-x_minGT)*(y_maxGT-y_minGT);

x_minD=positionDetection(1);
x_maxD=positionDetection(1)+patchSizeDetection(1);
y_minD=positionDetection(2);
y_maxD=positionDetection(2)+patchSizeDetection(2);
if(x_minD>x_maxGT || x_minGT>x_maxD ||y_minD>y_maxGT || y_minGT>y_maxD )
    real_score=0;
    return;
end
x_min=max(x_minD,x_minGT);
x_max=min(x_maxD,x_maxGT);
y_min=max(y_minD,y_minGT);
y_max=min(y_maxD,y_maxGT);
area=(y_max-y_min)*(x_max-x_min);
real_score=area/(0.5*(areaGT+areaD));
end