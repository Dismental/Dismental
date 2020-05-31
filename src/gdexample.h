#ifndef GDEXAMPLE_H
#define GDEXAMPLE_H

#include <Godot.hpp>
#include <Position2D.hpp>
#include <opencv2/core/mat.hpp>
#include <opencv2/videoio.hpp>
#include <opencv2/objdetect.hpp>
#include "VideoFaceDetector.h"

namespace godot {

    class GDExample : public Position2D {
        GODOT_CLASS(GDExample, Position2D)

private:
    float time_passed;
    float time_emit;
    float amplitude;
    float speed;
    cv::Mat image;
    cv::Mat frame;
    cv::VideoCapture camera;
    cv::CascadeClassifier face_cascase;
    cv::Point cursorPos;

    VideoFaceDetector detector;

public:
    static void _register_methods();

        GDExample();
        ~GDExample();

        void _init(); // our initializer called by Godot

        void _process(float delta);
    };

}

#endif
