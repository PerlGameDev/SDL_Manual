use strict;
use warnings;
use SDL;
use SDL::Event;
use SDLx::App;

my $app = SDLx::App->new(
    width  => 200,
    height => 200,
    title  => 'Pew Pew'
);

my $laser    = 0;
my $velocity = 10;

#We can add an event handler
$app->add_event_handler( \&quit_event );

#We tell app to handle the appropriate times to
#call both rendering and physics calculation

$app->add_move_handler( \&calculate_laser );
$app->add_show_handler( \&render_laser );

$app->run();

sub quit_event {

    #The callback is provided a SDL::Event to use
    my $event = shift;

    #Each event handler also returns you back the Controller call it
    my $controller = shift;

    #Stoping the controller for us will exit $app->run() for us
    $controller->stop if $event->type == SDL_QUIT;
}

sub calculate_laser {

    # The step is the difference in Time calculated for the
    # next jump
    my ( $step, $app, $t ) = @_;
    $laser += $velocity * $step;
    $laser = 0 if $laser > $app->w;
}

sub render_laser {
    my ( $delta, $app ) = @_;

    # The delta can be used to render blurred frames

    #Draw the background first
    $app->draw_rect( [ 0, 0, $app->w, $app->h ], 0 );

    #Draw the laser
    $app->draw_rect( [ $laser, $app->h / 2, 10, 2 ], [ 255, 0, 0, 255 ] );
    $app->update();

}
