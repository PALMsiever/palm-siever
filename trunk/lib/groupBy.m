function gX = groupBy(X, ID)

[a a ID] = unique(ID);
gX = accumarray(ID,X)./accumarray(ID,1);

