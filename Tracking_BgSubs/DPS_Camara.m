A = dlmread("./datos.txt");
time = A(:,1);
pos = A(:, 2);

kern = hamming(15);
kern = kern/sum(kern);

newPos = pos;
%newPos = conv(pos, kern, "same");
figure(1)
plot( time, newPos, "*")


vs = diff(newPos) ./ diff(time);
figure(2)
plot(time(1:end-floor(size(kern)/2)-1), conv(vs(1:end-floor(size(kern)/2)), kern,"same"))