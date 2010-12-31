use strict;
use warnings;
use SDL;
use SDL::Video;
use SDLx::App;

my $app = SDLx::App->new(
		w     => 600,
		h     => 600,
		eoq   => 1,
		flags => SDL_HWSURFACE | SDL_DOUBLEBUF,
		init  => SDL_INIT_VIDEO,
		title => 'Profiling',
		dt    => 0.2
		);

my $walkers = [];

my $profile_counter = 0;

foreach(0..20)
{

	$walkers->[$_] = { 		
		id       => $_,
		position => [ rand() * 600, rand() * 600 ],
		velocity => [ rand() * 20, rand() * 20 ],
		color    => [ 255, 0, 0, 255 ]
		}


}

sub show_blocks{ 
		$app->draw_rect( [ 0, 0, 600, 600 ], 0 );

		foreach ( @{$walkers} ) {
			$app->draw_rect( [ @{ $_->{position} }, 5, 5 ], $_->{color} );
		}

		$app->flip();

}

sub move_blocks{
		my $dt = shift;
		foreach ( @{$walkers} ) {

		$_->{position}->[0] += $_->{velocity}->[0] * $dt;
		$_->{velocity}->[0] *= -1
		if ( $_->{position}->[0] > 590 || $_->{position}->[0] < 0 );
		$_->{position}->[1] += $_->{velocity}->[1] * $dt;
		$_->{velocity}->[1] *= -1
		if ( $_->{position}->[1] > 590 || $_->{position}->[1] < 0 );

		}

 }

$app->add_show_handler( \&show_blocks );
$app->add_move_handler( \&move_blocks );

$app->add_move_handler( sub {$app->stop() if $profile_counter++ > 100; } );

$app->run();
