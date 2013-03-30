#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"

#include "ofxOpenCv.h"
#include "ofxCv.h"
#include "ofxFaceTracker.h"
#include "ofxFaceTrackerThreaded.h"

#define EYE_OPENNESS_OFFSET 0.4
#define DEFAULT_IMAGE_PATH  "image/jobs.png"

// macro for simulator
#if 0
#define IPHONE_SIM
#define ofVideoGrabber      ofImage
#define initGrabber(x, y)   loadImage("image/rola.jpg")
#define isFrameNew          isAllocated
#endif

using namespace ofxCv;
using namespace cv;

class testApp : public ofxiPhoneApp
{	
public:
    void setup();
    void update();
    void draw();
    void exit();
	
    void touchDown(ofTouchEventArgs & touch);
    void touchMoved(ofTouchEventArgs & touch);
    void touchUp(ofTouchEventArgs & touch);
    void touchDoubleTap(ofTouchEventArgs & touch);
    void touchCancelled(ofTouchEventArgs & touch);
    
    void lostFocus();
    void gotFocus();
    void gotMemoryWarning();
    void deviceOrientationChanged(int newOrientation);
    
    ofMesh getMouthMeshFromFaceTracker(const ofxFaceTracker *faceTrackerPtr);
    ofIndexType convertVertexIndexForMouthMesh(ofIndexType faceTrackerVertexIndex);

    void changeSrcImageTracker();
	
    ofVideoGrabber  cam;
    int                  camID; //0:back, 1:front
	ofxFaceTrackerThreaded  camTracker;
    ofxFaceTracker  imgTracker;
    ofImage         srcImage;
    ofMesh          imgMesh;
    ofMesh          mouthMesh;
    ofVec2f         position;
    float           scale;
    ofVec3f         orientation;
    float           leftEyeOpennessTh;
    float           rightEyeOpennessTh;
    vector<ofVec3f> camObjPoints, camObjPointsDiff;
    vector<ofVec2f> camImgPoints, camImgPointsDiff;
    
    ofxiPhoneImagePicker imgPicker;
    
    bool            wipeFlag;
};


