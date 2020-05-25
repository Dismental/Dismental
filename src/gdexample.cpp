#include "gdexample.h"

#include <opencv2/opencv.hpp>
#include <opencv2/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/objdetect.hpp>
#include <opencv2/tracking.hpp>

#include <iostream>
#include <sstream>
#include <string>
#include "VideoFaceDetector.h"
#include "VideoHandDetector.h"
#include <queue>
#include <math.h>

using namespace godot;
using namespace cv;
using namespace std;

const cv::String CASCADE_FILE("../src/opencv_data/haarcascades/haarcascade_frontalface_default.xml");

void GDExample::_register_methods() {
    register_method("_process", &GDExample::_process);
    register_property<GDExample, float>("amplitude", &GDExample::amplitude, 10.0);
    register_property<GDExample, float>("speed", &GDExample::set_speed, &GDExample::get_speed, 1.0);

    register_signal<GDExample>((char *)"position_changed", "node", GODOT_VARIANT_TYPE_OBJECT, "new_pos", GODOT_VARIANT_TYPE_VECTOR2);
}

GDExample::GDExample() {
}

GDExample::~GDExample() {
    // add your cleanup here
}

void GDExample::_init() {
    // initialize any variables here
    time_passed = 0.0;
    amplitude = 10.0;
    speed = 1.0;

    camera.open(0); //open camera
    camera.read(frame);
    cursorPos = Point(frame.cols / 4, frame.rows / 4);

    // camera.set(3, 512);
    // camera.set(4, 288);

    waitingForSample = true;

    bbox = Rect2d(100,200,200,300);

    // // TODO 
    face_cascase.load("../src/opencv_data/haarcascades/haarcascade_frontalface_default.xml");
    if(!face_cascase.load("../src/opencv_data/haarcascades/haarcascade_frontalface_default.xml")) {
        cerr << "Error XML" << endl;
    }

    // detector = VideoFaceDetector::VideoFaceDetector();
    detector.setVideoCapture(camera);
    detector.setFaceCascade(CASCADE_FILE);
}

int dist(Point p1, Point p2) {
    return sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2));
}

void GDExample::_process(float delta) {
    camera >> frame;

    handTracker.update(frame, bbox);

    if(waitKey(10) == 32) {
        // tracker->init(frame,bbox);
        handTracker.toggleTracking(frame, bbox);
    }
    
    flip(frame, frame, 1);
    imshow("", frame);
    set_position(Vector2(cursorPos.x, cursorPos.y));
}

void GDExample::set_speed(float p_speed) {
    speed = p_speed;
}

float GDExample::get_speed() {
    return speed;
}
