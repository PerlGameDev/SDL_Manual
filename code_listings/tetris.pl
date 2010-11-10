use strict;
use warnings;

use Data::Dumper;
use List::Util qw(shuffle);

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
};
my $server = {
    grid   => [],
    grid2  => [],
};

my $tile;
my %pieces = (
    I => [0,5,0,0,
          0,5,0,0,
          0,5,0,0,
          0,5,0,0],
    J => [0,0,0,0,
          0,0,6,0,
          0,0,6,0,
          0,6,6,0,
          0,0,0,0],
    L => [0,0,0,0,
          0,2,0,0,
          0,2,0,0,
          0,2,2,0,
          0,0,0,0],
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

sub check_collision {
    my ($A, $B) = @_;

    return if $A->bottom < $B->top;
    return if $A->top    > $B->bottom;
    return if $A->right  < $B->left;
    return if $A->left   > $B->right;

    # if we got here, we have a collision!
    return 1;
}

sub rotate {
    my $_piece   = shift;
    my $_rotated = [];
    my $_i = 0;
    for(@{$_piece}) {
        $_rotated->[$_i + (($_i%4+1)*3) - (5*int($_i/4))] = $_;
        $_i++;
    }
    return $_rotated;
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
        elsif ( $event->key_sym == SDLK_SPACE ) {
            my $x;
            my $y;
            for($y=0;$y<18;$y++) {
                for($x=0;$x<10;$x++) {
                    print ($server->{grid}->[$x+$y*10] || '0');
                }
                print "\n";
            }
            print "\n";
            ($tile->[0]) = shuffle(keys %pieces) if defined $tile;
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
        if($event->user_data1('grid')) {
            $client->{grid} = $event->user_data2;
        }
    }
}

sub server_event_handler {
    my ( $event, $app ) = @_;

    if ( $event->type == TO_SERVER ) {
        if(defined $tile) {
            if($event->user_data1 == SDLK_LEFT && $tile->[1] > 0) {
                $tile->[1]--;
            }
            elsif($event->user_data1 == SDLK_RIGHT && $tile->[1] + $pieces{$tile->[0]}->[0] < 10) {
                $tile->[1]++;
            }
            elsif($event->user_data1 == SDLK_DOWN && $tile->[2] + $pieces{$tile->[0]}->[1] - 1 < 24) {
                $tile->[2]++;
            }
            elsif($event->user_data1 == SDLK_UP) {
                $pieces{$tile->[0]} = rotate($pieces{$tile->[0]});
            }
        }
        my $new_event = SDL::Event->new();
        $new_event->type(TO_CLIENT);
        $new_event->user_data1('grid');
        $new_event->user_data2($server->{grid});
        SDL::Events::push_event($new_event);
    }
    $event = undef; # should we do this?
}

$app->add_event_handler( \&client_event_handler );
$app->add_event_handler( \&server_event_handler );

$app->add_move_handler( sub {
    my ( $step, $app ) = @_;

    unless(defined $tile) {
        $tile = ['J', 4, 0];
        ($tile->[0]) = shuffle(keys %pieces);
    }

    my $x = $tile->[1];
    my $y = int($tile->[2]);
    my $w = 4;
    my $h = 4;
    
    @{$server->{grid}} = @{$server->{grid2}};
    for my $y (0..3) {
        for my $x (0..3) {
            if($pieces{$tile->[0]}->[$x + 4 * $y]) {
                $server->{grid}->[ $x + $tile->[1] + 10 * ($y + int($tile->[2])) ] = $pieces{$tile->[0]}->[$x + 4 * $y];
            }
        }
    }
    
    $tile->[2] += $step * 0.5;
    if($tile->[2] >= 24) {
        @{$server->{grid2}} = @{$server->{grid}};
        $tile = undef;
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
        foreach(@{$client->{grid}}) {
            #$app->draw_rect( [ 28 + $x%10 * 20, 28 + $y * 20, 19, 19 ], 0xFF0000 ) if $_;
            $piece[$_]->blit( $app, undef, [ 28 + $x%10 * 20, 28 + $y * 20 ] ) if $_;
            $x++;
            $y++ unless $x%10;
        }
        # finally, we update the screen
        $app->update;
    }
);

# all is set, run the app!
$app->run();

