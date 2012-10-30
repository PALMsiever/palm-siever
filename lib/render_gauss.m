function im = render_gauss(pxSize, peaks, sigma, offsets, outSize, bounds)

if 1
    im = javaMethod('drawGaussianDensityEstimation',...
        'rendering.ImageUtils',zeros(outSize),...
        java.awt.Rectangle(bounds(1),bounds(2),bounds(3),bounds(4)),...
        1,pxSize,peaks(:,1),peaks(:,2),sigma(:,1),sigma(:,2),sigma(:,1)*0+1,4)';
    
    return
end

D = size(peaks,2);

if length(pxSize)==1
    pxSize=repmat(pxSize,D,1);
end

im = zeros(outSize);

tic
for i=1:size(peaks,1)
    for j=1:D
        Mc{j} = gauss_kernel(sigma(i,j),pxSize(j),3,offsets(i,j))';
    end
    M = double(full(ktensor(Mc)));
    
    x = peaks(i,1); y = peaks(i,2);
    
    hs = (max(size(M))-1)/2;
    HS = (size(M)-1)/2;
    if min(peaks(i,:))>hs && max(peaks(i,:))+hs<=min(outSize) % TODO: improve
        im( (peaks(i,1)-HS(1)):(peaks(i,1)+HS(1)),...
            (peaks(i,2)-HS(2)):(peaks(i,2)+HS(2)) ) = im( (peaks(i,1)-HS(1)):(peaks(i,1)+HS(1)),...
            (peaks(i,2)-HS(2)):(peaks(i,2)+HS(2)) ) + M;
    end
    
    if toc > 5
        progress(i,size(peaks,1))
        tic;
    end
end
