use strict;
use warnings;
use SDL;
use SDLx::App;
use SDL::Event;

use OpenGL qw/:all/;

my $app = SDLx::App->new( 
		title  => "OpenGL App",
		width  => 600,
		height => 600,
		gl     => 1,
		eoq    => 1
		);

glEnable(GL_DEPTH_TEST);
glMatrixMode(GL_PROJECTION);
glLoadIdentity;
gluPerspective(60, $app->w/$app->h, 1, 1000 );
glTranslatef( 0,0,-20);
glutInit();

my $rotate = [0,0];

$app->add_show_handler( 
		sub{
		my $dt = shift;

#clear the screen
		glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
		glColor3d(0,1,1);

		glPushMatrix();

		glRotatef($rotate->[0], 1,0,0);
		glRotatef($rotate->[1], 0,1,0);

		glutSolidTeapot(2); 

#sync the SDL application with the OpenGL buffer data
		$app->sync;

		glPopMatrix();
		}
		);

$app->add_event_handler(

		sub {
		my ($e ) = shift;

		if( $e->type == SDL_MOUSEMOTION )
		{
		$rotate = 	[$e->motion_x,  $e->motion_y];
		}

		}

		);

$app->run();

