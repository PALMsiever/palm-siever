% Find close 
maxF = 3;
maxD = 50;

cons = zeros(size(xx));
for i=find(subset)'
    xx = x(i);
    yy = y(i);
    
    dFrame = frame-frame(i);
    
    isF = subset & dFrame>0 & dFrame<maxF;
    
    if ~any(isF)
        continue
    end
    
    Xx = x(isF);
    Yy = y(isF);
    
    d = sqrt( (Xx-xx).^2 + (Yy-yy).^2 );
    
    isNear = d < maxD;
    
    if isempty(isNear) || ~any(isNear)
        cons(i) = 0;
    else
        [near neari] = min(d(isNear));
        cons(i) = neari(1);
    end
end
