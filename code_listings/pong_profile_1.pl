use strict;
use warnings;

use SDL;
use SDL::Event;
use SDL::Events;
use SDLx::App;
use SDLx::Text;
use SDLx::Rect;

# profiling counter
my $profile_counter = 0;

# create our main screen
my $app = SDLx::App->new(
    w            => 500,
    h            => 500,
    exit_on_quit => 1,
    dt           => 0.02,
    title        => 'SDLx Pong'
);

# create our game objects
my $score = SDLx::Text->new( font => 'font.ttf', h_align => 'center' );

my $player1 = {
    paddle => SDLx::Rect->new( 10, $app->h / 2, 10, 40 ),
    v_y    => 0,
    score  => 0,
};

my $player2 = {
    paddle => SDLx::Rect->new( $app->w - 20, $app->h / 2, 10, 40 ),
    v_y    => 0,
    score  => 0,
};

my $ball = {
    rect => SDLx::Rect->new( 0, 0, 10, 10 ),
    v_x  => -2.7,
    v_y  => 1.8,
};

# initialize positions
reset_game();

sub check_collision {
    my ($A, $B) = @_;

    return if $A->bottom < $B->top;
    return if $A->top    > $B->bottom;
    return if $A->right  < $B->left;
    return if $A->left   > $B->right;

    # if we got here, we have a collision!
    return 1;
}

sub reset_game {
    $ball->{rect}->x( $app->w / 2 );
    $ball->{rect}->y( $app->h / 2 );
}

# handles keyboard events
$app->add_event_handler(
    sub {
        my ( $event, $app ) = @_;

        if ( $event->type == SDL_KEYDOWN ) {
            if ( $event->key_sym == SDLK_UP ) {
                $player1->{v_y} = -2;
            }
            elsif ( $event->key_sym == SDLK_DOWN ) {
                $player1->{v_y} = 2;
            }
        }
        elsif ( $event->type == SDL_KEYUP ) {
            if (   $event->key_sym == SDLK_UP
                or $event->key_sym == SDLK_DOWN )
            {
                $player1->{v_y} = 0;
            }
        }
    }
);


# handles the ball movement and collisions
$app->add_move_handler( sub {
    my ( $step, $app ) = @_;
    my $ball_rect = $ball->{rect};

    $ball_rect->x( $ball_rect->x + ($ball->{v_x} * $step) );
    $ball_rect->y( $ball_rect->y + ($ball->{v_y} * $step) );

    # collision to the bottom of the screen
    if ( $ball_rect->bottom >= $app->h ) {
        $ball_rect->bottom( $app->h );
        $ball->{v_y} *= -1;
    }

    # collision to the top of the screen
    elsif ( $ball_rect->top <= 0 ) {
        $ball_rect->top( 0 );
        $ball->{v_y} *= -1;
    }

    # collision to the right: player 1 score!
    elsif ( $ball_rect->right >= $app->w ) {
        $player1->{score}++;
        reset_game();
        return;
    }

    # collision to the left: player 2 score!
    elsif ( $ball_rect->left <= 0 ) {
        $player2->{score}++;
        reset_game();
        return;
    }

    # collision with player1's paddle
    elsif ( check_collision( $ball_rect, $player1->{paddle} )) {
        $ball_rect->left( $player1->{paddle}->right );
        $ball->{v_x} *= -1;
    }

    # collision with player2's paddle
    elsif ( check_collision( $ball_rect, $player2->{paddle} )) {
        $ball->{v_x} *= -1;
        $ball_rect->right( $player2->{paddle}->left );
    }
});

# handles the player's paddle movement
$app->add_move_handler( sub {
    my ( $step, $app ) = @_;
    my $paddle = $player1->{paddle};

    $paddle->y( $paddle->y + ( $player1->{v_y} * $step ));
});


# handles AI's paddle movement
$app->add_move_handler( sub {
    my ( $step, $app ) = @_;
    my $paddle = $player2->{paddle};
    my $v_y = $player2->{v_y};

    if ( $ball->{rect}->y > $paddle->y ) {
        $player2->{v_y} = 2;
    }
    elsif ( $ball->{rect}->y < $paddle->y ) {
        $player2->{v_y} = -2;
    }
    else {
        $player2->{v_y} = 0;
    }

    $paddle->y( $paddle->y + ( $v_y * $step ) );
});


# renders game objects on the screen
$app->add_show_handler(
    sub {
        # first, we clear the screen
        $app->draw_rect( [ 0, 0, $app->w, $app->h ], 0x000000 );

        # then we render the ball
        $app->draw_rect( $ball->{rect}, 0xFF0000FF );

        # then we render each paddle
        $app->draw_rect( $player1->{paddle}, 0xFF0000FF );
        $app->draw_rect( $player2->{paddle}, 0xFF0000FF );

        # ... and each player's score!
        $score->write_to( $app,
           $player1->{score} . ' x ' . $player2->{score}
        );

        # finally, we update the screen
        $app->update;
    }
);

# exit after a count of 100
$app->add_move_handler( sub{ $app->stop() if $profile_counter++ > 100 } );


# all is set, run the app!
$app->run();

