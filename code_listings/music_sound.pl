use strict;
use warnings;
use SDL;
use Carp;
use SDL::Audio;
use SDL::Mixer;
use SDL::Mixer::Samples;
use SDL::Mixer::Channels;
use SDL::Mixer::Music;
SDL::init(SDL_INIT_AUDIO);

unless( SDL::Mixer::open_audio( 44100, AUDIO_S16SYS, 2, 4096 ) == 0 )
{
	Carp::croak "Cannot open audio: ".SDL::get_error(); 
}


my $sample = SDL::Mixer::Samples::load_WAV('data/sample.wav');

unless( $sample)
{
	Carp::croak "Cannot load file data/sample.wav: ".SDL::get_error(); 
}

my $playing_channel = SDL::Mixer::Channels::play_channel( -1, $sample, 0 );

#Load our awesome music from U<http://8bitcollective.com>
my $background_music = SDL::Mixer::Music::load_MUS('data/music/01-PC-Speaker-Sorrow.ogg');

unless( $background_music )
{
	Carp::croak "Cannot load music file data/music/01-PC-Speaker-Sorrow.ogg: ".SDL::get_error() ;
}

SDL::Mixer::Music::play_music( $background_music,0 );

sleep(2);

SDL::Mixer::Music::halt_music();
SDL::Mixer::close_audio;
