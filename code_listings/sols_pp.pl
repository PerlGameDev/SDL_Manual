
use strict;
use warnings;

use SDL;
use SDLx::App;


sub render {
	my $screen = shift;
	if ( SDL::Video::MUSTLOCK($screen) ) {
		return if ( SDL::Video::lock_surface($screen) < 0 );
	}

	my $ticks = SDL::get_ticks();
	my ( $i, $y, $yofs, $ofs ) = ( 0, 0, 0, 0 );
	for ( $i = 0; $i < 480; $i++ ) {
		for ( my $j = 0, $ofs = $yofs; $j < 640; $j++, $ofs++ ) {
			$screen->set_pixels( $ofs, ( $i * $i + $j * $j + $ticks ) );
		}
		$yofs += $screen->pitch / 4;
	}


	SDL::Video::unlock_surface($screen) if ( SDL::Video::MUSTLOCK($screen) );

	SDL::Video::update_rect( $screen, 0, 0, 640, 480 );

	return 0;
}


my $app = SDLx::App->new( width => 640, height => 480, eoq => 1, title => "Grovvy XS Effects" );

$app->add_show_handler( sub{ render( $app ) } );

$app->run();

