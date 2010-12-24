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

my $app = SDLx::App->new(
    init  => SDL_INIT_AUDIO | SDL_INIT_VIDEO,
	width => 250,
	height => 75,
    title => "Sound Event Demo",
    eoq   => 1
);

# Initialize the Audio
unless ( SDL::Mixer::open_audio( 44100, AUDIO_S16SYS, 2, 4096 ) == 0 ) {
    Carp::croak "Cannot open audio: " . SDL::get_error();
}

my $channel_volume = 100;
my $music_volume   = 100;
my $laser_status   = 'none';
my $music_status   = 'not playing';

# Load our sound resources
my $laser = SDL::Mixer::Samples::load_WAV('data/sample.wav');
unless ($laser) {
    Carp::croak "Cannot load sound: " . SDL::get_error();
}

my $background_music =
  SDL::Mixer::Music::load_MUS('data/music/01-PC-Speaker-Sorrow.ogg');
unless ($background_music) {
    Carp::croak "Cannot load music: " . SDL::get_error();
}


$app->add_show_handler(
sub { 

	$app->draw_rect([0,0,$app->w,$app->h], 0 );

	$app->draw_gfx_text( [10,10], [255,0,0,255], "Channel Volume : $channel_volume" );
	$app->draw_gfx_text( [10,25], [255,0,0,255], "Music Volume   : $music_volume" );
	$app->draw_gfx_text( [10,40], [255,0,0,255], "Laser Status   : $laser_status" );
	$app->draw_gfx_text( [10,55], [255,0,0,255], "Music Status   : $music_status" );

	$app->update();

}
);

$app->add_event_handler(
    sub {
        my $event = shift;

        if ( $event->type == SDL_KEYDOWN ) {
            my $keysym  = $event->key_sym;
            my $keyname = SDL::Events::get_key_name($keysym);

            if ( $keyname eq 'space' ) {

				$laser_status = 'PEW!';
                #fire lasers!
                SDL::Mixer::Channels::play_channel( -1, $laser, 0 );

            }
            elsif ( $keyname eq 'up' ) {
                $channel_volume += 5 unless $channel_volume == 100;
            }
            elsif ( $keyname eq 'down' ) {
                $channel_volume -= 5 unless $channel_volume == 0;
            }
            elsif ( $keyname eq 'right' ) {
                $music_volume += 5 unless $music_volume == 100;
            }
            elsif ( $keyname eq 'left' ) {
                $music_volume -= 5 unless $music_volume == 0;
            }
            elsif ( $keyname eq 'return' ) {
                my $playing = SDL::Mixer::Music::playing_music();
                my $paused  = SDL::Mixer::Music::paused_music();

                if ( $playing == 0 && $paused == 0 ) {
                    SDL::Mixer::Music::play_music( $background_music, 1 );
					$music_status = 'playing';
                }
                elsif ( $playing && !$paused ) {
                    SDL::Mixer::Music::pause_music();
					$music_status = 'paused'
                }
                elsif ( $playing && $paused ) {
                    SDL::Mixer::Music::resume_music();
					$music_status = 'resumed playing';
                }

            }

            SDL::Mixer::Channels::volume( -1, $channel_volume );
            SDL::Mixer::Music::volume_music($music_volume);

        }

      }

);

$app->run();

SDL::Mixer::Music::halt_music();
SDL::Mixer::close_audio;

