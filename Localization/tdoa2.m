function [x y z] = tdoa2(Sen_position , Hmax, Fs)

Vs = 34029;

timedelayvec = Hmax/Fs;

s = size(Sen_position);
len = s(1);

Amat = zeros(len,1);
Bmat = zeros(len,1);
Cmat = zeros(len,1);
Dmat = zeros(len,1);

x1 = Sen_position(1,1);
y1 = Sen_position(1,2);
z1 = Sen_position(1,3);
x2 = Sen_position(2,1);
y2 = Sen_position(2,2);
z2 = Sen_position(2,3);

for i=3:len
    xi = Sen_position(i,1);
    yi = Sen_position(i,2);
    zi = Sen_position(i,3); 
   Amat(i) = (1/(Vs*timedelayvec(i)))*(-2*x1+2*xi) - (1/(Vs*timedelayvec(2)))*(-2*x1+2*x2);
   Bmat(i) = (1/(Vs*timedelayvec(i)))*(-2*y1+2*yi) - (1/(Vs*timedelayvec(2)))*(-2*y1+2*y2);
   Cmat(i) = (1/(Vs*timedelayvec(i)))*(-2*z1+2*zi) - (1/(Vs*timedelayvec(2)))*(-2*z1+2*z2);
   Sum1 = (x1^2)+(y1^2)+(z1^2)-(xi^2)-(yi^2)-(zi^2);
   Sum2 = (x1^2)+(y1^2)+(z1^2)-(x2^2)-(y2^2)-(z2^2);
   Dmat(i) = Vs*(timedelayvec(i) - timedelayvec(2)) + (1/(Vs*timedelayvec(i)))*Sum1 - (1/(Vs*timedelayvec(2)))*Sum2;
end


M = zeros(len,3);
D = zeros(len,1);
for i=1:len
    M(i,1) = Amat(i);
    M(i,2) = Bmat(i);
    M(i,3) = Cmat(i);
    D(i) = Dmat(i);
end

M = M(3:len,:);
D = D(3:len);


D = D.*-1;

Minv = pinv(M);
T = Minv*(D);
x = T(1);
y = T(2);
z = T(3);


% figure;
% plot(x,y, 'bd'); 
% xlabel('X coordinate of target');
% ylabel('Y coordinate of target');
% title('TDOA Hyperbolic Localization');
% axis([-223 223 -244 244]);
end