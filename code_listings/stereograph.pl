use strict;
use warnings;

use Cwd;
use Carp;
use File::Spec;

use threads;
use threads::shared;

use SDL;
use SDL::Event;
use SDL::Events;

use SDL::Audio;
use SDL::Mixer;
use SDL::Mixer::Music;
use SDL::Mixer::Effects;

use SDLx::App;

my $stream_data :shared = '';
my $stream_lock :shared = 0;


my $lines = 100;

my $app = SDLx::App->new(
    init   => SDL_INIT_AUDIO | SDL_INIT_VIDEO,
	width  => 800,
	height => 600,
	depth  => 32,
    title  => "Sound Event Demo",
    eoq    => 1,
	dt     => 0.2,
);

# Initialize the Audio
unless ( SDL::Mixer::open_audio( 44100, AUDIO_S16, 2, 1024 ) == 0 ) {
    Carp::croak "Cannot open audio: " . SDL::get_error();
}

# Load our music files
my $data_dir = '.';
my @songs = glob 'data/music/*.ogg';

# Music Effect to pull Stream Data 
sub music_data {
	my $channel = shift;
	my $samples = shift;
	my $position = shift;
	my @stream = @_;

	if( $stream_lock != 0 )	
	{
		$stream_data = join ',', @stream;
		$stream_lock = 0;
	}
	return @stream;
}

sub done_music_data { }
# Music Playing Callbacks 
my $current_song = 0;

my $current_music_callback = sub { 
	my( $delta, $app ) = @_;

	
	if( $stream_lock == 0  ){

	$app->draw_rect([ 0, 0, $app->w(), $app->h()], 0x000000FF );

            my @stream = split( ',', $stream_data );
            $stream_data = '';
			my @left;
            my @right;
            my $cut =  $#stream/$lines;
            my @x;
                       
            my $l_wdt= ( $app->w() / $lines) /2;
            
            
            for ( my $i = 0 ; $i < $#stream ; $i += $cut ) {

                my $left  = $stream[$i];
                my $right = $stream[ $i + 1 ];

                my $point_y   = ( ( ($left) ) * $app->h()/4 / 32000 ) + ($app->h/2);
                my $point_y_r = ( ( ($right) ) * $app->h()/4 / 32000 )+ ($app->h/2);
                my $point_x   = ( $i / $#stream ) * $app->w;
                
           
                SDL::GFX::Primitives::box_RGBA(  $app, $point_x-$l_wdt, 300, $point_x+$l_wdt, $point_y, 40, 0, 255, 128 );
                SDL::GFX::Primitives::box_RGBA(  $app, $point_x-$l_wdt, 300, $point_x+$l_wdt, $point_y_r , 255, 0, 40, 128 );

            }
        
	
		$stream_lock = 1;
	}
	$app->flip();
};

my $cms_move_callback;
my $pns_move_callback; 

my $play_next_song_callback = sub {

	$app->stop() if $current_song > $#songs;
	my $song = SDL::Mixer::Music::load_MUS($songs[$current_song++]);
	
	SDL::Mixer::Music::hook_music_finished('main::music_finished_playing');
	SDL::Mixer::Music::play_music($song, 0 );

	$app->remove_move_handler( $pns_move_callback ) if defined $pns_move_callback;
	$cms_move_callback = $app->add_show_handler( $current_music_callback );
};

sub music_finished_playing { 

	SDL::Mixer::Music::halt_music();
	$pns_move_callback = $app->add_move_handler( $play_next_song_callback ); 
	$app->remove_show_handler($cms_move_callback); 

}
my $music_data_effect_id = 
      SDL::Mixer::Effects::register( MIX_CHANNEL_POST, "main::music_data",
        "main::done_music_data", 0 );

$app->add_event_handler(
sub {
	my ($event, $app) = @_;

	if( $event->type == SDL_KEYDOWN && $event->key_sym == SDLK_DOWN)
	{	
		#Indicate that we are done playing the music_finished_playing
		music_finished_playing();
	}

}
);

$pns_move_callback= $app->add_move_handler( $play_next_song_callback);


$app->run();

SDL::Mixer::Effects::unregister( MIX_CHANNEL_POST, $music_data_effect_id );
SDL::Mixer::Music::hook_music_finished();
SDL::Mixer::Music::halt_music();
SDL::Mixer::close_audio();

