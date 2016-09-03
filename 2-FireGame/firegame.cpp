#include "Hydra-Engine/Hydra.h"
using namespace std; //ugh
using namespace Hydra;

#define WSIZE_X 800
#define WSIZE_Y 600
#define FPS_TIME 1000 / 60
#define PLANE_SPEED 4

int main (int argc, char* argv[])
{
	HydraEngine* engine = HydraEngine::getInstance();
	TextureManager* tmanage = TextureManager::getInstance();
	engine->init();
	engine->setWSize(WSIZE_X, WSIZE_Y);
	engine->setWTitle("FireGame v1.0-cpp");

	//Load textures
	tmanage->loadTexture("plane.jpg", "plane");
	tmanage->loadTexture("lg-fire.gif", "lg-fire");
	tmanage->loadTexture("med-fire.gif", "med-fire");
	tmanage->loadTexture("sm-fire.gif", "sm-fire");
	Texture plane = tmanage->getTexture("plane");
	plane.setX(WSIZE_X / 2);
	plane.setY(100);
	
	bool quit = false;
	Timer fpsTimer(FPS_TIME);
	while (!quit)
	{	
		fpsTimer.reset();
		fpsTimer.start(); 

		//Event loop
		SDL_Event e;
		while (SDL_PollEvent(&e))
		{
			if (e.type == SDL_QUIT)
				quit = true;
			if (e.type == SDL_KEYDOWN)
			{
				switch (e.key.keysym.sym)
				{
					case SDLK_RIGHT:
						plane.setX(plane.getX() + PLANE_SPEED);
						break;
					case SDLK_LEFT:
						plane.setX(plane.getX() - PLANE_SPEED);
						break;
				}
			}
		}

		engine->queueTexture(plane);
		while (!fpsTimer.hasIntervalPassed()); //wait
		engine->renderAll();
	}
	

	
	
	engine->shutdown();
}

