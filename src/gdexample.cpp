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

    camera.open(0); //open camera
    camera.read(frame);

    // camera.set(3, 512);
    // camera.set(4, 288);

    // // TODO 
    face_cascase.load("../src/opencv_data/haarcascades/haarcascade_frontalface_default.xml");
    if(!face_cascase.load("../src/opencv_data/haarcascades/haarcascade_frontalface_default.xml")) {
        cerr << "Error XML" << endl;
    }

    // detector = VideoFaceDetector::VideoFaceDetector();
    detector.setVideoCapture(camera);
    detector.setFaceCascade(CASCADE_FILE);
}

void GDExample::_process(float delta) {
    detector >> frame;
    // flip(frame, frame, 1);
    
    if(detector.isFaceFound()) {
        rectangle(frame, detector.face(), Scalar(255,0,0), 4,8,0);
        circle(frame, detector.facePosition(), 30, Scalar(0, 255, 0), 4,8,0);
    }

    if(waitKey(10) == 27) return;

    cursorPos.x += (detector.facePosition().x - cursorPos.x) / 4;
    cursorPos.y += (detector.facePosition().y - cursorPos.y) / 4;

    set_position(Vector2(abs((float)cursorPos.x/(float)frame.cols-1), (float)cursorPos.y/(float)frame.rows));
    
    cv::Mat flipFrame;
    flip(frame, flipFrame, 1);
    // imshow("", flipFrame);
}
