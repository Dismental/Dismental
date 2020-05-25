#include "gdexample.h"
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <iostream>

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

void GDExample::_init() {
    // initialize any variables here
    time_passed = 0.0;
    time_emit = 0.0;
    amplitude = 10.0;

    Mat image = Mat::zeros(300, 600, CV_8UC3);
    circle(image, Point(250, 150), 100, Scalar(0, 255, 128), -100);
    // circle(image, Point(350, 150), 100, Scalar(255, 255, 255), -100);
    // imshow("Display Window", image);
}

void GDExample::_process(float delta) {
    time_passed += delta;

    Vector2 new_position = Vector2(
        amplitude + (amplitude * sin(time_passed * 2.0)),
        amplitude + (amplitude * cos(time_passed * 1.5))
    );

    set_position(new_position);

    time_emit += delta;
    // If a second has passed
    if (time_emit > 1.0) {
        emit_signal("position_changed", this, new_position);
        time_emit = 0.0;
    }
}
