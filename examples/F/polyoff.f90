! Example polyoff translated to Fortran by William F. Mitchell, NIST.
! The Fortran version is a contribution of NIST and not suject to copyright.
! The original C version contained the following copyright notice:
!/*
! * Copyright (c) 1993-1997, Silicon Graphics, Inc.
! * ALL RIGHTS RESERVED 
! * Permission to use, copy, modify, and distribute this software for 
! * any purpose and without fee is hereby granted, provided that the above
! * copyright notice appear in all copies and that both the copyright notice
! * and this permission notice appear in supporting documentation, and that 
! * the name of Silicon Graphics, Inc. not be used in advertising
! * or publicity pertaining to distribution of the software without specific,
! * written prior permission. 
! *
! * THE MATERIAL EMBODIED ON THIS SOFTWARE IS PROVIDED TO YOU "AS-IS"
! * AND WITHOUT WARRANTY OF ANY KIND, EXPRESS, IMPLIED OR OTHERWISE,
! * INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY OR
! * FITNESS FOR A PARTICULAR PURPOSE.  IN NO EVENT SHALL SILICON
! * GRAPHICS, INC.  BE LIABLE TO YOU OR ANYONE ELSE FOR ANY DIRECT,
! * SPECIAL, INCIDENTAL, INDIRECT OR CONSEQUENTIAL DAMAGES OF ANY
! * KIND, OR ANY DAMAGES WHATSOEVER, INCLUDING WITHOUT LIMITATION,
! * LOSS OF PROFIT, LOSS OF USE, SAVINGS OR REVENUE, OR THE CLAIMS OF
! * THIRD PARTIES, WHETHER OR NOT SILICON GRAPHICS, INC.  HAS BEEN
! * ADVISED OF THE POSSIBILITY OF SUCH LOSS, HOWEVER CAUSED AND ON
! * ANY THEORY OF LIABILITY, ARISING OUT OF OR IN CONNECTION WITH THE
! * POSSESSION, USE OR PERFORMANCE OF THIS SOFTWARE.
! * 
! * US Government Users Restricted Rights 
! * Use, duplication, or disclosure by the Government is subject to
! * restrictions set forth in FAR 52.227.19(c)(2) or subparagraph
! * (c)(1)(ii) of the Rights in Technical Data and Computer Software
! * clause at DFARS 252.227-7013 and/or in similar or successor
! * clauses in the FAR or the DOD or NASA FAR Supplement.
! * Unpublished-- rights reserved under the copyright laws of the
! * United States.  Contractor/manufacturer is Silicon Graphics,
! * Inc., 2011 N.  Shoreline Blvd., Mountain View, CA 94039-7311.
! *
! * OpenGL(R) is a registered trademark of Silicon Graphics, Inc.
! */

!   polyoff.f90
!   This program demonstrates polygon offset to draw a shaded
!   polygon and its wireframe counterpart without ugly visual
!   artifacts ("stitching").

module polyoff
use opengl_gl
use opengl_glu
use opengl_glut

private
public :: gfxinit, keyboard, display, mouse

integer(kind=GLuint), private :: list
integer(kind=GLint), private :: spinx = 0
integer(kind=GLint), private :: spiny = 0
real(kind=GLfloat), private :: tdist = 0.0
real(kind=GLfloat), private :: polyfactor = 1.0
real(kind=GLfloat), private :: polyunits = 1.0

contains

!   display() draws two spheres, one with a gray, diffuse material,
!   the other sphere with a magenta material with a specular highlight.

subroutine display()

    real(kind=GLfloat), dimension(4) :: &
                     mat_ambient = (/ 0.8, 0.8, 0.8, 1.0 /), &
                     mat_diffuse = (/ 1.0, 0.0, 0.5, 1.0 /), &
                     mat_specular = (/ 1.0, 1.0, 1.0, 1.0 /), &
                     gray = (/ 0.8, 0.8, 0.8, 1.0 /), &
                     black = (/ 0.0, 0.0, 0.0, 1.0 /)

    call glClear (ior(GL_COLOR_BUFFER_BIT,GL_DEPTH_BUFFER_BIT))
    call glPushMatrix ()
    call glTranslatef (0.0, 0.0, tdist)
    call glRotatef (real(spinx,GLfloat), 1.0, 0.0, 0.0)
    call glRotatef (real(spiny,GLfloat), 0.0, 1.0, 0.0)

    call glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, gray)
    call glMaterialfv(GL_FRONT, GL_SPECULAR, black)
    call glMaterialf(GL_FRONT, GL_SHININESS, 0.0)
    call glEnable(GL_LIGHTING)
    call glEnable(GL_LIGHT0)
    call glEnable(GL_POLYGON_OFFSET_FILL)
    call glPolygonOffset(polyfactor, polyunits)
    call glCallList (list)
    call glDisable(GL_POLYGON_OFFSET_FILL)

    call glDisable(GL_LIGHTING)
    call glDisable(GL_LIGHT0)
    call glColor3f (1.0, 1.0, 1.0)
    call glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
    call glCallList (list)
    call glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)

    call glPopMatrix ()
    call glFlush ()
