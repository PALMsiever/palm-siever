% Tracing algorithm
%
%   function Trace = trace(X,Y,P0,dir0,r0,step)
%
%       X,Y     the data to be traced
%       P0      coordinates to the first point in the trace
%       dir0    initial direction of movement
%       r0      initial radius of the estimation region
%       step    step size
%
%   The algorithm starts from P0 and reads the points within a region r0
%   to estimate the direction of movement. The estimation is performed by
%   moving along the largest eigenvalue of the covariance matrix.
%
% This software is released under the GPL v3. It is provided AS-IS and no
% warranty is given.
%
% Author: Thomas Pengo, 2012
function Trace = trace(X,Y,P0,dir0,r0,step)
minN = 20;

Trace = [];
r = r0;
moving = true;
P = P0;
dir = dir0;

visited = false(size(X));
hold
while moving
    for j=1:3
        subset0 = (X-P(1)).^2 + (Y-P(2)).^2 < r*r;
        subset = ~visited & subset0;
        if sum(subset)>minN
            break
        end
        r = r*1.3;
    end
    ss = [X(subset0) Y(subset0)];
    n = sum(subset);
    if n<minN
        disp('Was not able to find enough unvisited points to continue')
        break
    end
    
    % TODO : how do I detect an intersection? this doesn't work
    if sum(visited)>30 && n>10*std(Trace(:,8))
        intersection = 1;
        %disp('Intersection?')
    else
        intersection = 0;
    end
        
    visited = visited | subset;
    
    % Calculate new 
    curCenter = mean(ss,1);
    
    % Check if we're moving
    if ~isempty(Trace) 
        dP = curCenter'-Trace(end,1:2)';
        if sqrt( sum(dP.^2) ) < .01*step
            disp('Not moving any more!')
            break
        end
    else
        dP = step*dir;
    end
    
    [v d] = eig(cov(ss));
    
    % Check if we have a clear direction
    if d(2,2)/d(1,1) > 2
        
        % New direction is along largest eigenvector
        ndir = v(:,2)*sqrt(d(2,2)); ndir = ndir/sqrt(sumsqr(ndir));
        
        % Move forward.. (check scalar prod with previous dir)
        if ndir'*dP < 0
            ndir = -ndir;
        end
        cnt = 0;
        
        %if ndir'*dir < 0
        %    disp('Whoa.. Not going backwards: I''ll just go on..')
        %    ndir = dir;
        %    cnt = 1;
        %else
        %    cnt = 0;
        %end
        
        % Avoid sharp turns
        ndir = ndir*.8 + dir*.2;
    else
        % If no clear direction, keep going
        ndir = dir;
        cnt = 1;
    end
    
    Trace = [Trace; curCenter ndir' diag(d)' d(2,2)/d(1,1) n intersection cnt];

    % Move
    dP = ndir * step; dir = ndir;
    P = curCenter + dP';
    
    r = r0;
    
end
