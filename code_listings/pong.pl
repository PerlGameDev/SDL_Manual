use strict;
use warnings;

use SDL;
use SDL::Event;
use SDL::Events;

use SDLx::App;
use SDLx::Controller::Interface;

my $app = SDLx::App->new( w => 500, h => 500, dt => 0.02 );
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

$ball->attach(
    $app,
    sub {
        $app->draw_rect(
            [ $ball->previous->x - 10, $ball->previous->y - 10, 22, 22 ], 0 );
        $app->draw_rect( [ $_[0]->x, $_[0]->y, 10, 10 ], 0xFF0000FF );
        $app->update();
    }
);

$app->run();

