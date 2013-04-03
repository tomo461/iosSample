#include "ofMain.h"
#include "testApp.h"

//=== OSX or iOS =====================================================================
#ifndef TARGET_ANDROID
int main()
{
	ofSetupOpenGL(1024,768, OF_FULLSCREEN);			// <-------- setup the GL context
    
	ofRunApp(new testApp);
}

//=== Android ========================================================================
#else
#include "ofAppAndroidWindow.h"
int main()
{
	ofAppAndroidWindow *window = new ofAppAndroidWindow;
	ofSetupOpenGL(window, 1024,768, OF_WINDOW);			// <-------- setup the GL context
    
	// this kicks off the running of my app
	// can be OF_WINDOW or OF_FULLSCREEN
	// pass in width and height too:
	ofRunApp( new testApp() );
	return 0;
}
#endif