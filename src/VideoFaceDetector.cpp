#include "VideoFaceDetector.h"
#include <iostream>
#include <opencv2/imgproc.hpp>
#include <GodotGlobal.hpp>
#include <queue>

const double VideoFaceDetector::TICK_FREQUENCY = cv::getTickFrequency();

VideoFaceDetector::VideoFaceDetector() {
    
}

void VideoFaceDetector::setVideoCapture(cv::VideoCapture &videoCapture)
{
    m_videoCapture = &videoCapture;
}

cv::VideoCapture *VideoFaceDetector::videoCapture() const
{
    return m_videoCapture;
}

void VideoFaceDetector::setFaceCascade(const std::string cascadeFilePath)
{
    if (m_faceCascade == NULL) {
        m_faceCascade = new cv::CascadeClassifier(cascadeFilePath);
    }
    else {
        m_faceCascade->load(cascadeFilePath);
    }

    if (m_faceCascade->empty()) {
        std::cerr << "Error creating cascade classifier. Make sure the file" << std::endl
            << cascadeFilePath << " exists." << std::endl;
    }
}

cv::CascadeClassifier *VideoFaceDetector::faceCascade() const
{
    return m_faceCascade;
}

void VideoFaceDetector::setResizedWidth(const int width)
{
    m_resizedWidth = std::max(width, 1);
}

int VideoFaceDetector::resizedWidth() const
{
    return m_resizedWidth;
}

bool VideoFaceDetector::isFaceFound() const
{
	return m_foundFace;
}

cv::Rect VideoFaceDetector::face() const
{
    cv::Rect faceRect = m_trackedFace;
    faceRect.x = (int)(faceRect.x / m_scale);
    faceRect.y = (int)(faceRect.y / m_scale);
    faceRect.width = (int)(faceRect.width / m_scale);
    faceRect.height = (int)(faceRect.height / m_scale);
    return faceRect;
}

cv::Point VideoFaceDetector::facePosition() const
{
    cv::Point facePos;
    facePos.x = (int)(m_facePosition.x / m_scale);
    facePos.y = (int)(m_facePosition.y / m_scale);
    return facePos;
}

void VideoFaceDetector::setTemplateMatchingMaxDuration(const double s)
{
    m_templateMatchingMaxDuration = s;
}

double VideoFaceDetector::templateMatchingMaxDuration() const
{
    return m_templateMatchingMaxDuration;
}

VideoFaceDetector::~VideoFaceDetector()
{
    if (m_faceCascade != NULL) {
        delete m_faceCascade;
    }
}

cv::Rect VideoFaceDetector::doubleRectSize(const cv::Rect &inputRect, const cv::Rect &frameSize) const
{
    cv::Rect outputRect;
    // Double rect size
    outputRect.width = inputRect.width * 2;
    outputRect.height = inputRect.height * 2;

    // Center rect around original center
    outputRect.x = inputRect.x - inputRect.width / 2;
    outputRect.y = inputRect.y - inputRect.height / 2;

    // Handle edge cases
    if (outputRect.x < frameSize.x) {
        outputRect.width += outputRect.x;
        outputRect.x = frameSize.x;
    }
    if (outputRect.y < frameSize.y) {
        outputRect.height += outputRect.y;
        outputRect.y = frameSize.y;
    }

    if (outputRect.x + outputRect.width > frameSize.width) {
        outputRect.width = frameSize.width - outputRect.x;
    }
    if (outputRect.y + outputRect.height > frameSize.height) {
        outputRect.height = frameSize.height - outputRect.y;
    }

    return outputRect;
}

cv::Point VideoFaceDetector::centerOfRect(const cv::Rect &rect) const
{
    return cv::Point(rect.x + rect.width / 2, rect.y + rect.height / 2);
}

cv::Rect VideoFaceDetector::biggestFace(std::vector<cv::Rect> &faces) const
{
    assert(!faces.empty());

    cv::Rect *biggest = &faces[0];
    for (auto &face : faces) {
        if (face.area() < biggest->area())
            biggest = &face;
    }
    return *biggest;
}

