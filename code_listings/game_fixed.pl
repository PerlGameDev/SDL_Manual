
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

my ( $start, $end, $delta_time, $FPS, $frames ) = ( 0, 0, 0, 0, 0 );

#Don't need to quit yet
my $quit = 0;

#Start lazer on the left
my $lazer = 0;

sub get_events {

	my $event = SDL::Event->new();

#Pump the event queue
	SDL::Events::pump_events;

	while ( SDL::Events::poll_event($event) ) {
		$quit = 1 if $event->type == SDL_QUIT;
	}
}

sub calculate_next_positions {
	$lazer++;

	$lazer = 0 if $lazer > $app->w;
}

sub render {

#Draw the background first
	$app->draw_rect( [ 0, 0, $app->w, $app->h ], 0 );

#Draw the lazer
	$app->draw_rect( [ $lazer, $app->h / 2, 10, 2 ], [ 255, 0, 0, 255 ] );

	$app->draw_gfx_text( [ 10, 10 ], [ 255, 0, 255, 255 ], "FPS: $FPS" );

	$app->update();
}

my $fps_check = (1000/60);

sub calculate_fps_at_frame_end
{

	$end = SDL::get_ticks();

	if ( $frames < 10 ) {
		$frames++;
		$delta_time += $end - $start;
	}
	else {
		$FPS        = int( ( $frames * 100 ) / $delta_time );
		$frames     = 0;
		$delta_time = 0;
	}



}

while ( !$quit ) {


	$start = SDL::get_ticks();

	get_events();

	if( $ARGV[1] )
	{
		if ( $delta_time > $fps_check ) {

			calculate_fps_at_frame_end();
			next;		  

		}

	}
	calculate_next_positions();
	render();


	calculate_fps_at_frame_end();


	if ( $ARGV[0] ) {
		if ( $delta_time < $fps_check ) {
			SDL::delay( $fps_check - $delta_time );
		}
	}


}
