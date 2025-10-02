aaaa
%% 矩阵
A = [1 2 3; 4 5 2; 3 2 7]
B = A' %转秩
C = A(:) % 拉长 竖着
D = inv(A) %求方阵的逆
A * D

E = zeros(10,5,3)
E(:,:,1) = rand(10,5)%rand m行n列的伪随机数（0-1）
E(:,:,2) = randn(10,5)%randn 正态分布的伪随机数
E(:,:,3) = randi(5,10,5)%randi 均匀分布的伪随机整数([iMIN,iMAX],m,n)
%% 元胞数组
A = cell(1,6)% a = b =666
A{2} = eye(3)% 从1开始 不是从0
A{5} = magic(5)
B = A{5}
%%
% 结构体
books = struct('name',{{'Machine Learning','Data Mining'}},'price',[30 40])
books.name 
books.name(1)%cell
books.name{1}%字符串
%% 矩阵
A = [1 2 3 5 8 5 4 6]
B = 1:2:9 %2为步长 从1开始 9结束
C = repmat(B, 3, 2)% 重复B 3次 横着重复 2次
D = ones(2, 4)% 2行4列 且值为one
%% 四则运算
A = [1 2 3 4 ; 5 6 7 8];
B = [1 1 2 2 ; 2 2 1 1];
C = A + B
D = A - B
E = A * B' %B的转秩
F = A .* B %对应项相乘
G = A / B % G * B = A   G * B * pinv(B) = A * pinv(B)   G = A * pinv(B)
% 相当于A乘以B的逆
I = pinv(B)
H = A ./ B
%% 矩阵的下标
A = magic(5)
B = A(2,3)%取二行三列的值
C = A(3,:)%“：”冒号的意思是取全部的值
D = A(:,4)
[m, n] = find(A > 20)%找大于20的序号值/矩阵
%% 逻辑和流程控制
%循环结构 for 变量 = 初值： 步长： 变量终值
%             执行语句 1
%   ....      执行语句 n
%        end
sum = 10
for n = 1: 5
    sum = sum + n^2
end
% while 语句 同C语言  if ... end

%% 二维绘图
% 1. 二维平面
x = 0:0.1:2*pi;%从0开始 每次增加0.1 2Π结束
y = sin(x);
figure %建立一个幕布
plot(x,y)
title('y=sin(x)')
xlabel('x')
ylabel('sin(x)')
xlim([0 2*pi])


x = 0:0.01:20;
y1 = 200*exp(-0.05*x).*sin(x);
y2 = 0.8*exp(-0.5*x).*sin(10*x);
figure
[AX,H1,H2] = plotyy(x,y1,x,y2,'plot');
set(get(AX(1),'Ylabel'),'String','Slow Decay')
set(get(AX(2),'Ylabel'),'String','Fast Decay')
xlabel('Time(\musec)')
title('Multiple Decay Rates')
set(H1,'LineStyle','--')
set(H2,'LineStyle',':')
%% 三维绘图
t = 0:pi/50:10*pi;
plot3(sin(t),cos(t),t)
xlabel('sin(t)')
ylabel('cos(t)')
zlabel('t')
grid on
axis square

[x,y,z] = peaks(30);
mash(x,y,z)
grid
%% 图形窗口的分割
x=linspace(0, 2*pi, 60)
subplot(2, 2, 1)
plot(x, sin(x)-1);
title('sin(x)-1'); axis([0, 2*pi, -2, 0])
subplot(2, 1, 2)
plot(x, cos(x)+1);
title('cos(x)+1'); axis([0, 2*pi, 0, 2])
subplot(4, 4, 3)
plot(x, tan(x));
title('tan(x)'); axis([0, 2*pi, -40, 40])
subplot(4, 4, 8)
plot(x, cot(x));
title('cot(x)'); axis([0, 2*pi, -35, 35])