end subroutine display

!   specify initial properties
!   create display list with sphere  
!   initialize lighting and depth buffer

subroutine gfxinit ()

    real(kind=GLfloat), dimension(4) :: &
                     light_ambient = (/ 0.0, 0.0, 0.0, 1.0 /), &
                     light_diffuse = (/ 1.0, 1.0, 1.0, 1.0 /), &
                     light_specular = (/ 1.0, 1.0, 1.0, 1.0 /), &
                     light_position = (/ 1.0, 1.0, 1.0, 0.0 /), &
                     global_ambient = (/ 0.2, 0.2, 0.2, 1.0 /)

    call glClearColor (0.0, 0.0, 0.0, 1.0)

    list = glGenLists(1)
    call glNewList (list, GL_COMPILE)
       call glutSolidSphere(1.0_gldouble, 20_glint, 12_glint)
    call glEndList ()

    call glEnable(GL_DEPTH_TEST)

    call glLightfv (GL_LIGHT0, GL_AMBIENT, light_ambient)
    call glLightfv (GL_LIGHT0, GL_DIFFUSE, light_diffuse)
    call glLightfv (GL_LIGHT0, GL_SPECULAR, light_specular)
    call glLightfv (GL_LIGHT0, GL_POSITION, light_position)
    call glLightModelfv (GL_LIGHT_MODEL_AMBIENT, global_ambient)
end subroutine gfxinit

!   call when window is resized
subroutine reshape(width, height)
integer(kind=glcint), intent(inout) :: width, height

    call glViewport (0, 0, width, height)
    call glMatrixMode (GL_PROJECTION)
    call glLoadIdentity ()
    call gluPerspective(45.0_gldouble, &
                        real(width,GLdouble)/real(height,GLdouble), &
	                1.0_gldouble, 10.0_gldouble)
    call glMatrixMode (GL_MODELVIEW)
    call glLoadIdentity ()
    call gluLookAt (0.0_gldouble, 0.0_gldouble, 5.0_gldouble, &
                    0.0_gldouble, 0.0_gldouble, 0.0_gldouble, &
                    0.0_gldouble, 1.0_gldouble, 0.0_gldouble)
end subroutine reshape

!   call when mouse button is pressed
subroutine mouse(button, state, x, y)
integer(kind=glcint), intent(inout) :: button, state, x, y
    select case (button)
	case (GLUT_LEFT_BUTTON)
	    select case (state)
		case (GLUT_DOWN)
		    spinx = modulo((spinx + 5),360)
                    call glutPostRedisplay()
		case default
            end select
	case (GLUT_MIDDLE_BUTTON)
	    select case (state)
		case (GLUT_DOWN)
		    spiny = modulo((spiny + 5),360)
                    call glutPostRedisplay()
		case default
            end select
	case (GLUT_RIGHT_BUTTON)
	    select case (state)
		case (GLUT_UP)
                    stop
		case default
            end select
        case default
    end select
end subroutine mouse

subroutine keyboard (key, x, y)
integer(kind=glint), intent(inout) :: key
integer(kind=glcint), intent(inout) :: x, y

   select case (key)
      case (ichar("t"))
         if (tdist < 4.0) then
            tdist = (tdist + 0.5)
            call glutPostRedisplay()
         endif
      case (ichar("T"))
         if (tdist > -5.0) then
            tdist = (tdist - 0.5)
            call glutPostRedisplay()
         endif
      case (ichar("F"))
         polyfactor = polyfactor + 0.1
	 print *, "polyfactor is ", polyfactor
         call glutPostRedisplay()
      case (ichar("f"))
         polyfactor = polyfactor - 0.1
	 print *, "polyfactor is ", polyfactor
         call glutPostRedisplay()
      case (ichar("U"))
         polyunits = polyunits + 1.0
	 print *, "polyunits is ", polyunits
         call glutPostRedisplay()
      case (ichar("u"))
         polyunits = polyunits - 1.0
	 print *, "polyunits is ", polyunits
         call glutPostRedisplay()
      case default
   end select
end subroutine keyboard

end module polyoff

!   Main Loop
!   Open window with initial window size, title bar, 
!   RGBA display mode, and handle input events.

program main
use polyoff
use opengl_gl
use opengl_glut

integer(kind=glcint) :: iwin
    call glutInit()
    call glutInitDisplayMode(ior(ior(GLUT_SINGLE,GLUT_RGB),GLUT_DEPTH))
    iwin = glutCreateWindow("polyoff")
    call glutReshapeFunc(reshape)
    call glutDisplayFunc(display)
    call glutMouseFunc(mouse)
    call glutKeyboardFunc(keyboard)
    call gfxinit()
    call glutMainLoop()
end program main
