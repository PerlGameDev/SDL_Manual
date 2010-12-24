use strict;
use warnings;
use SDL;
use Carp;
use SDL::Audio;
use SDL::Mixer;

SDL::init(SDL_INIT_AUDIO);

unless( SDL::Mixer::open_audio( 44100, AUDIO_S16SYS, 2, 4096 ) == 0 )
{
	Carp::croak "Cannot open audio: ".SDL::get_error(); 
}

SDL::Mixer::close_audio;
