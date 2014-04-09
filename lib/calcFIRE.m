function [ FIRE se frcprofile frcprofile_f ] = calcFIRE(X, Y, res, minX, maxX, minY, maxY, nTrials)
frcprofile_f = linspace(0,res/(maxX-minX)/2,res/2+1)'; %dx=linx(2)-linx(1);
frcprofile = zeros(nTrials,res/2+1);

for trials=1:nTrials
    iss0 = randperm(length(X));

    iss1 = iss0(1:round(end/2));
    iss2 = iss0(round(end/2)+1:end);

    %ss1 = false(size(ss0)); ss1(iss1)=true;
    %ss2 = false(size(ss0)); ss2(iss2)=true;

    D1 = calcHistogram_(X(iss1), Y(iss1), res, minX, maxX, minY, maxY);
    D2 = calcHistogram_(X(iss2), Y(iss2), res, minX, maxX, minY, maxY);

    frcprofile(trials,:)=double(frc(cat(3,D1,D2)));
end

X = frcprofile_f;
for trials=1:size(frcprofile,1)
    Y = frcprofile(trials,:); Y=Y(:);
    
    f = @(x) sum(Y(X>x)-1/7)-sum(Y(X<x)-1/7);
    FIRE_ = fminbnd(f,min(X),max(X));
    if sum(X>FIRE_)<5 % We require at least 5 curve points to the right of the crossing point
        logger('The resolution threshold of 1/7 was not attained. You can probably use a finer grid to bin your data.');
    end

    FIREs(trials)=FIRE_;
end

FIRE = 1/mean(FIREs);
se = std(FIREs)/sqrt(nTrials);
