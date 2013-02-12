use Modern::Perl;
use SDL;
use SDL::Video;
use SDL::Color;
use SDL::Image;
use SDL::Event;
use SDL ':init';
use SDL::Event;
use SDL::Events ':all';
my $screen_width  = 300;
my $screen_height = 340;
my $x             = 0;
my $quit          = 0;
SDL::init(SDL_INIT_VIDEO);

# make a screen surface
my $screen_surface
    = SDL::Video::set_video_mode( $screen_width, $screen_height, 8,
    SDL_SWSURFACE | SDL_HWPALETTE );

# load and blit an image
my $img = SDL::Image::load('froggs.png');

# this image blit only needs to be done *once* :)
SDL::Video::blit_surface( $img, undef, $screen_surface, undef );


while ( !$quit ) {

    # check for a quit?
    get_events();
    #
    set_palette();
}

sub get_events {
    my $event = SDL::Event->new();

    #Pump the event queue
    SDL::Events::pump_events;
    while ( SDL::Events::poll_event($event) ) {
        $quit = 1 if $event->type == SDL_QUIT;
    }
}

sub set_palette {
    my @clrs;

    #push 256 color objects into an array
    foreach my $i ( 0 .. 255 ) { $clrs[$i] = SDL::Color->new( $x, 0, $i ); }

    # update surfaces' palette with 256 new colors
    my $rc
        = SDL::Video::set_palette( $screen_surface, SDL_PHYSPAL, 0, @clrs );
    $x++;
    $x = 0 if $x == 255;
}