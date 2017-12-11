function [isOutlier, lower, upper] = ADJBP(x)
%ADJUSTEDBOXPLOT produces an adjusted box and whisker plot with one box for each column
% of X.  
% Typical for this boxplot are its skewness-adjusted whiskers, which are based on
% the medcouple, a robust measure of skewness (see mc.m). At skewed data, the original boxplot
% typically marks too many regular observations as outliers. The adjusted boxplot on the other
% hand makes a better distinction between regular observations and real outliers.
% 
% The ADJUSTED BOXPLOT is constructed as follows:
%   - a line is put at the height of the sample median.
%   - the box is drawn from the first to the third quartile.
%   - At right skewed data (MC >= 0), all points outside the interval 
%     [Q1 - 1.5*e^(a*MC)*IQR ; Q3 + 1.5*e^(b*MC)*IQR] are marked as outliers, 
%     where Q1 and Q3 denote the first and third quartile respectively, 
%     IQR stands for the interquartile range and MC is an abbreviation
%     for the medcouple (see mc.m).  
%     At left skewed data (MC < 0), the interval [Q1 - 1.5*e^(-b*MC)*IQR ;
%     Q3 + 1.5*e^(-a*MC)*IQR] is used, because of symmetry reasons.  
%   - finally, the whiskers are drawn, going from the ends of the box to the 
%     most remote points that are no outliers.  
% Note that the standard boxplot has the same box, but other whiskers. In that case, 
% all points outside the interval [Q1 - 1.5*IQR ; Q3 + 1.5*IQR] are marked as outliers. 
% The adjusted boxplot is thus similar to the original boxplot at symmetric distributions
% where MC=0.
%
% The skewness-adjusted boxplot is introduced in:
%     Hubert, M. and Vandervieren, E. (2008), 
%     "An adjusted boxplot for skewed distributions", 
%     Computational Statistics and Data Analysis, 52, 5186?5201.
%
%
% Required input arguments:
%                 x : a data matrix; for each column the adjusted boxplot is
%                     drawn.  When also a grouping vector is given, x must be a
%                     vector.  
%
% Optional input arguments:
%                a : number, defining the whisker of the
%                    adjusted boxplot.  The default is to use a = -4.  
%                b : number, defining the whisker of the
%                    adjusted boxplot.  The default is to use b = 3.  
%                    This means that for right skewed data the interval 
%                    [Q1 - 1.5*e^(-4*MC)*IQR ; Q3 + 1.5*e^(3*MC)*IQR] and
%                    for left skewed data the interval
%                    [Q1 - 1.5*e^(-3*MC)*IQR ; Q3 + 1.5*e^(4*MC)*IQR] is
%                    used.  
%       groupvalid : Grouping variable defined as a vector, string matrix, 
%                    or cell array of strings.  Groupvalid can also be a 
%                    cell array of several grouping variables (such as 
%                    {G1 G2 G3}) to group the values in x by each unique 
%                    combination of grouping variable values.  
%          classic : If equal to 1, dotted lines are drawn at the height 
%                    of the original whiskers. If equal to 0, only the
%                    adjusted boxplot is plotted.  (default is 0).
%           symbol : Symbol and color to use for all outliers (default is 'r+').
%      orientation : Box orientation, value 1 for a vertical boxplot (default) 
%                     or value 0 for a horizontal boxplot.
%           labels : Character array or cell array of strings containing
%                    labels for each column of x, or each group in G.
%           colors : A string or a three-column matrix of box colors.  Each
%                    box (outline, median line, and whiskers) is drawn in the
%                    corresponding color.  Default is to draw all boxes with
%                    blue outline, red median, and black whiskers.  Colors are
%                    recycled if mecessary.
%           widths : A numeric vector or scalar of box widths.  Default is
%                    0.5, or slightly smaller for fewer than three boxes.
%                    Widths are recycled if necessary.
%        positions : A numeric vector of box positions.  Default is 1:n.
%       grouporder : When G is given, a character array or cell array of
%                    group names, specifying the ordering of the groups in
%                    G.  Ignored when G is not given.
%
%
% I/O: result=adjustedboxplot(x,'a',-4,'b',3,'groupvalid',[],'classic',0,'symbol','r+',...
%             'orientation',1,'labels',[],'colors',[],'widths',1.5,'positions',[],'grouporder',[]);
%  The user should only give the input arguments that have to change their default value.
%  The name of the input arguments needs to be followed by their value.
%  The order of the input arguments is of no importance.
%
% ADJUSTEDBOXPLOT calls ADJUSTEDBOXUTIL to do the actual plotting.
%
% Examples: ADJUSTED BOXPLOT of car mileage grouped by country
%      load carsmall
%      out=adjustedboxplot(MPG,'groupvalid',Origin,'classic',1)
%      out=adjustedboxplot(MPG,'groupvalid',Origin,'symbol','b*','orientation',0)
%      out=adjustedboxplot(MPG,'groupvalid',Origin,'widths',0.75,'positions',[1 3 4 7 8 10], ...
%                   'grouporder',{'France' 'Germany' 'Italy' 'Japan' 'Sweden' 'USA'},'colors','kbrgym')
%
% The output is a structure containing the following fields:
%              result.a : numeric value, used in the definition of the outlier cutoffs 
%                         of the adjusted boxplot. 
%              result.b : numeric value, used in the definition of the outlier cutoffs 
%                         of the adjusted boxplot. 
%     result.groupvalid : If there is a grouping vector, this vector
%                         contains the assigned group numbers for the observations in vector x.
%        result.classic : value 1 or 0, indicating if dotted lines have been plot 
%                         at the heigth of the standard whiskers. 
%         result.symbol : symbol and color that has been used for all outliers.  
%    result.orientation : If equal to 1, the boxes are vertically oriented.  
%                         If equal to 0, a horizontal orientation has been used.  
%         result.labels : character array or cell array of strings, containing
%                         labels for each column of X, or each group in G.  
%         result.colors : a string or three-column matrix of box colors.
%         result.widths : a numeric vector of scalar of box widths.
%      result.positions : a numeric vector, containing the box positions.  
%     result.grouporder : If there is a grouping vector, this character array 
%                         or cell array of group names specifies the ordering of the groups.  
%
% This function is part of LIBRA: the Matlab Library for Robust Analysis,
% available at:
%              http://wis.kuleuven.be/stat/robust
%
% Written by Ellen Vandervieren
% Created on: 07/04/2005
% Last Update: 11/10/2011
%

