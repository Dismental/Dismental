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

void GDExample::_register_methods() {
    register_method("_process", &GDExample::_process);
    register_property<GDExample, float>("amplitude", &GDExample::amplitude, 10.0);

    // First is name of signal
    // After that you have pairs of values that specify parameter name and type of each parameter we send to signal
    register_signal<GDExample>((char*)"position_changed", "node", GODOT_VARIANT_TYPE_OBJECT, "new_pos", GODOT_VARIANT_TYPE_VECTOR2);
}

GDExample::GDExample() {
}

GDExample::~GDExample() {
    // add your cleanup here
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
    // initialize any variables here
    time_passed = 0.0;
    time_emit = 0.0;
    amplitude = 10.0;

    camera.open(0); //open camera
    camera.read(frame);
    cursorPos = Point(frame.cols / 4, frame.rows / 4);

    // camera.set(3, 512);
    // TODO get .xml from res:// instead of a hardcoded path
    std::string path = "../src/opencv_data/haarcascades/haarcascade_frontalface_default.xml";
    if(!face_cascase.load(path)) {
        path = get_env_var("HOME") + "/Applications/DefuseTheBomb.app/Contents/Resources/haarcascade_frontalface_default.xml";
        std::cout << path << std::endl;
        cerr << "Error XML" << endl;
    }

    // detector = VideoFaceDetector::VideoFaceDetector();
    detector.setVideoCapture(camera);
    detector.setFaceCascade(path);
}

void GDExample::_process(float delta) {
    detector >> frame;
    // flip(frame, frame, 1);
    int frameWidth, frameHeigth;
    frameWidth = frame.cols;
    frameHeigth = frame.rows;
    
    if(detector.isFaceFound()) {
        rectangle(frame, detector.face(), Scalar(255,0,0), 4,8,0);
        circle(frame, detector.facePosition(), 30, Scalar(0, 255, 0), 4,8,0);
    }

    if(waitKey(10) == 27) return;

    // Get the queue of face template display them all in sequence in the frame (picture in picture style)
    std::queue<cv::Mat> frame_lastSeen_queue = detector.getLastSeenFaceTemplateQueue();
    int spacingx = 0;
    while (!frame_lastSeen_queue.empty())
    {
        cv:Mat q_element = frame_lastSeen_queue.front();
        q_element.copyTo(frame(cv::Rect(spacingx,0,q_element.cols, q_element.rows)));
        spacingx += q_element.cols;
        frame_lastSeen_queue.pop();
    }
    cv::Mat flipFrame;
    flip(frame, flipFrame, 1);
    // imshow("", flipFrame);

    cursorPos.x += (detector.facePosition().x - cursorPos.x) / 4;
    cursorPos.y += (detector.facePosition().y - cursorPos.y) / 4;

    set_position(Vector2(abs((float)cursorPos.x/(float)frameWidth-1), (float)cursorPos.y/(float)frameHeigth));
}