/*
* Face template is small patch in the middle of detected face.
*/
cv::Mat VideoFaceDetector::getFaceTemplate(const cv::Mat &frame, cv::Rect face)
{
    face.x += face.width / 4;
    face.y += face.height / 4;
    face.width /= 2;
    face.height /= 2;

    cv::Mat faceTemplate = frame(face).clone();
    return faceTemplate;
}

void VideoFaceDetector::detectFaceAllSizes(const cv::Mat &frame)
{
    // Minimum face size is 1/5th of screen height
    // Maximum face size is 2/3rds of screen height
    m_faceCascade->detectMultiScale(frame, m_allFaces, 1.1, 3, 0,
        cv::Size(frame.rows / 5, frame.rows / 5),
        cv::Size(frame.rows * 2 / 3, frame.rows * 2 / 3));

    if (m_allFaces.empty()) return;

    m_foundFace = true;
    lost_tracking = false;

    // Locate biggest face
    m_trackedFace = biggestFace(m_allFaces);

    too_close = m_trackedFace.height > (frame.rows / 2.5);

    // Copy face template
    m_faceTemplate = getFaceTemplate(frame, m_trackedFace);

    // Calculate roi
    m_faceRoi = doubleRectSize(m_trackedFace, cv::Rect(0, 0, frame.cols, frame.rows));

    // Update face position
    m_facePosition = centerOfRect(m_trackedFace);
}

void VideoFaceDetector::detectFaceAroundRoi(const cv::Mat &frame)
{
    // Detect faces sized +/-20% off biggest face in previous search
    m_faceCascade->detectMultiScale(frame(m_faceRoi), m_allFaces, 1.1, 3, 0,
        cv::Size(m_trackedFace.width * 8 / 10, m_trackedFace.height * 8 / 10),
        cv::Size(m_trackedFace.width * 12 / 10, m_trackedFace.height * 12 / 10));

    // When no face is found, search for a face at the 'lastSeen' location
    if (m_allFaces.empty()) 
    {
        // Face detection at 'lastSeen'
        std::vector<cv::Rect>   m_allFaces_lastSeen;
        cv::Rect m_faceRoi_lastSeen = doubleRectSize(m_trackedFace_lastSeen, cv::Rect(0, 0, frame.cols, frame.rows));
        m_faceCascade->detectMultiScale(frame(m_faceRoi_lastSeen), m_allFaces_lastSeen, 1.1, 3, 0,
            cv::Size(m_trackedFace.width * 8 / 10, m_trackedFace.height * 8 / 10),
            cv::Size(m_trackedFace.width * 12 / 10, m_trackedFace.height * 12 / 10));

        if (!m_allFaces_lastSeen.empty()) 
        {
            // A face has been found at the 'lastSeen' location
            // Override the current face data with the newly found face
            m_faceRoi = m_faceRoi_lastSeen;
            m_allFaces = m_allFaces_lastSeen;

            // Add a rectangle to the debug display queue
            cv::Rect m_trackedFace_lastSeen = biggestFace(m_allFaces_lastSeen);
        }
    }

    if (m_allFaces.empty())
    {
        // Activate template matching if not already started and start timer
        if (!m_templateMatchingRunning) m_trackedFace_lastSeen = m_trackedFace;
        m_templateMatchingRunning = true;
        if (m_templateMatchingStartTime == 0)
            m_templateMatchingStartTime = cv::getTickCount();
        return;
    }

    // Turn off template matching if running and reset timer
    m_templateMatchingRunning = false;
    m_templateMatchingCurrentTime = m_templateMatchingStartTime = 0;

    // Get detected face
    m_trackedFace = biggestFace(m_allFaces);

    if (m_trackedFace.height > (frame.rows / 3.0)) {
        too_close = true;
    } else {
        too_close = false;
    }

    // Add roi offset to face
    m_trackedFace.x += m_faceRoi.x;
    m_trackedFace.y += m_faceRoi.y;

    // Get face template
    m_faceTemplate = getFaceTemplate(frame, m_trackedFace);

    // Calculate roi
    m_faceRoi = doubleRectSize(m_trackedFace, cv::Rect(0, 0, frame.cols, frame.rows));

    // Update face position
    m_facePosition = centerOfRect(m_trackedFace);
}

