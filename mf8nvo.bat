@echo off
REM This batch file has been tested on
REM   computer: Pentium II
REM         OS: Windows NT 4.0 (service release 4)
REM   compiler: Digital Visual Fortran 6.0
REM          C: Microsoft Visual C++ 6.0
REM     OpenGL: Microsoft OpenGL, Glut 3.7.1, f90gl 1.2.0

REM ------------- User configuration parameters ---------------

REM modify these for your system

REM any relative paths should be relative to a subdirectory of the directory
REM containing this makefile

REM procedure name mangling approach used by your fortran compiler
REM  LOWERCASE  - convert to lower case
REM  UNDERSCORE - convert to lower case and append underscore
REM  UPPERCASE  - convert to upper case
set FNAME=UPPERCASE

REM the include directory for Windows visual C
set WININC=c:\Program Files\Microsoft Visual Studio\VC98\Include

REM fortran 90 compiler and compiler flags
set F90C=df
set F90FLAGS=

REM C compiler and compiler flags
set CC=cl
set CFLAGS=-DDVF -DWIN32 /I"%WININC%"
 
REM The compiler flag to get at the module file for opengl_kinds in ../include/GL
set USEMOD=/I"..\lib"

REM ----------- end of user configuration parameters ------------

REM The preprocessor
set F90PPR=..\util\sppr

REM The include file for f90ppr directives
set F90PPR_INC=..\fppincs\fpp8nvo

REM select action; default is install

if "%1"=="install" goto install
if "%1"=="clean" goto clean
if "%1"=="reallyclean" goto reallyclean

REM build and install the libraries

:install
cd util
call mf8nvo sppr
cd ..
cd gl
call mf8nvo install
cd ..
cd glu
call mf8nvo install
cd ..
cd glut
call mf8nvo install
cd ..
goto done

REM delete files created during compilation, but keep the libraries

:clean
cd gl
call mf8nvo clean
cd ..
cd glu
call mf8nvo clean
cd ..
cd glut
call mf8nvo clean
cd ..
cd examples
call mf8nvo clean
cd ..
cd util
call mf8nvo clean
cd ..
goto done

REM delete everything, including libraries and utilities

:reallyclean
cd gl
call mf8nvo clean
cd ..
cd glu
call mf8nvo clean
cd ..
cd glut
call mf8nvo clean
cd ..
cd examples
call mf8nvo clean
cd ..
cd util
call mf8nvo clean
cd ..
del lib\*.lib
del lib\*.mod
del lib\modtable.txt
goto done

:done
