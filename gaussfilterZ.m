function fzmap = gaussfilterZ(zmap, sigma)
%function fzmap = gaussfilterZ(zmap, sigma)
%
% gaussfilterZ :  apply Gaussian filter to a complex image
%
% Input
% zmaps :   a complex image
% sigma :   "width" of filter kernel in pixels
%
% Output
% fzmap :   filtered complex image

% Original version from Peter Kovesi (www.peterkovesi.com)

    % calculate filter size
    sze = ceil(6*sigma);  
    if ~mod(sze,2)    % Ensure filter size is odd
        sze = sze+1;
    end
    sze = max(sze,1); % and make sure it is at least 1
    
    % calculate Gaussian kernel
    h = fspecial('gaussian', [sze sze], sigma);
    
    % apply filter
    fzmap = complex(filter2(h, real(zmap)), filter2(h, imag(zmap)));
    
end
