use strict;
use warnings;

use List::Util qw(shuffle min max);

use SDL;
use SDL::Event;
use SDL::Events;
use SDLx::App;
use SDLx::Text;
use SDLx::Rect;
use SDLx::Surface;

sub TO_SERVER { SDL_USEREVENT };
sub TO_CLIENT { SDL_USEREVENT + 1 };
# create our main screen
my $app = SDLx::App->new(
    w            => 400,
    h            => 512,
    exit_on_quit => 1,
    dt           => 0.2,
    title        => 'SDLx Tetris'
);

# create our game objects
my $score = SDLx::Text->new( font => 'font.ttf', h_align => 'center' );
my $back  = SDLx::Surface->load( 'data/tetris_back.png' );
my @piece = (undef);
push(@piece, SDLx::Surface->load( "data/tetris_$_.png" )) for(1..7);

my $client = {
    grid   => [],
    store  => [],
};
my $server = {
    grid   => [],
    store  => [],
};

my %pieces = (
    I => [0,5,0,0,
          0,5,0,0,
          0,5,0,0,
          0,5,0,0],
    J => [0,0,0,0,
          0,0,6,0,
          0,0,6,0,
          0,6,6,0],
    L => [0,0,0,0,
          0,2,0,0,
          0,2,0,0,
          0,2,2,0],
    O => [0,0,0,0,
          0,3,3,0,
          0,3,3,0,
          0,0,0,0],
    S => [0,0,0,0,
          0,4,4,0,
          4,4,0,0,
          0,0,0,0],
    T => [0,0,0,0,
          0,7,0,0,
          7,7,7,0,
          0,0,0,0],
    Z => [0,0,0,0,
          1,1,0,0,
          0,1,1,0,
          0,0,0,0],
);
my $next_tile         =  shuffle(keys %pieces);
my $curr_tile         = [undef, 4, 0];          # this is shared between client&server!! bad!
   @{$curr_tile->[0]} = @{$pieces{$next_tile}};
   $next_tile         =  shuffle(keys %pieces); # this is shared between client&server!! bad!

sub rotate_piece {
    my $_piece   = shift;
    my $_rotated = [];
    my $_i = 0;
    for(@{$_piece}) {
        $_rotated->[$_i + (($_i%4+1)*3) - (5*int($_i/4))] = $_;
        $_i++;
    }
    return $_rotated;
}

sub can_move_piece {
    my $direction = shift;
    my $amount    = shift || 1;

    for my $y (0..3) {
        for my $x (0..3) {
            if($curr_tile->[0]->[$x + 4 * $y]) {
                return if $direction eq 'left'  && $x - $amount + $curr_tile->[1]  < 0;
                return if $direction eq 'right' && $x + $amount + $curr_tile->[1]  > 9;
                return if $direction eq 'down'  && int($y + $amount + $curr_tile->[2]) > 22;
                
                return if $direction eq 'right' && $server->{store}->[ $x + $amount + $curr_tile->[1] + 10 * int($y           + $curr_tile->[2]) ];
                return if $direction eq 'left'  && $server->{store}->[ $x - $amount + $curr_tile->[1] + 10 * int($y           + $curr_tile->[2]) ];
                return if $direction eq 'down'  && $server->{store}->[ $x           + $curr_tile->[1] + 10 * int($y + $amount + $curr_tile->[2]) ];
            }
        }
    }

    return 1;
}

sub move_piece {
    my $direction = shift;
    my $amount    = shift || 1;

    if($direction eq 'right') {
        $curr_tile->[1] += $amount;
    }
    elsif($direction eq 'left') {
        $curr_tile->[1] -= $amount;
    }
    elsif($direction eq 'down') {
        $curr_tile->[2] += $amount;
    }
    
    @{$server->{grid}} = ();
    for my $y (0..3) {
        for my $x (0..3) {
            if($curr_tile->[0]->[$x + 4 * $y]) {
                $server->{grid}->[ $x + $curr_tile->[1] + 10 * ($y + int($curr_tile->[2])) ] = $curr_tile->[0]->[$x + 4 * $y];
            }
        }
    }

    return 1;
}

sub store_piece {
    for my $y (0..3) {
        for my $x (0..3) {
            if($curr_tile->[0]->[$x + 4 * $y]) {
                $server->{store}->[ $x + $curr_tile->[1] + 10 * ($y + int($curr_tile->[2])) ] = $curr_tile->[0]->[$x + 4 * $y];
            }
        }
    }
}

