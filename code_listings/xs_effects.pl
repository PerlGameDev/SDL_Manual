use Alien::SDL;
use SDL;
use SDLx::App;
use Inline;
my $libs = Alien::SDL->config('libs');
my $cflags = Alien::SDL->config('cflags');
my $typemap = '/home/kthakore/Documents/Development/SDLPerl/SDL/typemap';
my $code = 
'#include <SDL.h>

void render( SDL_Surface *screen )
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
  for (i = 0; i < 480; i++)
  {
    for (j = 0, ofs = yofs; j < 640; j++, ofs++)
    {
      ((unsigned int*)screen->pixels)[ofs] = i * i + j * j + tick;
    }
    yofs += screen->pitch / 4;
  }

  // Unlock if needed
  if (SDL_MUSTLOCK(screen)) 
    SDL_UnlockSurface(screen);

  // Tell SDL to update the whole screen
  SDL_UpdateRect(screen, 0, 0, 640, 480);    
}


';

Inline->bind( C => $code => LIBS => $libs => CCFLAGS => $cflags => TYPEMAPS => $typemap  );

my $app = SDLx::App->new( width => 640, height => 480, eoq => 1 );

$app->add_show_handler( sub{ render( $app ) } );

$app->run();

