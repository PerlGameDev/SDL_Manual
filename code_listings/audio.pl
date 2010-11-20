#!/usr/bin/perl -w
use strict;
use SDL;
use SDL::Audio;
use SDL::AudioSpec;

use threads;
use threads::shared;

SDL::init(SDL_INIT_AUDIO);


my $desired = SDL::AudioSpec->new;

$desired->freq(44100);
$desired->format(SDL::Audio::AUDIO_S16SYS);
$desired->channels(2);
$desired->samples(4096);
$desired->callback('main::audio_callback');


my $done :shared = 0;

sub audio_callback {
$done = 1;
warn 'Set Done:'.$done;
#SDL::Audio::pause(2);
}

my $obtained = SDL::AudioSpec->new;
unless( SDL::Audio::open( $desired, $obtained ) == 0 )
{
	die "Problem opening audio:".SDL::get_error();
}
my $wav_ref = SDL::Audio::load_wav( 'data/sample.wav', $obtained );

unless ( $wav_ref )
{

	die "Problem loading wav data:".SDL::get_error();

}
my ( $wav_spec, $audio_buf, $audio_len ) = @{$wav_ref};


SDL::Audio::pause(0);

while( $done != 1 && SDL::Audio::get_status() == SDL_AUDIO_PLAYING )
{
	warn $done;

	SDL::delay(100);

}
SDL::Audio::free_wav($audio_buf);
SDL::Audio::close();

