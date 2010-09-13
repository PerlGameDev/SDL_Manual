use strict;
use warnings;
use SDL;
use SDLx::App;
use SDLx::Sprite;

my $app = SDLx::App->new( w => 500, h => 500, d => 32, title => 'Pretty Flowers' );


my $flower = SDLx::Sprite->new ( width => 50, height => 100 );

$flower->surface->draw_rect   ( [0,0,50,100], 0x00000000 );

$flower->surface->draw_rect   ( [23,30, 4, 50], 0x00FF00FF );
$flower->surface->draw_circle_filled ( [25,25], 10, 0xBB0000FF );

$flower->surface->draw_circle ( [25,25], 10, 0xFF0000FF );


$flower->alpha_key( 0 );

$app->draw_rect( [0,0,500,500], [20,50,170, 255] );

$app->draw_rect( [0,400,500,100], [50,170,20,100] );

foreach( 0..500 )
{
	my $y =  425 - rand( 50 );
	$flower->draw_xy( $app, rand(500)-20, $y );
#	$flower->alpha( 1- $y/425 +0.25);

}
$app->update();
sleep(2);
