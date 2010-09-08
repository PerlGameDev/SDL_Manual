use strict;
use warnings;
use SDL;
use SDLx::App;

use Game::Life;
use Data::Dumper;

my $app = SDLx::App->new( w=>400, h=> 400);

my $game = new Game::Life(100);
my $starting = [ [ 1, 1, 1 ], [ 1, 0, 0 ], [ 0, 1, 0 ] ];

$game->place_points( 96, 96, $starting );
for ( 1 .. 100 ) {
	my $grid = $game->get_grid();
	$app->draw_rect( undef, 0 );
	foreach( 0..100 )
	  {
		my $x = $_;
		foreach( 0..100)
		{
		  $app->draw_rect( [$x*4, $_*4, 4,4 ], 0xFF0000FF )	if $grid->[$x][$_];
		}

	  }
	$game->process();
	$app->update();
}


sleep(2);
