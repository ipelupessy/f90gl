REM Many of the macros are inherited from the makefile in the parent directory

REM select what to make; default is library

if "%1"=="library" goto library
if "%1"=="install" goto install
if "%1"=="clean" goto clean

REM build libraries

:library

REM make the include file of preprocessor directives

%F90C% isshort.f90 %F90FLAGS%
type %F90PPR_INC% > fppr.inc
isshort
type defshort >> fppr.inc

REM make the C wrappers

%CC% %CFLAGS% /DFNAME=%FNAME% /c cwrap.c

REM make the opengl_kinds module

%F90PPR% < glkinds.fpp > glkinds.f90
%F90C% -c glkinds.f90 %F90FLAGS% %USEMOD%

REM make the interface module, Fortran wrappers and module opengl_gl

%F90PPR% < interf.fpp > interf.f90
%F90C% -c interf.f90 %F90FLAGS% %USEMOD%
%F90PPR% < fwrap.fpp > fwrap.f90
%F90C% -c fwrap.f90 %F90FLAGS% %USEMOD%

REM package them into the libraries

f95 -package f90gl interf.obj fwrap.obj glkinds.obj -mslink cwrap.obj opengl32.lib msvcrt.lib

goto done

REM install the libraries

:install

REM first build them
call mf8nao library

REM then move them

if not exist ..\lib mkdir ..\lib
if exist ..\lib\f90gl.dll del /s/q ..\lib\f90gl.dll
if exist ..\lib\f90gl.lib del /s/q ..\lib\f90gl.lib
if exist ..\lib\f90gl rmdir /s/q ..\lib\f90gl
move f90gl.dll ..\lib\
move f90gl.lib ..\lib\
move f90gl ..\lib\

goto done

REM delete everything created while building the libraries

:clean

del fppr.inc fwrap.f90 interf.f90 glkinds.f90 isshort.exe *.obj *.map *.mod *.lib *.lnk modtable.txt defshort *.exp
rmdir /s/q album
goto done

:done
