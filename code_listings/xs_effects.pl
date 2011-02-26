use strict;
use warnings;
use Inline with => 'SDL';
use SDL;
use SDLx::App;


my $app = SDLx::App->new( width => 640, height => 480, eoq => 1, title => "Grovvy XS Effects" );

$app->add_show_handler( \&render );

$app->run();

use Inline C => <<'END';

void render( float delta, SDL_Surface *screen )
{   
	// Lock surface if needed
	if (SDL_MUSTLOCK(screen)) 
		if (SDL_LockSurface(screen) < 0) 
			return;

	// Ask SDL for the time in milliseconds
	int tick = SDL_GetTicks();

	// Declare a couple of variables
	int i, j, yofs, ofs;

	// Draw to screen
	yofs = 0;
	for (i = 0; i < screen->h; i++)
	{
		for (j = 0, ofs = yofs; j < screen->w; j++, ofs++)
		{

			Uint32 value = i * i + j * j + tick;
			Uint8 a = value >> 2;
			Uint8 b = value >> 4;
			Uint8 g = value >> 8;
			Uint8 r = value >> 16;

			Uint32 map_val = SDL_MapRGBA( screen->format, r, g, b, a);
			((unsigned int*)screen->pixels)[ofs] = map_val;
		}
		yofs += screen->pitch / 4;
	}

	// Unlock if needed
	if (SDL_MUSTLOCK(screen)) 
		SDL_UnlockSurface(screen);

	// Tell SDL to update the whole screen
	SDL_UpdateRect(screen, 0, 0, screen->w,screen->h);    
}

END