if nargin<1
    error('Input argument ''x'' is undefined.')
end

whissw = 0; % don't plot whisker inside the box.

if isvector(x)
   % Might have one box, or might have a grouping variable. n will be properly
   % set later for the latter.
   x = x(:);
   n = 1; %
else
   % Have a data matrix, use as many boxes as columns.
   n = size(x,2);
end

% Assigning default-values
counter=1;
default=struct('a',-4,'b',3,'groupvalid',[],'classic',0,'symbol','r+','orientation',1,'labels',[],...
   'colors',[],'positions',[],'widths',0.5,'grouporder',[]);
% colors: default is blue box, red median, black whiskers
% positions: default is 1:n
% widths: default is 0.5, smaller for three or fewer boxes
% grouporder: default is 1:n
list=fieldnames(default);
result=default;
IN=length(list);
i=1;
%reading the user's input 
if nargin>1
    %
    %placing inputfields in array of strings
    %
    for j=1:nargin-1
        if rem(j,2)~=0
            chklist{i}=varargin{j};
            i=i+1;
        end
    end    
    %
    %Checking which default parameters have to be changed
    % and keep them in the structure 'result'.
    %    
    while counter<=IN 
        index=strmatch(list(counter,:),chklist,'exact');
        if ~isempty(index) %in case of similarity
            for j=1:nargin-1 %searching the index of the accompanying field
                if rem(j,2)~=0 %fieldnames are placed on odd index
                    if strcmp(chklist{index},varargin{j})
                        I=j;
                    end
                end
            end
            result=setfield(result,chklist{index},varargin{I+1});
            index=[];
        end
        counter=counter+1;
    end
