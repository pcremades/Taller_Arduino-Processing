clear all
pkg load signal
pkg load instrument-control
figure(1);
Img = double(imread("./pic1.png")(:,:,1));
ImgSize = size(Img);

s=serial("/dev/ttyACM0",115200,1);
sleep(3);
[data, count] = srl_read(s,10);
sleep(1)

N = 200; %Numero de muestras
Mask = zeros(N, prod(ImgSize));
Intensity = zeros(N,1);

for i=1:N
  A=double(rand(ImgSize(1), ImgSize(2))>0.9);
  Mask(i,:) = A(:);
  B=Img.*A;
  imshow(B)
  refresh()
  pause(0.1)
  srl_write(s, "R");
  [data, count] = srl_read(s,20);
  dato = str2double(char(data));
  %Intensity(i) = dato;
  Intensity(i) = mean(B(:));  
endfor

fclose(s)

Result = Mask\Intensity;
Result = Result + abs(min(Result(:)));
Result = Result/max(Result(:));
ImgResult = reshape(Result, ImgSize);
figure(2)
imshow(ImgResult)
