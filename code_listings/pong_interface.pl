use strict;
use warnings;

use SDL;
use SDL::Event;
use SDL::Events;
use SDL::Rect;
use SDLx::App;
use SDLx::Text;
use SDLx::Rect;

my $app = SDLx::App->new(
    w            => 500,
    h            => 500,
    exit_on_quit => 1,
    dt           => 0.02,
    title        => 'SDLx Pong'
);

my $paddle1 = {
    rect => SDLx::Rect->new( 10, $app->h / 2, 10, 40 ),
    v_y  => 0,
};

my $paddle2 = {
    rect => SDLx::Rect->new( $app->w - 20, $app->h / 2, 10, 40 ),
    v_y  => 0,
};

my $ball = {
    rect => SDLx::Rect->new( 0, 0, 10, 10 ),
    v_x  => 3,
    v_y  => 1.7,
};
reset_game();

my $text = SDLx::Text->new( font => 'font.ttf', h_align => 'center' );

my ( $p1_score, $p2_score ) = ( 0, 0 );


sub check_collision {
    my ( $ball, $paddle ) = @_;

    my $ball_rect   = $ball->{rect};
    my $paddle_rect = $paddle->{rect};

    return if $ball_rect->bottom < $paddle_rect->top;
    return if $ball_rect->top    > $paddle_rect->bottom;
    return if $ball_rect->right  < $paddle_rect->left;
    return if $ball_rect->left   > $paddle_rect->right;

    # reverse horizontal speed
    $ball->{v_x} *= -1;

    # mess a bit with vertical speed
    $ball->{v_y} += $paddle->{v_y} * rand 1;

    # collision came from the left!
    if ( $ball_rect->x < $paddle_rect->x ) {
        $ball_rect->x( $paddle_rect->x - $ball_rect->w );
    }
    # collision came from the right
    else {
        $ball_rect->x( $paddle_rect->x + $paddle_rect->w );
    }
    return 1;
}

sub reset_game {
    $ball->{rect}->x( $app->w / 2 );
    $ball->{rect}->y( $app->h / 2 );

    $ball->{v_x} = (2 + rand 1) * (rand 2 > 1 ? -1 : 1);
    $ball->{v_y} = (2 + rand 1) * (rand 2 > 1 ? -1 : 1);

    $paddle1->{rect}->y( $app->w / 2 );
    $paddle2->{rect}->y( $app->w / 2 );
}

sub on_ball_move {
    my ( $step, $app ) = @_;

    my $x = $ball->{rect}->x + ( $ball->{v_x} * $step );
    my $y = $ball->{rect}->y + ( $ball->{v_y} * $step );

    # collision to the bottom of the screen
    if ( $y >= ( $app->h - $ball->{rect}->h ) ) {
        $y = $app->h - $ball->{rect}->h;
        $ball->{v_y} *= -1;
    }

    # collision to the top of the screen
    elsif ( $y <= 0 ) {
        $y = 0;
        $ball->{v_y} *= -1;
    }

    # collision to the right: player 1 score!
    elsif ( $x >= ( $app->w - $ball->{rect}->w ) ) {
        $p1_score++;
        reset_game();
        return;

    }

    # collision to the left: player 2 score!
    elsif ( $x <= 0 ) {
        $p2_score++;
        reset_game();
        return;
    }
    $ball->{rect}->x($x);
    $ball->{rect}->y($y);

    # collisions with players
    check_collision($ball, $paddle1)
        or check_collision($ball, $paddle2);
}

$app->add_move_handler( \&on_ball_move );

sub on_paddle1_move {
    my ( $step, $app ) = @_;

    $paddle1->{rect}->y( $paddle1->{rect}->y + ( $paddle1->{v_y} * $step ) );
}

$app->add_move_handler( \&on_paddle1_move );

$app->add_event_handler(
    sub {
        my ( $event, $app ) = @_;

        if ( $event->type == SDL_KEYDOWN ) {
            if ( $event->key_sym == SDLK_UP ) {
                $paddle1->{v_y} = -2;
            }
            elsif ( $event->key_sym == SDLK_DOWN ) {
                $paddle1->{v_y} = 2;
            }
        }
        elsif ( $event->type == SDL_KEYUP ) {
            if (   $event->key_sym == SDLK_UP
                or $event->key_sym == SDLK_DOWN )
            {
                $paddle1->{v_y} = 0;
            }
        }
    }
);

sub AI_move {
    my ( $step, $app ) = @_;

    if ( $ball->{rect}->y > $paddle2->{rect}->y ) {
        $paddle2->{v_y} = 2;
    }
    elsif ( $ball->{rect}->y < $paddle2->{rect}->y ) {
        $paddle2->{v_y} = -2;
    }
    else {
        $paddle2->{v_y} = 0;
    }

    $paddle2->{rect}->y( $paddle2->{rect}->y + ( $paddle2->{v_y} * $step ) );
}

$app->add_move_handler( \&AI_move );

# our 'view' of the game
################################

$app->add_show_handler(
    sub {

        # first, we clear the screen
        $app->draw_rect( [ 0, 0, $app->w, $app->h ], 0x000000 );

        # then we render the ball
        $app->draw_rect( $ball->{rect}, 0xFF0000FF );

        # then we render each paddle
        $app->draw_rect( $paddle1->{rect}, 0xFF0000FF );
        $app->draw_rect( $paddle2->{rect}, 0xFF0000FF );

        # ... and each player's score!
        $text->write_to( $app, "$p1_score x $p2_score" );

        # finally, we update the screen
        $app->update;
    }
);

$app->run();

