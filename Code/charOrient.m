function charOri=charOrient(img)

%%% Defaut parameters
% Local window size

winSize=5; % default window size 5

% Number of angle samples
numAngl=36; % default number of angle samples 36 (has no effect if approximation is used)

% Approximation scheme (approximating response using cosine)
useApprox=0; % do not use approximation as default

%%% Initialize
img=single(img);
[imgRow,imgCol]=size(img);
r=(winSize-1)/2; % Get radius from window size

%%% Get rotation estimation filters
Wi=getRotationEstimationMasks_(winSize,numAngl,useApprox);

%%% Compute estimation angles (if approximation is used, only 0 and pi/2 angles are applied).
if useApprox == 1
    ang=[0;pi/2];
else
    numAngl=numAngl/2; % We only need angles up to pi because of the symmetry. 
    ang=(0:(pi/numAngl):(pi-pi/numAngl))'; % Imaginary part is antisymmetric.
end

%%% Reformat image data to matrix containing neighborhoods as columns
F=zeros(winSize^2,(imgRow-winSize+1)*(imgCol-winSize+1));
ii=1;
for i=1:winSize
   for k=1:winSize       
       d=img(i:(end-winSize+i),k:(end-winSize+k));
       F(ii,:)=d(:)';
       ii=ii+1;
   end
end

%%% characteristic orientation estimation using either approximation or sampling method.
if useApprox==1 % Approximation using cosine fitting
    % Rotation estimation
    R=(Wi*F); % imag frequency components at freq 1/n at angles ang
    tmp1=(R(2,:)*cos(ang(1))-R(1,:)*cos(ang(2)));
    tmp2=(R(2,:)*sin(ang(1))-R(1,:)*sin(ang(2)));
    
    % Get phase angle
    phi=atan(tmp1./tmp2);

    % Get characteristic orientation as peak location (equivalent to phase angle of the complex moment as below).
    charOri=mod(-phi,2*pi); 

else % Characteristic orientation using sampling method
    % Get signs of the imaginary part for each angle sample for each valid pixel position
    R=(Wi*F)>=0;

    % Calculate complex moment
    fullang=exp(1i*[ang; ang+pi]);
    tmp=sum(([R; 1-R]).*(fullang*ones(1,size(R,2))));
    
    % Get characteristic orientation as phase angle of the complex moment.
    charOri=mod(atan2(imag(tmp),real(tmp)),2*pi);

end

%%% Reformating estimates
charOri=reshape(charOri,[imgRow-2*r,imgCol-2*r]);
    
%%% Zero padd to mach the image size (image borders result zero orientation, since no well defined neigborhood is available)
charOri=[zeros(r,size(charOri,2)+2*r);[zeros(size(charOri,1),r),charOri,zeros(size(charOri,1),r)];zeros(r,size(charOri,2)+2*r)];

%%% Compute filter masks for rotation estimation
function Wi = getRotationEstimationMasks_(winSize,numAngl,useApprox)

% Default parameters
stdev = 2; % Standard deviation of the Gaussian window
%sigmaS=(winSize-1)/4; % Tuottaa eri tuloksen winSize=5 -> stdev=1;

% Initialize
r=(winSize-1)/2; % Get radius from window size
x=-r:r; % Form coordinate values

% Compute estimation angles (if approximation is used, only 0 and pi/2 angles are applied).
if useApprox == 1
    ang=[0;pi/2];
else
    numAngl=numAngl/2; % We only need angles up to pi because of the symmetry. 
    ang=(0:(pi/numAngl):(pi-pi/numAngl))'; % Imaginary part is antisymmetric.
end

% Form Gaussian window
gs=exp(-(x.^2)/(2*stdev^2));
H=gs'*gs; H=H/sum(H(:));

% Compute filter masks
xi=(1/winSize)*[cos(ang),-sin(ang)]';
Wi=zeros(size(xi,2),winSize^2);
for i=1:size(xi,2)
    M=exp(-2*pi*1i*xi(1,i)*x(:)) * exp(-2*pi*1i*xi(2,i)*(x(:).'));
    M=M.';
    M=H.*M; % Gaussian window
    Wi(i,:)=imag(M(:).');
end

return;




