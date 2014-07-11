% Calculates gamma-adjusted image
function imG = gammaAdjust(im,gammaVal)
%GAMMAADJUST Calculates gamma-adjusted image
%   Author: Seamus Holden, 2012

imMax = max(im(:));
imMin = min(im(:));

% Normalise image
imG = real((( (im-imMin)/(imMax-imMin)).^gammaVal)*(imMax-imMin)+imMin);

end

