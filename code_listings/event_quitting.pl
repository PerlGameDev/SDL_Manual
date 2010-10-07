    use strict;
    use warnings;
    use SDL;
    use SDL::Event;
    use SDLx::App;

    my $app = SDLx::App->new( w => 200, h => 200, d => 32, title => "Quit Events" );

    #We can add an event handler 
    $app->add_event_handler( \&quit_event );

    #Then we will run the app
    #which will start a loop for keeping the app alive
    $app->run();

    sub quit_event
    {
        #The callback is provided a SDL::Event to use
	    my $event = shift;

	#Each event handler also returns you back the Controller call it
	    my $controller = shift;

        #Stoping the controller for us will exit $app->run() for us
	    $controller->stop if $event->type == SDL_QUIT;
    }


