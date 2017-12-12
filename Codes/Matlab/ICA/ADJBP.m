function [isOutlier, lower, upper] = ADJBP(x)
if isvector(x)
   x = x(:);
   n = 1; 
else
   % Have a data matrix, use as many boxes as columns.
   n = size(x,2);
end

% Assigning default-values
default=struct('a',-4,'b',3,'groupvalid',[],'classic',0,'symbol','r+','orientation',1,'labels',[],...
   'colors',[],'positions',[],'widths',0.5,'grouporder',[]);
result=default;
a=result.a;
b=result.b;
group=result.groupvalid;

whis = 1.5;
notnans = ~isnan(x);
for i= 1:n
   if ~isempty(group)
      thisgrp = find((group==i) & notnans);
   else
      thisgrp = find(notnans(:,i)) + (i-1)*size(x,1);
   end
   [isOutlier, lower,upper] = adjustedboxutil(x(thisgrp),a,b,whis);
end
%=============================================================================

function [outlier, loadj, upadj] = adjustedboxutil(x,a,b,whis)
%ADJUSTEDBOXUTIL Produces a single adjusted boxplot.

% define the median and the quantiles
pctiles = prctile(x,[25;50;75]);
q1 = pctiles(1,:);
q3 = pctiles(3,:);

% find the extreme values (to determine where whiskers appear)
medc = mc(x);
if medc>=0
    vloadj = q1-whis*exp(a*medc)*(q3-q1);  %Lower cutoff value for the adjusted boxplot.  
    loadj = min(x(x>=vloadj));
    vhiadj = q3+whis*exp(b*medc)*(q3-q1);  %Upper cutoff value for the adjusted boxplot.  
    upadj = max(x(x<=vhiadj));
else
    vloadj = q1-whis*exp(-b*medc)*(q3-q1);  %Lower cutoff value for the adjusted boxplot.  
    loadj = min(x(x>=vloadj));
    vhiadj = q3+whis*exp(-a*medc)*(q3-q1);  %Upper cutoff value for the adjusted boxplot.  
    upadj = max(x(x<=vhiadj));
end

if (isempty(loadj)), loadj = q1; end
if (isempty(upadj)), upadj = q3; end

outlier = x<loadj | x > upadj;