end

a=result.a;
b=result.b;
group=result.groupvalid;
classic=result.classic;
symbol=result.symbol;
orientation=result.orientation;
labels=result.labels;
colors=result.colors;
positions=result.positions;
widths=result.widths;
grouporder=result.grouporder;

% a and b must be numeric scalars.
if isempty(a)
    a = -4;
elseif ~isscalar(a) || ~isnumeric(a)
   error('LIBRA:adjustedboxplot:BadA',...
         'The ''a'' parameter value must be a numeric scalar.');
end

if isempty(b)
    b = 3;
elseif ~isscalar(b) || ~isnumeric(b)
   error('LIBRA:adjustedboxplot:BadB',...
         'The ''b'' parameter value must be a numeric scalar.');
end

% When group is non-empty, x must be a vector.  
if (~isempty(group) && ~isvector(x))
      error('LIBRA:adjustedboxplot:VectorRequired',...
            'x must be a vector when there is a grouping variable.');
end

% Classic must be equal to 0 or 1.
if isempty(classic)
   classic = 0;
elseif ~isscalar(classic) || ~ismember(classic,0:1)
   error('LIBRA:adjustedboxplot:InvalidClassic','Invalid value for ''classic'' parameter');
end

% Convert wordy inputs to internal codes
if isempty(orientation)
   orientation = 1;
elseif ischar(orientation)
   orientation = strmatch(orientation,{'horizontal' 'vertical'}) - 1;
end
if isempty(orientation) || ~isscalar(orientation) || ~ismember(orientation,0:1)   
   error('LIBRA:adjustedboxplot:InvalidOrientation',...
         'Invalid value for ''orientation'' parameter');
end

% Deal with grouping variable before processing more inputs
if ~isempty(group)
    if orientation, sep = '\n';
    else
        sep = ',';
    end
    [group,glabel,gname,multiline] = mgrp2idx(group,size(x,1),sep);
    n = size(gname,1);
    if numel(group) ~= numel(x)
        error('LIBRA:adjustedboxplot:InputSizeMismatch',...
            'X and G must have the same length.');
    end
else
    multiline = false;
end

