#include "VideoHandDetector.h"
#include <iostream>
#include <opencv2/opencv.hpp>
#include <opencv2/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/objdetect.hpp>
#include <opencv2/tracking.hpp>
#include <GodotGlobal.hpp>
#include <queue>
#include <string>

using namespace std;

VideoHandDetector::VideoHandDetector() {
    string trackerTypes[8] = {"BOOSTING", "MIL", "KCF", "TLD","MEDIANFLOW", "GOTURN", "MOSSE", "CSRT"};
    string trackerType = trackerTypes[7];

    if (trackerType == "BOOSTING")
        tracker = cv::TrackerBoosting::create();
    if (trackerType == "MIL")
        tracker = cv::TrackerMIL::create();
    if (trackerType == "KCF")
        tracker = cv::TrackerKCF::create();
    if (trackerType == "TLD")
        tracker = cv::TrackerTLD::create();
    if (trackerType == "MEDIANFLOW")
        tracker = cv::TrackerMedianFlow::create();
    if (trackerType == "GOTURN")
        tracker = cv::TrackerGOTURN::create();
    if (trackerType == "MOSSE")
        tracker = cv::TrackerMOSSE::create();
    if (trackerType == "CSRT")
        tracker = cv::TrackerCSRT::create();

    trackingState = false;
}

void VideoHandDetector::startTracking(cv::Mat &frame, cv::Rect2d &bbox) {
    trackingState = true;
    tracker->init(frame, bbox);
}

cv::Rect2d VideoHandDetector::update(cv::Mat &frame, cv::Rect2d &bbox) {
    if(trackingState) {
        tracker->update(frame,bbox);
        cv::rectangle(frame, bbox, cv::Scalar(0,255,0), 4, 8, 0);
    } else {
        cv::rectangle(frame, bbox, cv::Scalar(0,0,255), 4, 8, 0);

        cv::flip(frame, frame, 1);
        cv::putText(frame,
            "Place your hand inside the red rectangle.",
            cv::Point(50, 50),
            cv::FONT_HERSHEY_TRIPLEX,
            0.75,
            CV_RGB(255, 255, 255),
            2
        );
        cv::flip(frame, frame, 1);
    }

    return bbox;
}

void VideoHandDetector::stopTracking() {
    trackingState = false;
}

void VideoHandDetector::toggleTracking(cv::Mat &frame, cv::Rect2d &bbox) {
    trackingState = !trackingState;
    if(trackingState) startTracking(frame,bbox);
    else stopTracking();
}

bool VideoHandDetector::isTracking() {
    return trackingState;
}

