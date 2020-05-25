#ifndef GDEXAMPLE_H
#define GDEXAMPLE_H

#include <Godot.hpp>
#include <Position2D.hpp>
#include <opencv2/core/mat.hpp>
#include <opencv2/videoio.hpp>
#include <opencv2/objdetect.hpp>
#include <opencv2/tracking.hpp>
#include "VideoFaceDetector.h"
#include "VideoHandDetector.h"

namespace godot {

    class GDExample : public Sprite {
        GODOT_CLASS(GDExample, Sprite)

private:
    float time_passed;
    float time_emit;
    float amplitude;
    float speed;
    bool waitingForSample;
    cv::Mat image;
    cv::Mat frame;
    cv::VideoCapture camera;
    cv::CascadeClassifier face_cascase;
    cv::Point cursorPos;

    // Hand tracking
    cv::Ptr<cv::Tracker> tracker;
    cv::Rect2d bbox;
    cv::Mat handSample;

    VideoFaceDetector detector;
    VideoHandDetector handTracker;

public:
    static void _register_methods();

        GDExample();
        ~GDExample();

        void _init(); // our initializer called by Godot

        void _process(float delta);
    };

}

#endif
