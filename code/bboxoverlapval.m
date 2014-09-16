function ov=bboxoverlapval(bb1,bb2,normtype)

%
% ov=bboxoverlapval(bb1,bb2,normtype)
%
%  returns normalized intersection area of two rectangles
%  'normtype' = -1: no normalization, absolute overlap area 
%                0: normalization by the area of common min. rectangle (default)
%                1: normalization by the area of the 1st rectangle
%                2: normalization by the area of the 2nd rectangle

if nargin<3 normtype=0; end
 % tic
ov=zeros(size(bb1,1),size(bb2,1));
for i=1:size(bb1,1) 
   % if(toc>10)
      %  tic
     %   fprintf('%i %% \n',round(100*i/size(bb1,1)));
  %  end
  for j=1:size(bb2,1) 
    ov(i,j)=bboxsingleoverlapval(bb1(i,:),bb2(j,:),normtype);
  end
end

function ov=bboxsingleoverlapval(bb1,bb2,normtype)

bb1=[min(bb1(1),bb1(3)) min(bb1(2),bb1(4)) max(bb1(1),bb1(3)) max(bb1(2),bb1(4))];
bb2=[min(bb2(1),bb2(3)) min(bb2(2),bb2(4)) max(bb2(1),bb2(3)) max(bb2(2),bb2(4))];

ov=0;
if normtype<0 ua=1;
elseif normtype==1
  ua=(bb1(3)-bb1(1)+1)*(bb1(4)-bb1(2)+1);
elseif normtype==2
  ua=(bb2(3)-bb2(1)+1)*(bb2(4)-bb2(2)+1);
else
  bu=[min(bb1(1),bb2(1)) ; min(bb1(2),bb2(2)) ; max(bb1(3),bb2(3)) ; max(bb1(4),bb2(4))];
  ua=(bu(3)-bu(1)+1)*(bu(4)-bu(2)+1);
end

bi=[max(bb1(1),bb2(1)) ; max(bb1(2),bb2(2)) ; min(bb1(3),bb2(3)) ; min(bb1(4),bb2(4))];
iw=bi(3)-bi(1)+1;
ih=bi(4)-bi(2)+1;
if iw>0 & ih>0              
  ov=iw*ih/ua;
end
