use strict;
use warnings;

use SDL;
use SDLx::App;
my $app = SDLx::App->new(width => 400, height => 400, title => 'Pong - A clone');

$app->draw_line( [200,20], [20,200], [255, 255, 0, 255] );

$app->draw_rect([ 10, 20, 40 , 40], [255,255,255,255]);

$app->draw_circle([100,100], 20, [255,0,0,255]);

$app->draw_circle_filled( [100,100], 19, [0,0,255,255] );

$app->update();

sleep(2);
