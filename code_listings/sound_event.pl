use strict;
use warnings;
use SDL;
use Carp;
use SDLx::App;
use SDL::Audio;
use SDL::Mixer;
use SDL::Event;
use SDL::Events;
use SDL::Mixer::Music;
use SDL::Mixer::Samples;
use SDL::Mixer::Channels;


my $app = SDLx::App->new( init  => SDL_INIT_AUDIO|SDL_INIT_VIDEO, 
						  title => "Sound Event Demo", 
						  eoq   => 1 );


# Initialize the Audio
unless( SDL::Mixer::open_audio( 44100, AUDIO_S16SYS, 2, 4096 ) == 0 )
{
	Carp::croak "Cannot open audio: ".SDL::get_error(); 
}

# Load our sound resources
my $laser = SDL::Mixer::Samples::load_WAV('data/sample.wav');
unless( $laser)
{
	Carp::croak "Cannot load sound: ".SDL::get_error(); 
}

my $background_music = SDL::Mixer::Music::load_MUS('data/music/01-PC-Speaker-Sorrow.ogg');

unless( $background_music )
{
	Carp::croak "Cannot load music: ".SDL::get_error() ;
}

$app->add_event_handler(
sub{
my $event = shift;

	if($event->type == SDL_KEYDOWN)
	{
		my $keysym = $event->key_sym; 
		my $keyname = SDL::Events::get_key_name( $keysym );

		if( $keyname =~ 'space' )
		{
			#fire lasers!
			SDL::Mixer::Channels::play_channel( -1, $laser, 0 );
		
		}
	}


}

);

$app->run();
