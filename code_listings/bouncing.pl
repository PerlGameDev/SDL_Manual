use strict;
use warnings;

use SDL;
use SDL::Video;
use SDL::Event;
use SDL::Events;

use SDLx::App;
use SDLx::Controller::Interface;
my $app = SDLx::App->new( w => 512, h => 512, dt => 0.02, flags => SDL_HWSURFACE|SDL_DOUBLEBUF );
my $ball =
  SDLx::Controller::Interface->new( x => 10, h => 10, v_x => 150, v_y => 150 );

$app->add_event_handler( sub { return 0 if $_[0]->type == SDL_QUIT; return 1 }
);

$ball->set_acceleration(
    sub {
        my ( $time, $s ) = @_;
        if ( $s->x >= $app->w - 10 ) {
            $s->x( $app->w - 11 );
            $s->v_x( -1 * $s->v_x );
        }
        elsif ( $s->x <= 0 ) {
            $s->x(11);
            $s->v_x( -1 * $s->v_x );
        }

        if ( $s->y >= $app->h - 10 ) {
            $s->y( $app->h - 11 );
            $s->v_y( $s->v_y * -0.9 );

        }
        elsif ( $s->y <= 0 ) {
            $s->y(11);
            $s->v_y( $s->v_y * -0.9 );

        }
	        return ( 0, 0, 0 );
    }
);

my $previous = [0,0,0,0];
$ball->attach(
    $app,
    sub {
        $app->draw_rect([0,0,$app->w, $app->h], 0 );
	my $current = [ $_[0]->x, $_[0]->y, 10, 10 ];
	$app->draw_rect( $current, 0xFF0000FF );
        $app->update( $current );
	$app->update( $previous );
	$previous = $current;
    }
);

$app->run();

