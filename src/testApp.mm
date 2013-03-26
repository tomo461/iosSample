#include "testApp.h"


//--------------------------------------------------------------
void testApp::setup()
{
    // initialize the accelerometer
	ofxAccelerometer.setup();
	
	//If you want a landscape oreintation
	//iPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_RIGHT);
    
	ofSetVerticalSync(true);
    ofEnableAlphaBlending();
    
	ofSetDrawBitmapMode(OF_BITMAPMODE_MODEL_BILLBOARD);
	
    // camera initialization
    cam.initGrabber(640, 480);
	
    // setting of faceTracker for camera
	camTracker.setup();
    
    // load source image
    srcImage.loadImage(DEFAULT_IMAGE_PATH);
    srcImage.setImageType(OF_IMAGE_COLOR_ALPHA);
    ofSetWindowShape(srcImage.width, srcImage.height);
    
    // setting of faceTracker for source image
    imgTracker.setup();
    imgTracker.update(toCv(srcImage));
    
    // get face position of source image
    position    = imgTracker.getPosition();
    scale       = imgTracker.getScale();
    orientation = imgTracker.getOrientation();
    
    // get face mesh from source image
    imgMesh = imgTracker.getImageMesh();
    
    // get mouth mesh from source image
    ofPolyline mouthLine;
    ofTessellator tessellator;
    mouthLine = imgTracker.getObjectFeature(ofxFaceTracker::INNER_MOUTH);
    mouthMesh.setMode(OF_PRIMITIVE_TRIANGLE_STRIP);
    tessellator.tessellateToMesh(mouthLine, OF_POLY_WINDING_ODD, mouthMesh);
    mouthMesh.addColor(ofFloatColor(0.2, 0, 0));
    
    camObjPoints.clear();
}

//--------------------------------------------------------------
void testApp::update()
{
	// update camera
    cam.update();
    
	if(cam.isFrameNew()) {
        camTracker.update(toCv(cam));
	}
    
    if(camTracker.getFound()){
        // initialize vertex vectors
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
                camObjPointsDiff[i] = (camTracker.getObjectPoint(i)/* / camTracker.getObjectPoint(i).length()*/ - camObjPoints[i]/* / camObjPoints[i].length()*/);
                camObjPointsDiff[i] = camObjPointsDiff[i]/* * imgTracker.getObjectPoint(i).length()*/ + imgTracker.getObjectPoint(i);
                imgMesh.setVertex(i, camObjPointsDiff[i]);
                // set vertex for mouth mesh
                int j = 0;
                switch (i) {    // vertex index conversion
                    case 48:
                        j = 2;
                        break;
                    case 60:
                        j = 0;
                        break;
                    case 61:
                        j = 4;
                        break;
                    case 62:
                        j = 6;
                        break;
                    case 54:
                        j = 7;
                        break;
                    case 63:
                        j = 5;
                        break;
                    case 64:
                        j = 3;
                        break;
                    case 65:
                        j = 1;
                        break;
                    default:
                        continue;
                        break;
                }
                mouthMesh.setVertex(j, camObjPointsDiff[i]);
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
    }
}

//--------------------------------------------------------------
void testApp::draw()
{
    // draw source image
    srcImage.draw(0, 0, srcImage.width, srcImage.height);
    
    // draw frame rate
	ofSetColor(255);
	ofDrawBitmapString(ofToString((int) ofGetFrameRate()), 10, 20);
    
    // disable display 3D pharse
    ofSetupScreenOrtho(ofGetWindowWidth(), ofGetWindowHeight(), OF_ORIENTATION_DEFAULT, true, -1000,1000);
    
    // draw mesh
    glEnable(GL_DEPTH_TEST);
    ofPushMatrix();
    ofTranslate(position.x, position.y);
    ofScale(scale, scale, scale);
    ofRotateX(orientation.x * 45.0f);
    ofRotateY(orientation.y * 45.0f);
    ofRotateZ(orientation.z * 45.0f);
    mouthMesh.drawFaces();
    srcImage.getTextureReference().bind();
    imgMesh.draw();
    srcImage.getTextureReference().unbind();
    ofPopMatrix();
    glDisable(GL_DEPTH_TEST);
    
    if(!camTracker.getFound()) {
		drawHighlightString("camera face not found", 10, 50);
	}
}

//--------------------------------------------------------------
void testApp::exit()
{

}

//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs & touch)
{

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

