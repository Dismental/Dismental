#pragma once

#include <opencv2/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/objdetect/objdetect.hpp>
#include <opencv2/core/mat.hpp>
#include <opencv2/videoio.hpp>
#include <opencv2/objdetect.hpp>
#include <opencv2/tracking.hpp>
#include <queue>

class VideoHandDetector
{
public:
    // VideoHandDetector(const std::string cascadeFilePath, cv::VideoCapture &videoCapture);
    VideoHandDetector();
    // ~VideoHandDetector();

    void startTracking(cv::Mat &frame, cv::Rect2d &bbox);
    cv::Rect2d update(cv::Mat &frame, cv::Rect2d &bbox);
    void stopTracking();
    void toggleTracking(cv::Mat &frame, cv::Rect2d &bbox);
    bool isTracking();

private:
    bool trackingState;
    cv::Ptr<cv::Tracker> tracker;
    cv::Rect2d bbox;
};