% Reorder the groups if necessary
if ~isempty(group) && ~isempty(grouporder)
   if iscellstr(grouporder) || ischar(grouporder)
      % If we have a grouping vector, grouporder may be a list of group names.
      if ischar(grouporder), grouporder = cellstr(grouporder); end
      [dum,grouporder] = ismember(grouporder(:),glabel);
      % Must be a permutation of the group names
      if ~isequal(sort(grouporder),(1:n)')
         error('LIBRA:adjustedboxplot:BadGrouporder', ...
               'The ''grouporder'' parameter value must contain all the unique group names in G.');
      end
   else
      error('LIBRA:adjustedboxplot:BadGrouporder', ...
            'The ''grouporder'' parameter value must be a character array or a cell array of strings.');
   end
   group = order(group);
   glabel = glabel(grouporder);
   gname = gname(grouporder,:);
end

% Process the rest of the inputs

if isempty(labels)
   if ~isempty(group)
      labels = glabel;
   end
else
   if ~(iscellstr(labels) && numel(labels)==n) && ...
      ~(ischar(labels) && size(labels,1)==n)
      % Must have one label for each box
      error('LIBRA:adjustedboxplot:BadLabels','Incorrect number of box labels.');
   end
   if ischar(labels), labels = cellstr(labels); end
   multiline = false;
end
dfltLabs = (isempty(labels) && isempty(group)); % box labels are just column numbers

if isempty(widths)
   widths = repmat(min(0.15*n,0.5),n,1);
elseif ~isvector(widths) || ~isnumeric(widths) || any(widths<=0)
   error('LIBRA:adjustedboxplot:BadWidths', ...
         'The ''widths'' parameter value must be a numeric vector of positive values.');
elseif length(widths) < n
   % Recycle the widths if necessary.
   widths = repmat(widths(:),ceil(n/length(widths)),1);
end

if isempty(colors)
   % Empty colors tells adjustedboxutil to use defaults.
   colors = char(zeros(n,0));
elseif ischar(colors) && isvector(colors)
   colors = colors(:); % color spec string, make it a column
elseif isnumeric(colors) && (ndims(colors)==2) && (size(colors,2)==3)
   % RGB matrix, that's ok
else
   error('LIBRA:adjustedboxplot:BadColors',...
         'The ''colors'' parameter value must be a string or a three-column numeric matrix.');
end
if size(colors,1) < n
   % Recycle the colors if necessary.
   colors = repmat(colors,ceil(n/size(colors,1)),1);
end

if isempty(positions)
   positions = 1:n;
elseif ~isvector(positions) || ~isnumeric(positions)
   error('LIBRA:adjustedboxplot:BadPositions', ...
         'The ''positions'' parameter value must be a numeric vector.');
elseif length(positions) ~= n
   % Must have one position for each box
   error('LIBRA:adjustedboxplot:BadPositions', ...
         'The ''positions'' parameter value must have one element for each box.');
else
   if isempty(group) && isempty(labels)
      % If we have matrix data and the positions are not 1:n, we need to
      % force the default 1:n tick labels.
      labels = cellstr(num2str((1:n)'));
   end
end

%
% Done processing inputs
%

notch = 0;
whis = 1.5;

% Put at least the widest box or half narrowest spacing at each margin
if n > 1
    wmax = max(max(widths), 0.5*min(diff(positions)));
else
    wmax = 0.5;
end
xlims = [min(positions)-wmax, max(positions)+wmax];

ymin = nanmin(x(:));
ymax = nanmax(x(:));
if ymax > ymin
   dy = (ymax-ymin)/20;
else
   dy = 0.5;  % no data range, just use a y axis range of 1
end
ylims = [(ymin-dy) (ymax+dy)];

% Scale axis for vertical or horizontal boxes.
% newplot
% oldstate = get(gca,'NextPlot');
% set(gca,'NextPlot','add','Box','on');
% set(gcf,'Name', 'Adjusted boxplot', 'NumberTitle', 'off');
% if orientation
%     axis([xlims ylims]);
%     set(gca,'XTick',positions);
%     ylabel(gca,'Values');
%     if dfltLabs, xlabel(gca, 'Column Number'); end
% else
%     axis([ylims xlims]);
%     set(gca,'YTick',positions);
%     xlabel(gca,'Values');
%     if dfltLabs, ylabel(gca,'Column Number'); end
% end
if nargout>0
   hout = [];
end

xvisible = NaN(size(x));
notnans = ~isnan(x);
for i= 1:n
   if ~isempty(group)
      thisgrp = find((group==i) & notnans);
   else
      thisgrp = find(notnans(:,i)) + (i-1)*size(x,1);
   end
   [isOutlier, lower,upper] = adjustedboxutil(x(thisgrp),a,b,classic,notch,positions(i),widths(i), ...
                                 colors(i,:),symbol,orientation,whis,whissw);
end


%=============================================================================

function [outlier, loadj, upadj] = adjustedboxutil(x,a,b,classic,notch,lb,lf,clr,symbol,orientation,whis,whissw)
%ADJUSTEDBOXUTIL Produces a single adjusted boxplot.

% define the median and the quantiles
pctiles = prctile(x,[25;50;75]);
q1 = pctiles(1,:);
med = pctiles(2,:);
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

if (isequal(classic,1)),
    vloorig = q1-whis*(q3-q1);     %Lower cutoff value for the original boxplot. 
    loorig = min(x(x>=vloorig));
    if (isempty(loorig)), loorig = q1; end
end

if (isequal(classic,1)),
    vhiorig = q3+whis*(q3-q1);     %Upper cutoff value for the original boxplot.      
    uporig = max(x(x<=vhiorig));
    if (isempty(uporig)), uporig = q3; end
end

x1 = repmat(lb,1,2);
x2 = x1+[-0.25*lf,0.25*lf];
outlier = x<loadj | x > upadj;
