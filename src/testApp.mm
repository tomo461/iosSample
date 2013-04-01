#include "testApp.h"


//--------------------------------------------------------------
void testApp::setup()
{
    /* settings for iOs */
	//ofxAccelerometer.setup();    // initialize the accelerometer
	//iPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_RIGHT);  // If you want a landscape oreintation

    
	ofSetVerticalSync(true);
    ofEnableAlphaBlending();
	ofSetDrawBitmapMode(OF_BITMAPMODE_MODEL_BILLBOARD);
    ofBackground(0, 0, 0);

    
    // camera initialization
    camID    = 0;
    cam.setDeviceID(camID);
    cam.initGrabber(ofGetWidth(), ofGetHeight());
    wipeFlag = false;
    

	
    // setting of faceTracker for camera
	camTracker.setup();
    
    // load source image
    srcImage.loadImage(DEFAULT_IMAGE_PATH);
    srcImage.setImageType(OF_IMAGE_COLOR_ALPHA);

    float resizeRate = max(srcImage.width / (float) ofGetWidth(), srcImage.height / (float)ofGetHeight());
    srcImage.resize(srcImage.width / resizeRate, srcImage.height / resizeRate);
    
    // setting of faceTracker for source image
    imgTracker.setup();
    imgTracker.update(toCv(srcImage));
    
    // get face position of source image
    position    = imgTracker.getPosition();
    scale       = imgTracker.getScale();
    orientation = imgTracker.getOrientation();
    
    
    // get face mesh from source image
    imgMesh = imgTracker.getImageMesh();
    imgMesh.clearTexCoords();
    ofVec2f normalizeFact = ofVec2f(ofNextPow2(srcImage.getWidth()), ofNextPow2(srcImage.getHeight()));
    for(int i = 0; i < imgMesh.getNumVertices(); i++) {
        imgMesh.addTexCoord(imgTracker.getImagePoint(i) / normalizeFact);   // should be implemented by overriding getMesh()?
    }
    
    // get mouth mesh from source image
    mouthMesh.setMode(OF_PRIMITIVE_TRIANGLE_STRIP);
    mouthMesh = getMouthMeshFromFaceTracker(&imgTracker);
    
    camObjPoints.clear();
    
    // load icon image;
    cameraSwitchIcon.loadImage("image/icon00.png");
    pictureLibraryIcon.loadImage("image/icon01.png");
    showCameraImageIcon.loadImage("image/icon02.png");
}

