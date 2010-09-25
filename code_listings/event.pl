use strict;
use warnings;
use SDL;
use SDL::Event;
use SDLx::App;

my $app = SDLx::App->new( w => 200, h => 200, d => 32, title => "Quit Events");
$app->add_event_handler( \&quit_event );
$app->run();

sub quit_event {

    my $event = shift;
    return 0 if $event->type == SDL_QUIT;
    return 1;
}
