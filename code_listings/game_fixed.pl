
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

    # Variables
    # to save our start/end and delta times for each frame
    # to save our frames and FPS
    my ( $start, $end, $delta_time, $FPS, $frames ) = ( 0, 0, 0, 0, 0 );

    # We will aim for a rate of 60 frames per second
    my $fixed_rate = 60;

    # Our times are in micro second, so we will compenstate for it
    my $fps_check = ( 1000 / $fixed_rate );

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

        $laser = 0 if $laser > $app->w;
    }

    sub render {

        #Draw the background first
        $app->draw_rect( [ 0, 0, $app->w, $app->h ], 0 );

        #Draw the laser
        $app->draw_rect( [ $laser, $app->h / 2, 10, 2 ], [ 255, 0, 0, 255 ] );

        #Draw our FPS on the screen so we can see
        $app->draw_gfx_text( [ 10, 10 ], [ 255, 0, 255, 255 ], "FPS: $FPS" );

        $app->update();
    }

    # Called at the end of each frame, wether we draw or not
    sub calculate_fps_at_frame_end {

        # Ticks are microseconds since load time
        $end = SDL::get_ticks();

     # We will average our frame rate over 10 frames, to give less erratic rates
        if ( $frames < 10 ) {

            #Count a frame
            $frames++;

            #Calculate how long it took from the start
            $delta_time += $end - $start;
        }
        else {

            # Our frame rate is our  Frames * 100 / Time Elapsed in us
            $FPS = int( ( $frames * 100 ) / $delta_time );

            # Reset our metrics
            $frames     = 0;
            $delta_time = 0;
        }

    }

    while ( !$quit ) {

        # Get the time for the starting of the frame
        $start = SDL::get_ticks();

        get_events();

        # If we are fixing the lower bounds of the frame rate
        if ( $ARGV[1] ) {

            # And our delta time is going too slow for frame check
            if ( $delta_time > $fps_check ) {

                # Calculate our FPS from this
                calculate_fps_at_frame_end();

                # Skip rendering and collision detections
                # The heavy functions in the game loop
                next;

            }

        }

        calculate_next_positions();
        render();

        # A normal frame with rendering actually performed
        calculate_fps_at_frame_end();

        # if we are fixing the upper bounds of the frame rate
        if ( $ARGV[0] ) {

            # and our delta time is going too fast compared to the frame check
            if ( $delta_time < $fps_check ) {

                # delay for the difference
                SDL::delay( $fps_check - $delta_time );
            }
        }

    }
