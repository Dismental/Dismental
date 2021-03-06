#ifndef GDEXAMPLE_H
#define GDEXAMPLE_H

#include <Godot.hpp>
#include <Position2D.hpp>
#include <opencv2/core/mat.hpp>
#include <opencv2/videoio.hpp>
#include <opencv2/objdetect.hpp>
#include <opencv2/tracking.hpp>
#include "VideoFaceDetector.h"

namespace godot {

    class GDExample : public Position2D {
        GODOT_CLASS(GDExample, Position2D)

private:
    bool waitingForSample;
    cv::Mat image;
    cv::Mat frame;
    cv::VideoCapture camera;
    cv::CascadeClassifier face_cascase;
    Vector2 cursorPos;
    VideoFaceDetector detector;

    bool multiple_faces;
    bool too_close;
    bool template_matching;
    bool lost_tracking;
    bool camera_access;
    float retry_timer = 0.0;

public:
    static void _register_methods();

        GDExample();
        ~GDExample();

        void _init(); // our initializer called by Godot

        void _process(float delta);
    };
}

#endif