void VideoFaceDetector::stopTemplateMatching()
{
    m_foundFace = false;
    m_templateMatchingRunning = false;
    m_templateMatchingStartTime = m_templateMatchingCurrentTime = 0;
    m_facePosition.x = m_facePosition.y = 0;
    m_trackedFace.x = m_trackedFace.y = m_trackedFace.width = m_trackedFace.height = 0;
    template_matching = false;
    lost_tracking = true;
}

void VideoFaceDetector::detectFacesTemplateMatching(const cv::Mat &frame)
{
    // Calculate duration of template matching
    m_templateMatchingCurrentTime = cv::getTickCount();
    double duration = (double)(m_templateMatchingCurrentTime - m_templateMatchingStartTime) / TICK_FREQUENCY;


    if (!template_matching && duration > (m_templateMatchingMaxDuration/2)) {
        template_matching = true;
    }

    // If template matching lasts for more than 2 seconds face is possibly lost
    // so disable it and redetect using cascades
    if (duration > m_templateMatchingMaxDuration) {
        stopTemplateMatching();
		return;
    }

	// Edge case when face exits frame while 
	if (m_faceTemplate.rows * m_faceTemplate.cols == 0 || m_faceTemplate.rows <= 1 || m_faceTemplate.cols <= 1) {
		stopTemplateMatching();
		return;
	}

    // Template matching with last known face 
    //cv::matchTemplate(frame(m_faceRoi), m_faceTemplate, m_matchingResult, CV_TM_CCOEFF);
    cv::matchTemplate(frame(m_faceRoi), m_faceTemplate, m_matchingResult, cv::TM_SQDIFF_NORMED);
    cv::normalize(m_matchingResult, m_matchingResult, 0, 1, cv::NORM_MINMAX, -1, cv::Mat());
    double min, max;
    cv::Point minLoc, maxLoc;
    cv::minMaxLoc(m_matchingResult, &min, &max, &minLoc, &maxLoc);

    // Add roi offset to face position
    minLoc.x += m_faceRoi.x;
    minLoc.y += m_faceRoi.y;

    // Get detected face
    //m_trackedFace = cv::Rect(maxLoc.x, maxLoc.y, m_trackedFace.width, m_trackedFace.height);
    m_trackedFace = cv::Rect(minLoc.x, minLoc.y, m_faceTemplate.cols, m_faceTemplate.rows);
    m_trackedFace = doubleRectSize(m_trackedFace, cv::Rect(0, 0, frame.cols, frame.rows));

    // Get new face template
    m_faceTemplate = getFaceTemplate(frame, m_trackedFace);

    // Calculate face roi
    m_faceRoi = doubleRectSize(m_trackedFace, cv::Rect(0, 0, frame.cols, frame.rows));

    // Update face position
    m_facePosition = centerOfRect(m_trackedFace);
}

cv::Point VideoFaceDetector::getFrameAndDetect(cv::Mat &frame)
{
    *m_videoCapture >> frame;

    // Downscale frame to m_resizedWidth width - keep aspect ratio
    m_scale = (double) std::min(m_resizedWidth, frame.cols) / frame.cols;
    cv::Size resizedFrameSize = cv::Size((int)(m_scale*frame.cols), (int)(m_scale*frame.rows));

    cv::Mat resizedFrame;
    cv::resize(frame, resizedFrame, resizedFrameSize);

    if (!m_foundFace)
        detectFaceAllSizes(resizedFrame); // Detect using cascades over whole image
    else {
        detectFaceAroundRoi(resizedFrame); // Detect using cascades only in ROI
        if (m_templateMatchingRunning) {
            detectFacesTemplateMatching(resizedFrame); // Detect using template matching
        } else {
            template_matching = false;
        }
    }


    return m_facePosition;
}

cv::Point VideoFaceDetector::operator>>(cv::Mat &frame)
{
    return this->getFrameAndDetect(frame);
}