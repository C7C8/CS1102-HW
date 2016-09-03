#include "Hydra-Engine/Hydra.h"
using namespace std; //ugh
using namespace Hydra;

#define WSIZE_X 800
#define WSIZE_Y 600

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
	plane.setY(WSIZE_Y / 2);

	Timer pauseTimer(5000); //ms?
	engine->queueTexture(plane);
	engine->renderAll();
	pauseTimer.start();
	while (!pauseTimer.hasIntervalPassed());
	
	
	engine->shutdown();
}

