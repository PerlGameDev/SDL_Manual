use strict;
use warnings;
use SDL;
use SDL::Event;
use SDLx::App;

my $app = SDLx::App->new( w => 200, h => 200, d => 32, title => "Quit Events");
$app->add_event_handler( \&quit_event );
$app->add_event_handler( \&mouse_event );
$app->add_event_handler( \&keyboard_event );
$app->run();

sub quit_event {

    my $event = shift;
    return 0 if $event->type == SDL_QUIT;
    return 1;
}

my $drawing = 0;
my $brush_color  = 0;
sub mouse_event {
	
   my $event = shift;

              if($event->type == SDL_MOUSEBUTTONDOWN || $drawing)
               {
                   # now you can handle the details
                  $drawing = 1;
                  my $x =  $event->button_x;
                  my $y =  $event->button_y;
		  my $colors = [ 0xFF0000FF, 0x00FF00FF, 0x0000FFFF, 0, 0xFFFFFFFF ];
		  $app->[$x][$y] = $colors->[$brush_color]
		  $app->update();
               }
	     $drawing = 0 if($event->type == SDL_MOUSEBUTTONUP );
	

     return 1;
}

sub keyboard_event {

    my $event = shift;

    if ( $event->type == SDL_KEYDOWN )
	{
	    	my $key_name = SDL::Events::get_key_name( $event->key_sym );

		$brush_color = $key_name if $key_name =~ /\d/;
		
		warn 'Brush color is '.$brush_color;
	}
    return 1;
}
