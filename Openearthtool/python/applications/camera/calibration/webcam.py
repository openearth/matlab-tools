import os
import cv
import cv2
import numpy as np
#from cox import cox

STREAM_TYPE = 'WEBCAM'

n = 100

patternSize = (7,5) #(7,4)
imageSize = (600*1280/720, 600)

patternPoints = np.zeros((np.prod(patternSize),3), np.float32)
patternPoints[:,:2] = np.indices(patternSize).T.reshape(-1, 2)

scale = max( float(min(imageSize))/(min(patternSize)-1),
             float(max(imageSize))/(max(patternSize)-1) ) * 1.2 / 3
patternPoints = patternPoints * scale

offsetX = (imageSize[0] - max(patternPoints[:,0])) * 1.2 * 1.2 / 2
offsetY = (imageSize[1] - max(patternPoints[:,1])) * 1.2 * 1.2 / 2
patternPoints[:,0] = patternPoints[:,0] + offsetX
patternPoints[:,1] = patternPoints[:,1] + offsetY

def open_stream():
    cv2.namedWindow("webcam",1)

    if STREAM_TYPE == 'IR':
        cHandle, cTimerID = cox.connection.OpenConnect()
        return (cHandle, cTimerID)
    else:
        stream = cv2.VideoCapture()
        stream.open(0)
        return stream

def close_stream():
    cv2.destroyWindow("camera")

def capture_frame(stream):
    if STREAM_TYPE == 'IR':
        cHandle, cTimerID = stream
        images, n = cox.image.GetIRImageStream(cHandle, cTimerID, interval, 2)
        img = images['snap']
    else:
        img = stream.read()[1]
        img = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY).astype(np.uint8)

    return img

def show_frame(img, isCalibrated=False, framesCaptured=0, framesNeeded=100):
    img = cv2.resize(img, imageSize)

    msg = 'no messages'
    if isCalibrated:
        msg = 'calibrated'
    else:
        if framesCaptured >= framesNeeded:
            msg = 'processing...'
        else:
            msg = 'calibrating... %d%%' % (float(framesCaptured)/framesNeeded*100)
    
    cv2.putText(img, msg, (10,50), cv2.FONT_HERSHEY_PLAIN, 3, (0,255,0), thickness=3)
    #cv2.imwrite('capture.png', img)
    cv2.imshow("webcam", img)
    cv2.waitKey(10)

def find_chessboard(img):
    corners = np.array((np.prod(patternSize),1,2))
#    patternWasFound, corners = cv2.findChessboardCorners(img, patternSize, cv.CV_CALIB_CB_FILTER_QUADS+cv.CV_CALIB_CB_ADAPTIVE_THRESH)
    patternWasFound, corners = cv2.findCirclesGrid(img, patternSize, 0, cv2.CALIB_CB_SYMMETRIC_GRID)

    if patternWasFound:
        print corners.shape
        cv2.drawChessboardCorners(img, patternSize, corners, patternWasFound)

        return (img, corners.reshape(-1,2))
    else:
        return (img, None)

def undistort_chessboard(img, corners, cameraMatrix, distCoeffs):
    img = cv2.undistort(img, cameraMatrix, distCoeffs)

    if not corners == None:
        corners = np.array([corners[:,:2]]).astype(np.float32)
        corners_undist = cv2.undistortPoints(corners, cameraMatrix, distCoeffs, P=cameraMatrix).squeeze()

        H, dc = cv2.findHomography(corners_undist.astype(np.float32),patternPoints[:,:2].astype(np.float32),cv.CV_RANSAC)
        img = cv2.warpPerspective(img, H, (img.shape[1],img.shape[0]))

    return img

def read_calibration():
    if os.path.exists('imagePoints.txt'):
        corners = np.loadtxt('imagePoints.txt')
        corners = corners.reshape((corners.shape[0],-1,2))
        corners = [corners[i,:,:].astype(np.float32) for i in range(corners.shape[0])]

        return corners
    else:
        return []

if __name__ == "__main__":
    stream = open_stream()

    isCalibrated = False
    
    imagePoints = read_calibration()

    while True:
        img = capture_frame(stream)
        img, corners = find_chessboard(img)
        
        if not isCalibrated:
            
            if not corners == None:

                imagePoints.append(corners)

            if len(imagePoints) >= n:
                show_frame(img, isCalibrated, n, n)

                np.savetxt('imagePoints.txt', np.array(imagePoints).reshape(n,-1))
                    
                objectPoints = [patternPoints.astype(np.float32) for i in range(len(imagePoints))]
                rms, cameraMatrix, distCoeffs, rvecs, tvecs = cv2.calibrateCamera(objectPoints[::3], imagePoints[::3], img.shape[:2])
                k1, k2, p1, p2, k3 = distCoeffs[0]
                
                isCalibrated = True

        else:
            img = undistort_chessboard(img, corners, cameraMatrix, distCoeffs)

        show_frame(img, isCalibrated, len(imagePoints), n)
        
