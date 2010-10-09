
    use strict;
    use warnings;
    use SDL;
    use SDL::Event;
    use SDL::Events;
    use SDLx::App;

    my $app = SDLx::App->new(
        width  => 200,
        height => 200,
        title  => 'Pew Pew'
    );

    #Don't need to quit yet
    my $quit = 0;

    #Start laser on the left
    my $laser = 0;

    sub get_events {

        my $event = SDL::Event->new();

        #Pump the event queue
        SDL::Events::pump_events;

        while ( SDL::Events::poll_event($event) ) {
            $quit = 1 if $event->type == SDL_QUIT;
        }
    }

    sub calculate_next_positions {
        $laser++;
        $laser = 0 if $laser > $app->w();
    }

    sub render {

        #Draw the background first
        $app->draw_rect( [ 0, 0, $app->w, $app->h ], 0 );

        #Draw the laser
        $app->draw_rect( [ $laser, $app->h / 2, 10, 2 ], [ 255, 0, 0, 255 ] );

        $app->update();

    }

    while ( !$quit ) {
        get_events();
        calculate_next_positions();
        render();
    }

