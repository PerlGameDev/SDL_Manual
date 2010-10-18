use strict;
use warnings;

use SDL;
use SDL::Event;
use SDL::Events;
use SDLx::App;
use SDLx::Text;
use SDLx::Rect;


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
    v_x  => 3,
    v_y  => 1.7,
};

# initialize positions
reset_game();


sub check_collision {
    my ( $ball, $player) = @_;

    my $ball_rect = $ball->{rect};
    my $paddle = $player->{paddle};

    return if $ball_rect->bottom < $paddle->top;
    return if $ball_rect->top    > $paddle->bottom;
    return if $ball_rect->right  < $paddle->left;
    return if $ball_rect->left   > $paddle->right;

    # reverse horizontal speed
    $ball->{v_x} *= -1;

    # mess a bit with vertical speed
    $ball->{v_y} += $player->{v_y} * rand 1;

    # collision came from the left!
    if ( $ball_rect->x < $paddle->x ) {
        $ball_rect->x( $paddle->x - $ball_rect->w );
    }
    # collision came from the right
    else {
        $ball_rect->x( $paddle->x + $paddle->w );
    }
    return 1;
}

sub reset_game {
    $ball->{rect}->x( $app->w / 2 );
    $ball->{rect}->y( $app->h / 2 );

    $ball->{v_x} = (2 + rand 1) * (rand 2 > 1 ? -1 : 1);
    $ball->{v_y} = (2 + rand 1) * (rand 2 > 1 ? -1 : 1);

    $player1->{paddle}->y( $app->w / 2 );
    $player2->{paddle}->y( $app->w / 2 );
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
        $player1->{score}++;
        reset_game();
        return;

    }

    # collision to the left: player 2 score!
    elsif ( $x <= 0 ) {
        $player2->{score}++;
        reset_game();
        return;
    }
    $ball->{rect}->x($x);
    $ball->{rect}->y($y);

    # collisions with players
    check_collision($ball, $player1)
        or check_collision($ball, $player2);
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

    if ( $ball->{rect}->y > $player2->{paddle}->y ) {
        $player2->{v_y} = 2;
    }
    elsif ( $ball->{rect}->y < $player2->{paddle}->y ) {
        $player2->{v_y} = -2;
    }
    else {
        $player2->{v_y} = 0;
    }

    $player2->{paddle}->y(
        $player2->{paddle}->y + ( $player2->{v_y} * $step )
    );
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

# all is set, run the app!
$app->run();

