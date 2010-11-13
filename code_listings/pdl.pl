use strict;
use warnings;
use SDLx::App;
use PDL;

my $app = SDLx::App->new(
        title => "PDL and SDL aplication",
        width => 640, height => 480, eoq => 1 );


sub make_surface_piddle {
    my ( $bytes_per_pixel, $width, $height) = @_;
    my $piddle = zeros( byte, $bytes_per_pixel, $width, $height );
    my $pointer = $piddle->get_dataref();
	my $s = SDL::Surface->new_from(
		$pointer, $width, $height, 32,
		$width * $bytes_per_pixel
	);

    my $surface = SDLx::Surface->new( surface => $s );

    return ( $piddle, $surface );
} 


my ( $piddle, $surface ) = make_surface_piddle( 4, 400, 200 );

$app->add_move_handler( sub {

        SDL::Video::lock_surface($surface);

        $piddle->mslice( 'X',
            [ rand(400), rand(400), 1 ],
            [ rand(200), rand(200), 1 ] 
            ) .= pdl( rand(225), rand(225), rand(225), 255 );

        SDL::Video::unlock_surface($surface);
        } );


$app->add_show_handler( sub {

    $surface->blit( $app, [0,0,$surface->w,$surface->h], [10,10,0,0] );
    $app->update();

});

$app->run();
