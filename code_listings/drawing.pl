use strict;
use warnings;

use SDL;
use SDLx::App;
my $app = SDLx::App->new(width => 400, height => 400, title => 'Pong - A clone');

$app->draw_rect([ 10, 20, 40 , 40], [255,255,255,255]);

$app->update();

sleep(2);
