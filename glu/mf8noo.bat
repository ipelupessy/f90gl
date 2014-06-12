REM Many of the macros are inherited from the makefile in the parent directory

REM select what to make; default is library

if "%1"=="library" goto library
if "%1"=="install" goto install
if "%1"=="clean" goto clean

REM build libraries

:library

REM get the include file of preprocessor directives

copy %F90PPR_INC% fppr.inc
..\gl\isshort
type defshort >> fppr.inc

REM make the C wrappers

%CC% %CFLAGS% /DFNAME=%FNAME% /c cwrapglu.c

REM make the interface module, Fortran wrappers and module opengl_gl

%F90PPR% < intrfglu.fpp > intrfglu.f90
%F90C%  intrfglu.f90 %F90FLAGS% %USEMOD%
%F90PPR% < fwrapglu.fpp > fwrapglu.f90
%F90C%  fwrapglu.f90 %F90FLAGS% %USEMOD%

REM package them into the libraries

slink /out:f90GLU.lib -addobj:cwrapglu.obj  -addobj:fwrapglu.OBJ
goto done                                  

REM install the libraries

:install

REM first build them
call mf8noo library

REM then move them

move *.lib ..\lib
move *.mod ..\lib
goto done

REM delete everything created while building the libraries

:clean

del fppr.inc fwrapglu.f90 intrfglu.f90 *.obj *.map *.mod *.lib *.lnk modtable.txt defshort
goto done

:done
