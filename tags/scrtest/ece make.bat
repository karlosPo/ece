REM ���������� ������ ����������
Set TARGET=scrtest
Set ARGS=-O3

rem ������� ������
echo off
cls

del %TARGET%.exe
fpc %ARGS% %TARGET%.dpr
del *.o
del *.ppu
del *.or

start %TARGET%.exe

pause
taskkill /F /IM %TARGET%.exe