#include "gdexample.h"
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/objdetect.hpp>
#include <opencv2/tracking.hpp>

#include <iostream>
#include <sstream>
#include <string>
#include "VideoFaceDetector.h"
#include <queue>
#include <math.h>

using namespace cv;
using namespace std;
using namespace godot;

const bool debug_mode = false;

void GDExample::_register_methods() {
    register_method("_process", &GDExample::_process);

	register_property<GDExample, bool>("multiface", &GDExample::multiple_faces, false);
	register_property<GDExample, bool>("tooclose", &GDExample::too_close, false);
    register_property<GDExample, bool>("templatematching", &GDExample::template_matching, false);
    register_property<GDExample, bool>("losttracking", &GDExample::lost_tracking, false);
}

GDExample::GDExample() {
}

GDExample::~GDExample() {
}

string get_env_var( std::string const & key ) {                                 
    char * val;
    val = getenv( key.c_str() );
    std::string retval = "";
    if (val != NULL) {
        retval = val;
    }
    return retval;
}

void GDExample::_init() {

    // TODO get .xml from res:// instead of a hardcoded path
    std::string path = "../src/opencv_data/haarcascades/haarcascade_frontalface_default.xml";
    if(!face_cascase.load(path)) {
        // Load XML file in from the game being installed at the root applications
        path = "/Applications/Dismental.app/Contents/Resources/haarcascade_frontalface_default.xml";
        if (!face_cascase.load(path)) {
            // If not found there, load from ~/Applications
            path = get_env_var("HOME") + "/Applications/Dismental.app/Contents/Resources/haarcascade_frontalface_default.xml";
            // If still not found, cout error
            if (!face_cascase.load(path)) {
                cerr << "Error XML!!" << endl;
            }
        }
    }

    camera.open(0); //open camera

    // Set the handtracking Detector with the camera
    detector.setVideoCapture(camera);
    // Set the haarcascade classifier for the tracking method.
    detector.setFaceCascade(path);
}

void GDExample::_process(float delta) {
    if (camera.isOpened()) {
        detector >> frame;

        // Set the position of the linked node (should be a Position2D node) with the tracked position
        cursorPos = Vector2(abs((float)detector.facePosition().x/(float)frame.cols-1), (float)detector.facePosition().y/(float)frame.rows);
        set_position(cursorPos);

        if (debug_mode)
        {
            // Display debug information of the tracking in the webcam frame
            if(detector.isFaceFound()) 
            {
                rectangle(frame, detector.face(), Scalar(255,0,0), 4,8,0);
                circle(frame, detector.facePosition(), 30, Scalar(0, 255, 0), 4,8,0);
            }
            
            // Flip the frame to make the webcam look like a mirror.
            cv::Mat flipFrame;
            flip(frame, flipFrame, 1);
            imshow("", flipFrame); // Uncomment this line to show the webcam frames in a seperate window
        }

        multiple_faces = detector.multiple_faces;
        too_close = detector.too_close;
        lost_tracking = detector.lost_tracking;
        template_matching = detector.template_matching;
    } else {
        retry_timer += delta;
        if (retry_timer > 2) {
            retry_timer = 0;
            camera.open(0);
        }
    }
}
