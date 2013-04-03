/*
 * common.h
 *
 * Compile Options for Target Platform.
 *
 */
#ifndef COMMON_H
#define COMMON_H

//=== OSX =====================================================================
#ifdef TARGET_OSX
#define OF_APP_TYPE ofBaseApp
#endif

//=== iOS =====================================================================
#ifdef TARGET_OF_IPHONE
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"
#define OF_APP_TYPE ofxiPhoneApp
#endif

//=== Android =================================================================
#ifdef TARGET_ANDROID
#include "ofxAndroid.h"
#include <jni.h>
extern "C"{
	void Java_cc_openframeworks_OFAndroid_init( JNIEnv*  env, jobject  thiz ){
		main();
	}
}
#define OF_APP_TYPE ofxAndroidApp
#endif

#endif