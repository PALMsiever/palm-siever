% Power spectrum of the current rendering
function pspectrum(handles)

D = getappdata(0,'KDE'); D = D{3};
FD = real(abs(ft(D))^2);
dipshow(log(FD),'lin')

figure; surf(double(log(FD)))

