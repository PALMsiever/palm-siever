function imG = gammaAdjust(im,gammaVal)
%GAMMAADJUST Calculates gamma-adjusted image
%   Author: Seamus Holden, 2012

imMax = max(im(:));

% Normalise image
imG = ((im/imMax).^gammaVal)*imMax;

end

