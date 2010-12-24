use strict;
use warnings;
use SDL;
use Carp;
use SDL::Audio;
use SDL::Mixer;
use SDL::Mixer::Samples;
use SDL::Mixer::Channels;
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

my $playing_channel = SDL::Mixer::Channels::play_channel( -1, $sample, 1 );

sleep(2);
SDL::Mixer::close_audio;
