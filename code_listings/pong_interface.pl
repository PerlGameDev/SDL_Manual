use strict;
use warnings;

use SDL;
use SDL::Event;
use SDL::Events;
use SDL::Rect;
use SDLx::App;
use SDLx::Controller::Interface;

package Ball;
use Class::XSAccessor {
    constructor => 'new',
    accessors => [ qw(x y w h v_x v_y) ],
};

sub check_collision {
    my ($ball, $paddle) = @_;

    if (    $ball->x   < ($paddle->x + $paddle->w)
        and $paddle->x < ($ball->x + $ball->w)
        and $ball->y   < ($paddle->y + $paddle->h)
        and $paddle->y < ($ball->y + $ball->h)
    ) {
        # reverse horizontal speed
        $ball->v_x( $ball->v_x * -1 );

        # mess a bit with vertical speed
        $ball->v_y( $ball->v_y + rand(1) - rand(1) );

        # collision came from the left!
        if ($ball->x < $paddle->x + $paddle->w / 2) {
            $ball->x( $paddle->x - $ball->w );
        }
        # collision came from the right
        else {
            $ball->x( $paddle->x + $paddle->w );
        }
        return 1;
    }
    return;
}

package Paddle;
use Class::XSAccessor {
    constructor => 'new',
    accessors => [ qw( x y w h v_y ) ],
};

package SDLx::Text;
use SDL;
use SDL::Video;
use SDL::TTF;
use Carp ();
use Class::XSAccessor {
    accessors => [ qw( _font _color size h_align x y w h surface) ],
};

sub new {
    my ($class, %options) = @_;
   
    my $file = $options{'font'}
        or Carp::croak 'must provide font filename';

    my $color = $options{'color'} || [255, 0, 0];
    my $size = $options{'size'} || 24;

    my $self = bless {}, ref($class) || $class;

    $self->x( $options{'x'} || 0 );
    $self->y( $options{'y'} || 0 );

    $self->h_align( $options{'h_align'} || 'left' );
    # TODO: validate
    # TODO: v_align
    # TODO: other accessors

    SDL::TTF::init;
    $self->_font( SDL::TTF::open_font($file, $size) );
    Carp::croak 'Error opening font: ' . SDL::get_error
        unless $self->_font;

    $self->_color( SDL::Color->new( @$color ) );

    return $self;
}

sub text {
    my ($self, $text) = @_;

    my $surface = SDL::TTF::render_text_blended($self->_font, $text, $self->_color)
                    or Carp::croak 'TTF rendering error: ' . SDL::get_error;

    $self->surface( $surface );
    $self->w( $surface->w );
    $self->h( $surface->h );
}

sub write_to {
    my ($self, $target, $text) = @_;

    $self->text($text) if $text;

    my $surface = $self->surface;

    if ($self->h_align eq 'center' ) {
       $self->x( ($target->w / 2) - ($surface->w / 2) );
    }
    # TODO: other alignments

    SDL::Video::blit_surface(
        $surface, SDL::Rect->new(0,0,$surface->w, $surface->h),
        $target, SDL::Rect->new($self->x, $self->y, $target->w, $target->h)
    );
    return;
}

sub write_xy {
    my ($self, $target, $x, $y, $text) = @_;

    $self->text($text) if $text;
    my $surface = $self->surface;

    $self->x($x);
    $self->y($y);

    SDL::Video::blit_surface(
        $surface, SDL::Rect->new(0,0,$surface->w, $surface->h),
        $target, SDL::Rect->new($x, $y, $target->w, $target->h)
    );
    return;
}

package main;

my $app = SDLx::App->new( w => 500, h => 500, exit_on_quit => 1, dt => 0.02 );

my $paddle1 = Paddle->new( x => 10, y => $app->h/2, w => 10, h => 40, v_y => 0);
my $paddle2 = Paddle->new( x => $app->w - 20, y => $app->h/2, w => 10, h => 40);

my $ball = Ball->new( x => $app->w/2, y => $app->h/2, w => 10, h => 10, v_x => 3, v_y => 1.7 );

my $text = SDLx::Text->new( font => 'font.ttf', h_align => 'center' );

my ($p1_score, $p2_score) = (0, 0);

sub on_ball_move {
    my ($step, $app) = @_;

    my $x = $ball->x + ($ball->v_x * $step);
    my $y = $ball->y + ($ball->v_y * $step);

    # collision to the bottom of the screen
    if ( $y >= ($app->h - $ball->h) ) {
        $y = $app->h - $ball->h;
        $ball->v_y( $ball->v_y * -1 );
    }
    # collision to the top of the screen
    elsif ( $y <= 0 ) {
        $y = 0;
        $ball->v_y( $ball->v_y * -1 );
    }
    # collision to the right: player 1 score!
    elsif ( $x >= ($app->w - $ball->w) ) {
        $p1_score++;
        $x = $app->w / 2;
        $y = $app->h / 2;
    }
    # collision to the left: player 2 score!
    elsif ( $x <= 0 ) {
        $p2_score++;
        $x = $app->w / 2;
        $y = $app->h / 2;
    }
    $ball->x( $x );
    $ball->y( $y );
    
    # collisions with players
    $ball->check_collision( $paddle1 )
        or $ball->check_collision( $paddle2 );
}

$app->add_move_handler( \&on_ball_move );

sub on_paddle1_move {
    my ($step, $app) = @_;

    $paddle1->y( $paddle1->y + ($paddle1->v_y * $step) );
};

$app->add_move_handler( \&on_paddle1_move );

$app->add_event_handler( sub {
    my ($event, $app) = @_;

    if ( $event->type == SDL_KEYDOWN ) {
        if ($event->key_sym == SDLK_UP) {
            $paddle1->v_y(-2);
        }
        elsif ($event->key_sym == SDLK_DOWN ) {
            $paddle1->v_y(2);
        }
    }
    elsif ( $event->type == SDL_KEYUP ) {
        if ($event->key_sym == SDLK_UP
         or $event->key_sym == SDLK_DOWN
        ) {
            $paddle1->v_y(0);
        }
    }
});

sub AI_move {
    my ($step, $app) = @_;

    if ($ball->y > $paddle2->y) {
        $paddle2->v_y(2);
    }
    elsif ($ball->y < $paddle2->y) {
        $paddle2->v_y(-2);
    }
    else {
        $paddle2->v_y(0);
    }

    $paddle2->y( $paddle2->y + ($paddle2->v_y * $step) );
}

$app->add_move_handler( \&AI_move );


# our 'view' of the game
################################

$app->add_show_handler( sub {

    # first, we clear the screen
    $app->draw_rect( [0,0,$app->w, $app->h], 0x000000);

    # then we render the ball
    $app->draw_rect( [$ball->x, $ball->y, $ball->w, $ball->h], 0xFF0000FF );

    # then we render each paddle
    $app->draw_rect( [$paddle1->x, $paddle1->y, $paddle1->w, $paddle1->h], 0xFF0000FF );
    $app->draw_rect( [$paddle2->x, $paddle2->y, $paddle2->w, $paddle2->h], 0xFF0000FF );

    # ... and each player's score!
    $text->write_to($app, "$p1_score x $p2_score");

    # finally, we update the screen
    $app->update;
});

$app->run();


