#pragma once

#include <opencv2/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/objdetect/objdetect.hpp>
#include <queue>

class VideoHandDetector
{
public:
    // VideoHandDetector(const std::string cascadeFilePath, cv::VideoCapture &videoCapture);
    VideoHandDetector();
    ~VideoHandDetector();

    cv::Point               getFrameAndDetect(cv::Mat &frame);
    cv::Point               operator>>(cv::Mat &frame);
    void                    setVideoCapture(cv::VideoCapture &videoCapture);
    cv::VideoCapture*       videoCapture() const;
    void                    setFaceCascade(const std::string cascadeFilePath);
    cv::CascadeClassifier*  faceCascade() const;
    void                    setResizedWidth(const int width);
    int                     resizedWidth() const;
	bool					isFaceFound() const;
    cv::Rect                face() const;
    cv::Point               facePosition() const;
    void                    setTemplateMatchingMaxDuration(const double s);
    double                  templateMatchingMaxDuration() const;
    std::queue<cv::Mat>     getLastKnownFaceTemplateQueue() const;

private:
    bool isTracking;
};