sub client_event_handler {
    my ( $event, $app ) = @_;

    if ( $event->type == SDL_KEYDOWN ) {
        if ( $event->key_sym & (SDLK_LEFT|SDLK_RIGHT|SDLK_UP|SDLK_DOWN) ) {
            my $new_event = SDL::Event->new();
            $new_event->type(TO_SERVER);
            $new_event->user_data1($event->key_sym);
            SDL::Events::push_event($new_event);
        }
    }
    elsif ( $event->type == SDL_KEYUP ) {
        if (   $event->key_sym == SDLK_UP
            or $event->key_sym == SDLK_DOWN )
        {
            #warn 'up/down released';
        }
    }
    elsif ( $event->type == TO_CLIENT ) {
        if($event->user_code(1)) {
            $client->{grid}  = $event->user_data1;
            $client->{store} = $event->user_data2;
        }
    }
}

sub server_event_handler {
    my ( $event, $app ) = @_;

    if ( $event->type == TO_SERVER ) {
        if(defined $curr_tile) {
            if($event->user_data1 == SDLK_LEFT && can_move_piece('left')) {
                move_piece('left');
            }
            elsif($event->user_data1 == SDLK_RIGHT && can_move_piece('right')) {
                move_piece('right');
            }
            elsif($event->user_data1 == SDLK_DOWN && can_move_piece('down')) {
                move_piece('down')
            }
            elsif($event->user_data1 == SDLK_UP) {
                $curr_tile->[0] = rotate_piece($curr_tile->[0]);
            }
        }
        my $new_event = SDL::Event->new();
        $new_event->type(TO_CLIENT);
        $new_event->user_code(1);
        $new_event->user_data1($server->{grid});
        $new_event->user_data2($server->{store});
        SDL::Events::push_event($new_event);
    }
    $event = undef; # should we do this?
}

$app->add_event_handler( \&client_event_handler );
$app->add_event_handler( \&server_event_handler );

$app->add_move_handler( sub {
    my ( $step, $app ) = @_;

    if(can_move_piece('down', $step / 2)) {
        move_piece('down', $step / 2);
    }
    else {
        store_piece($curr_tile); # placing the tile
        
        # checking for lines to delete
        my $y;
        my @to_delete = ();
        for($y = 22; $y >= 0; $y--) {
            # there is no space if min of this row is true (greater than zero)
            if(min(@{$server->{store}}[($y*10)..((($y+1)*10)-1)])) {
                push(@to_delete, $y);
            }
        }

        # deleting lines
        foreach(@to_delete) {
            splice(@{$server->{store}}, $_*10, 10);
        }
        
        # adding blank rows to the top
        foreach(@to_delete) {
            splice(@{$server->{store}}, 0, 0, (0,0,0,0,0,0,0,0,0,0));
        }
        
        # launching new tile
        @{$curr_tile->[0]}  = @{$pieces{$next_tile}};
        $curr_tile->[1]     = 4;
        $curr_tile->[2]     = 0;
        $next_tile          = shuffle(keys %pieces);
    }
});

# renders game objects on the screen
$app->add_show_handler(
    sub {
        # first, we clear the screen
        $app->draw_rect( [ 0, 0, $app->w, $app->h ], 0x000000 );
        $back->blit( $app );

        my $x = 0;
        my $y = 0;
        foreach(@{$client->{store}}) {
            $piece[$_]->blit( $app, undef, [ 28 + $x%10 * 20, 28 + $y * 20 ] ) if $_;
            $x++;
            $y++ unless $x % 10;
        }
        $x = 0;
        $y = 0;
        foreach(@{$client->{grid}}) {
            $piece[$_]->blit( $app, undef, [ 28 + $x%10 * 20, 28 + $y * 20 ] ) if $_;
            $x++;
            $y++ unless $x % 10;
        }
        my $next_tile_index = max(@{$pieces{$next_tile}});
        for $y (0..3) {
            for $x (0..3) {
                if($pieces{$next_tile}->[$x + 4 * $y]) {
                    $piece[$next_tile_index]->blit( $app, undef, [ 264 + $x * 20, 48 + $y * 20 ] );
                }
            }
        }
        # finally, we update the screen
        $app->update;
    }
);

# all is set, run the app!
$app->run();