//--------------------------------------------------------------
void testApp::update()
{
    cam.update();
    
    if(cam.isFrameNew()) {
        camTracker.update(toCv(cam));
    }
    
    if(imgPicker.imageUpdated){
        imgPicker.imageUpdated = false;
        srcImage.setFromPixels(imgPicker.pixels, imgPicker.width, imgPicker.height, OF_IMAGE_COLOR_ALPHA);
        //srcImage.resize(ofGetWidth(), ofGetHeight());
        float resizeRate = max(srcImage.width / (float) ofGetWidth(), srcImage.height / (float)ofGetHeight());
        srcImage.resize(srcImage.width / resizeRate, srcImage.height / resizeRate);

        imgPicker.close();
        
        changeSrcImageTracker();
    }

    
    if(camTracker.getFound()){
        // initialize vertex vectors and eye openness
        if (camObjPoints.empty()) {
            camObjPoints = camTracker.getObjectPoints();
            camObjPointsDiff = camTracker.getObjectPoints();
            leftEyeOpennessTh = camTracker.getGesture(ofxFaceTracker::LEFT_EYE_OPENNESS) - EYE_OPENNESS_OFFSET;
            rightEyeOpennessTh = camTracker.getGesture(ofxFaceTracker::RIGHT_EYE_OPENNESS) - EYE_OPENNESS_OFFSET;
        }
        // copy vertex motion of camTracker to imgMesh
        for (int i = 0; i < imgMesh.getNumVertices(); i++) {
            // ignore face outline
            if (i < 18) {
                imgMesh.setVertex(i, imgTracker.getObjectPoint(i));
            } else {
#ifdef IPHONE_SIM
                if (i >= 63 && i <= 65) {
                    camObjPointsDiff[i] = (camTracker.getObjectPoint(i) + ofVec3f(0, 1.1) * ofGetElapsedTimef()/2 - camObjPoints[i]);
                } else {
                    camObjPointsDiff[i] = (camTracker.getObjectPoint(i) - camObjPoints[i]);
                }
#else
                camObjPointsDiff[i] = (camTracker.getObjectPoint(i) - camObjPoints[i]);
#endif
                camObjPointsDiff[i] = camObjPointsDiff[i] + imgTracker.getObjectPoint(i);
                imgMesh.setVertex(i, camObjPointsDiff[i]);
                // set vertex for mouth mesh
                mouthMesh.setVertex(convertVertexIndexForMouthMesh(i), camObjPointsDiff[i]);
            }
        }
        // add color to mouth mesh
        mouthMesh.addColor(ofFloatColor(0.2, 0, 0));
        // check eye openness
        if (camTracker.getGesture(ofxFaceTracker::LEFT_EYE_OPENNESS) < leftEyeOpennessTh) {
            imgMesh.setVertex(37, camObjPoints[41]);
            imgMesh.setVertex(38, camObjPoints[40]);
        }
        if (camTracker.getGesture(ofxFaceTracker::RIGHT_EYE_OPENNESS) < rightEyeOpennessTh) {
            imgMesh.setVertex(43, camObjPoints[47]);
            imgMesh.setVertex(44, camObjPoints[46]);
        }
    } else {
        camObjPoints.clear();
        for(int i=0;i<imgMesh.getNumVertices();i++){
            imgMesh.setVertex(i, imgTracker.getObjectPoint(i));
        }
    }
}

//--------------------------------------------------------------
void testApp::draw()
{
    if(imgTracker.getFound()){
        // draw source image
        //srcImage.draw(ofGetWidth()/2 - srcImage.width/2, ofGetHeight()/2 - srcImage.height/2, srcImage.width, srcImage.height);
    
        srcImage.draw((ofGetWidth()/2 - srcImage.width/2), (ofGetHeight()/2 - srcImage.height/2));
    }
    else{
        ofDrawBitmapString("image face not found", 10, ofGetHeight()/2);
    }
    
    // draw frame rate
	ofSetColor(255);
	ofDrawBitmapString(ofToString((int) ofGetFrameRate()), 10, 20);
    
    // disable display 3D pharse
    ofSetupScreenOrtho(ofGetWindowWidth(), ofGetWindowHeight(), OF_ORIENTATION_DEFAULT, true, -1000,1000);
    
    
    // draw mesh
    glEnable(GL_DEPTH_TEST);
    ofPushMatrix();
    ofTranslate((ofGetWidth()/2 - srcImage.width/2) + position.x, (ofGetHeight()/2 - srcImage.height/2) + position.y);
    ofScale(scale, scale, scale);
    ofRotateX(orientation.x * 45.0f);
    ofRotateY(orientation.y * 45.0f);
    ofRotateZ(orientation.z * 45.0f);
    mouthMesh.drawFaces();
    srcImage.bind();
    imgMesh.draw();
    srcImage.unbind();
    ofPopMatrix();
    glDisable(GL_DEPTH_TEST);

    if(wipeFlag)
        cam.draw(ofGetWidth()*3/4, 0, ofGetWidth()/4, ofGetHeight()/4);
    
    if(!imgTracker.getFound()){
        drawHighlightString("image face not fount", 10, ofGetHeight()/2);
    }
    
    
    // draw icon image
    cameraSwitchIcon.draw(ofGetWidth()/5 - pictureLibraryIcon.width/2, ofGetHeight()/5*4);
    pictureLibraryIcon.draw(ofGetWidth()/2 - pictureLibraryIcon.width/2, ofGetHeight()/5*4);
    showCameraImageIcon.draw(ofGetWidth()/5*4 - showCameraImageIcon.width/2, ofGetHeight()/5*4);
}

/**
 * @function    getMouthMeshFromFaceTracker
 * @abstract    gets a mouth mesh from ofxFaceTracker.
 * @param       FaceTracker pointer
 * @return      extracted mouth mesh
 */
