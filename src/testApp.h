#pragma once

#include "ofMain.h"
#include "common.h"

//--- addons -----------------------------------------------------------
#include "ofxOpenCv.h"
#include "ofxCv.h"
#include "ofxFaceTracker.h"
#include "ofxFaceTrackerThreaded.h"

//--- compile option for iPhone simulator ------------------------------
//#ifdef TARGET_IPHONE_SIMULATOR
//#define DEBUG_IPHONE_SIMULATOR
//#define ofVideoGrabber      ofImage
//#define initGrabber(x, y)   loadImage("image/1.jpg")
//#define isFrameNew          isAllocated
//#endif

//--- macro definitions ------------------------------------------------
#define EYE_OPENNESS_OFFSET 0.3
#define DEFAULT_IMAGE_PATH  "image/1.jpg"
#define NUM_IMAGE           5

//--- namespace --------------------------------------------------------
using namespace ofxCv;
using namespace cv;

//--- class ------------------------------------------------------------
class testApp : public OF_APP_TYPE
{	
public:
    void setup();
    void update();
    void draw();
    void exit();
	
    /*** callbacks ***/
#if defined(TARGET_OF_IPHONE) || defined(TARGET_ANDROID)
    void touchDown(ofTouchEventArgs & touch);
    void touchMoved(ofTouchEventArgs & touch);
    void touchUp(ofTouchEventArgs & touch);
    void touchDoubleTap(ofTouchEventArgs & touch);
    void touchCancelled(ofTouchEventArgs & touch);
    void lostFocus();
    void gotFocus();
    void gotMemoryWarning();
    void deviceOrientationChanged(int newOrientation);
#else
    void keyPressed( int key );
    void keyReleased( int key );
    void mouseMoved( int x, int y );
    void mouseDragged( int x, int y, int button );
    void mousePressed( int x, int y, int button );
    void mouseReleased();
    void mouseReleased(int x, int y, int button );
    void windowResized(int w, int h);
    void dragEvent(ofDragInfo dragInfo);
#endif
    
    /*** functions ***/
    void getMouthMeshFromSrcImageTracker(void);
    void changeSrcImageTracker(void);
    ofIndexType convertVertexIndexForMouthMesh(ofIndexType faceTrackerVertexIndex);

    /*** types ***/
    enum CamID_t {
        CAMERA_BACK,
        CAMERA_FRONT,
    };
	
    /*** variables ***/
    ofVideoGrabber  cam;
    CamID_t         camID;
    bool            wipeFlag;
	ofxFaceTrackerThreaded  camTracker;
    ofxFaceTracker  imgTracker;
    ofImage         srcImage;
    ofImage         pictureLibraryIcon, showCameraImageIcon, cameraSwitchIcon;
    int             numImage;
    ofMesh          imgMesh;
    ofMesh          mouthMesh;
    ofVec2f         position;
    float           scale;
    ofVec3f         orientation;
    float           leftEyeOpennessTh;
    float           rightEyeOpennessTh;
    vector<ofVec3f> camObjPoints, camObjPointsDiff;

#ifdef TARGET_OF_IPHONE
    ofxiPhoneImagePicker imgPicker;
#endif

};


