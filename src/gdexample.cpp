#include "gdexample.h"
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <iostream>
#include <sstream>
#include <string>
#include "VideoFaceDetector.h"
#include <queue>

using namespace cv;
using namespace std;
using namespace godot;

const cv::String CASCADE_FILE("../src/opencv_data/haarcascades/haarcascade_frontalface_default.xml");
const bool debug_mode = true;

void GDExample::_register_methods() {
    register_method("_process", &GDExample::_process);

    // First is name of signal
    // After that you have pairs of values that specify parameter name and type of each parameter we send to signal
    register_signal<GDExample>((char*)"position_changed", "node", GODOT_VARIANT_TYPE_OBJECT, "new_pos", GODOT_VARIANT_TYPE_VECTOR2);
}

GDExample::GDExample() {
}

GDExample::~GDExample() {
    // add your cleanup here
}

void GDExample::_init() {
    // initialize any variables here
    cursorPos = Point(frame.cols / 4, frame.rows / 4);


    // camera.set(3, 512);
    // camera.set(4, 288);

    // // TODO 
    face_cascase.load("../src/opencv_data/haarcascades/haarcascade_frontalface_default.xml");
    if(!face_cascase.load("../src/opencv_data/haarcascades/haarcascade_frontalface_default.xml")) {
        cerr << "Error XML" << endl;
    }

    camera.open(0); //open camera
    camera.read(frame);

    // Set the handtracking Detector with the camera
    // detector = VideoFaceDetector::VideoFaceDetector();
    detector.setVideoCapture(camera);
    // Set the haarcascade classifier for the tracking method.
    detector.setFaceCascade(CASCADE_FILE);
}

void GDExample::_process(float delta) {
    detector >> frame;

    // Create the 'joystick' effect by restraining the movement of cursorPos. CursorPos 'follows' facePosition and is not mapped 1on1.
    cursorPos.x += (detector.facePosition().x - cursorPos.x) / 4;
    cursorPos.y += (detector.facePosition().y - cursorPos.y) / 4;

    // Set the position of the linked node (should be a Position2D node) with the tracked position
    set_position(Vector2(abs((float)cursorPos.x/(float)frame.cols-1), (float)cursorPos.y/(float)frame.rows));

    if (debug_mode)
    {
        // Display debug information of the tracking in the webcam frame
        if(detector.isFaceFound()) 
        {
            rectangle(frame, detector.face(), Scalar(255,0,0), 4,8,0);
            circle(frame, detector.facePosition(), 30, Scalar(0, 255, 0), 4,8,0);
        }
        
        // flip the frame to make the webcam look like a mirror.
        cv::Mat flipFrame;
        flip(frame, flipFrame, 1);
        imshow("", flipFrame); // Uncomment this line to show the webcam frames in a seperate window
    }
}