ofMesh testApp::getMouthMeshFromFaceTracker(const ofxFaceTracker *faceTrackerPtr)
{
    ofPolyline mouthLine;
    ofTessellator tessellator;
    ofMesh mouthMesh;
    
    mouthLine = faceTrackerPtr->getObjectFeature(ofxFaceTracker::INNER_MOUTH);
    mouthMesh.setMode(OF_PRIMITIVE_TRIANGLE_STRIP);
    tessellator.tessellateToMesh(mouthLine, OF_POLY_WINDING_ODD, mouthMesh);
    mouthMesh.addColor(ofFloatColor(0.2, 0, 0));
    
    return mouthMesh;
}

/**
 * @function    convertVertexIndexForMouthMesh
 * @abstract    converts vertex index of ofxFaceTracker for a mouth mesh.
 * @param       vertex index of FaceTracker
 * @return      converted vertex index
 */
ofIndexType testApp::convertVertexIndexForMouthMesh(ofIndexType faceTrackerVertexIndex)
{
    int index = 0;
    
    switch (faceTrackerVertexIndex) {
        case 48:
            index = 2;
            break;
        case 60:
            index = 0;
            break;
        case 61:
            index = 4;
            break;
        case 62:
            index = 6;
            break;
        case 54:
            index = 7;
            break;
        case 63:
            index = 5;
            break;
        case 64:
            index = 3;
            break;
        case 65:
            index = 1;
            break;
        default:
            break;
    }
    
    return index;
}

/**
 * @function    changeSrcImageTracker
 * @abstract    change sourch image.
 * @param       none
 * @return      none
 */

void testApp::changeSrcImageTracker(){

    imgTracker.reset();
    imgTracker.setup();
    
    imgTracker.update(toCv(srcImage));
    
    // get face position of source image
    position    = imgTracker.getPosition();
    scale       = imgTracker.getScale();
    orientation = imgTracker.getOrientation();
    
    // get face mesh from source image
    imgMesh.clear();
    
    imgMesh = imgTracker.getImageMesh();
    imgMesh.clearTexCoords();
    ofVec2f normalizeFact = ofVec2f(ofNextPow2(srcImage.getWidth()), ofNextPow2(srcImage.getHeight()));
    for(int i = 0; i < imgMesh.getNumVertices(); i++) {
        imgMesh.addTexCoord(imgTracker.getImagePoint(i) / normalizeFact);   // should be implemented by overriding getMesh()?
    }
    
    // get mouth mesh from source image
    mouthMesh.clear();
    
    mouthMesh.setMode(OF_PRIMITIVE_TRIANGLE_STRIP);
    mouthMesh = getMouthMeshFromFaceTracker(&imgTracker);
    
    camObjPoints.clear();
}


//--------------------------------------------------------------
void testApp::exit()
{

}

//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs & touch)
{
    if(touch.y > ofGetHeight()/5 *4){
    
    //switch camera
    if(touch.x < ofGetWidth()/3){
        cam.close();
        if(camID == 0){
            camID = 1;
        }
        else{
            camID = 0;
        }
        cam.setDeviceID(camID);
        cam.initGrabber(ofGetWidth(), ofGetHeight());
    }
    
    //open photo library
    else if(touch.x > ofGetWidth()/3 && touch.x < ofGetWidth()/3 *2){
        imgPicker.openLibrary();
        
    }
    
    //display camera image
    else if(touch.x > ofGetWidth()/3*2 && touch.x < ofGetWidth()){
        wipeFlag = (wipeFlag)? false: true;
    }
        
    }
    

}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs & touch)
{

}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs & touch)
{

}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs & touch)
{

}

//--------------------------------------------------------------
void testApp::touchCancelled(ofTouchEventArgs & touch)
{
    
}

//--------------------------------------------------------------
void testApp::lostFocus()
{

}

//--------------------------------------------------------------
void testApp::gotFocus(){

}

//--------------------------------------------------------------
void testApp::gotMemoryWarning()
{

}

//--------------------------------------------------------------
void testApp::deviceOrientationChanged(int newOrientation)
{

}

