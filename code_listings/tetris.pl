use strict;
use warnings;

use Data::Dumper;

use SDL;
use SDL::Event;
use SDL::Events;
use SDLx::App;
use SDLx::Text;
use SDLx::Rect;

sub TO_SERVER { SDL_USEREVENT };
sub TO_CLIENT { SDL_USEREVENT + 1 };
# create our main screen
my $app = SDLx::App->new(
    w            => 500,
    h            => 500,
    exit_on_quit => 1,
    dt           => 0.2,
    title        => 'SDLx Tetris'
);

# create our game objects
my $score = SDLx::Text->new( font => 'font.ttf', h_align => 'center' );

my $client = {
    grid   => [],
};
my $server = {
    grid   => [],
    grid2  => [],
};

my $tile;
my @pieces = (
    [4,1,1,2,1,1],         # I
    [2,4,0,1,0,2,0,1,0,1], # -
    [4,1,1,2,1,1],         # I
    [2,4,0,1,0,2,0,1,0,1], # -
    [3,2,1,0,0,2,1,1], # J
    [2,3,2,1,1,0,1,0], # J
    [3,2,1,0,0,2,1,1], # J
    [3,2,1,0,0,2,1,1], # J
    [3,2,0,0,1,1,1,2], # L
    [3,2,0,0,1,1,1,2], # L
    [3,2,0,0,1,1,1,2], # L
    [3,2,0,0,1,1,1,2], # L
    [2,2,2,1,1,1],     # O
    [2,2,2,1,1,1],     # O
    [2,2,2,1,1,1],     # O
    [2,2,2,1,1,1],     # O
    [3,2,0,2,1,1,1,0], # S
    [3,2,0,2,1,1,1,0], # S
    [3,2,0,2,1,1,1,0], # S
    [3,2,0,2,1,1,1,0], # S
    [3,2,0,1,0,1,2,1], # T
    [3,2,0,1,0,1,2,1], # T
    [3,2,0,1,0,1,2,1], # T
    [3,2,0,1,0,1,2,1], # T
    [3,2,1,2,0,0,1,1], # Z
    [3,2,1,2,0,0,1,1], # Z
    [3,2,1,2,0,0,1,1], # Z
    [3,2,1,2,0,0,1,1], # Z
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
            elsif($event->user_data1 == SDLK_RIGHT && $tile->[1] + $pieces[$tile->[0]]->[0] < 10) {
                $tile->[1]++;
            }
            elsif($event->user_data1 == SDLK_DOWN && $tile->[2] + $pieces[$tile->[0]]->[1] - 1 < 20) {
                $tile->[2]++;
            }
            elsif($event->user_data1 == SDLK_UP) {
                $tile->[0] = int($tile->[0]/4)*4 + ($tile->[0]%4 + 1)%4;
            }
        }
        my $new_event = SDL::Event->new();
        $new_event->type(TO_CLIENT);
        $new_event->user_data1('grid');
        $new_event->user_data2($server->{grid});
        SDL::Events::push_event($new_event);
    }
}

$app->add_event_handler( \&client_event_handler );
$app->add_event_handler( \&server_event_handler );

$app->add_move_handler( sub {
    my ( $step, $app ) = @_;

    $tile = [int(rand(7))*4, 4, 0] unless defined $tile;

    my $x = $tile->[1];
    my $y = int($tile->[2]);
    my $w = $pieces[$tile->[0]]->[0];
    my $h = $pieces[$tile->[0]]->[1];
    
    @{$server->{grid}} = @{$server->{grid2}};
    for(2..$#{$pieces[$tile->[0]]}) {
        $server->{grid}->[ $x + 10 * $y ] = $pieces[$tile->[0]]->[$_] if $pieces[$tile->[0]]->[$_];
        $x++;
        unless(($_-1) % $w) {
            $y++;
            $x = $tile->[1];
        }
    }
    $tile->[2] += $step * 0.5;
    if($y + $h - 1 >= 20) {
        @{$server->{grid2}} = @{$server->{grid}};
        $tile = undef;
    }
});

# renders game objects on the screen
$app->add_show_handler(
    sub {
        # first, we clear the screen
        $app->draw_rect( [ 0, 0, $app->w, $app->h ], 0x000000 );

        my $x = 0;
        my $y = 0;
        foreach(@{$client->{grid}}) {
            $app->draw_rect( [ $x%10 * 20, $y * 20, 19, 19 ], 0xFF0000 ) if $_;
            $x++;
            $y++ unless $x%10;
        }
        # finally, we update the screen
        $app->update;
    }
);

# all is set, run the app!
$app->run();

