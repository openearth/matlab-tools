import numpy as np
import cv2

help_message = '''
USAGE: opt_flow.py [<video_source>]

Keys:
1 - toggle HSV flow visualization
2 - toggle glitch

'''

def draw_flow(img, flow, step=16):
    h, w = img.shape[:2]
    y, x = np.mgrid[step/2:h:step, step/2:w:step].reshape(2,-1)
    fx, fy = -flow[y,x].T
    lines = np.vstack([x, y, x+fx, y+fy]).T.reshape(-1, 2, 2)
    lines = np.int32(lines + 0.5)
    vis = cv2.cvtColor(img, cv2.COLOR_GRAY2BGR)
    cv2.polylines(vis, lines, 0, (0, 255, 0))
    for (x1, y1), (x2, y2) in lines:
        cv2.circle(vis, (x1, y1), 1, (0, 255, 0), -1)
    return vis

def draw_hsv(flow):
    h, w = flow.shape[:2]
    fx, fy = flow[:,:,0], flow[:,:,1]
    ang = np.arctan2(fy, fx) + np.pi
    v = np.sqrt(fx*fx+fy*fy)
    hsv = np.empty((h, w, 3), np.uint8)
    hsv[...,0] = ang*(180/np.pi/2)
    hsv[...,1] = 255 # Always saturate
    hsv[...,2] = np.minimum(v*4, 255)
    bgr = cv2.cvtColor(hsv, cv2.COLOR_HSV2BGR)
    return bgr

def warp_flow(img, flow):
    h, w = flow.shape[:2]
    flow = -flow
    flow[:,:,0] += np.arange(w)
    flow[:,:,1] += np.arange(h)[:,np.newaxis]
    res = cv2.remap(img, flow, None, cv2.INTER_LINEAR)
    return res

if __name__ == '__main__':
    import sys
    print help_message

    # Creata a camera object that allows to get the latest images
    # See: http://docs.opencv.org/modules/highgui/doc/reading_and_writing_images_and_video.html#videocapture
    cam = cv2.VideoCapture('../data/ad/VID00004.MP4')
    # Set the resolution of the captured image
    cam.set(cv2.cv.CV_CAP_PROP_FRAME_HEIGHT, 768)
    cam.set(cv2.cv.CV_CAP_PROP_FRAME_WIDTH, 1024)
    # ret, prev are both returned
    # ret is the return status
    # prev is the image (stored in previous image, because we'll collect the "current" image in the loop
    ret, prev = cam.read()
    # get every other pixel ::2 -> slice from 0 to n in steps of 2
    # make a copy because we're converting it inline to black and white.
    # And we're also showing the full resolution color image
    prev = prev[::2,::2,:].copy()
    # Convert the scaled image to grey scale
    prevgray = cv2.cvtColor(prev, cv2.COLOR_BGR2GRAY)
    # Some gui options (hsv -> hue, saturation value) 
    show_hsv = False
    # show_glitch -> shows the mapped image, useful to detect glitches (applies the flow field to the initial image)
    show_glitch = False
    # use this image for glitch detection. 
    cur_glitch = cv2.imread('chessboard.jpg')

    # Create an array to store the flow calculation
    # Equivalant to CreateImage
    # http://docs.opencv.org/modules/core/doc/old_basic_structures.html#createimage
    # prevgray.shape[0] -> 1024/2, prevgray.shape[1] -> 768/2
    # 2 channels because we're storing both the x and y component (u,v) of the vector
    flow = np.empty((prevgray.shape[0], prevgray.shape[1], 2),dtype='float32')
    # We need 2 extra arrays (images) for the updated average
    # We compute the mean flow_u and mean flow_v components
    # Note that the mean is computed as sum(x)/n(x), where n is the number of x's
    # This array keeps track of the sum of all u and v velocties (u,v). Are the 2 channels.
    sumflow = np.zeros((prevgray.shape[0], prevgray.shape[1], 2),dtype='float32')
    # This array keeps track of the number of observed vectors. 
    nflow = np.zeros((prevgray.shape[0], prevgray.shape[1], 2),dtype='int32')

    # This can be a for loop over the number of collected images.
    
    while True:
        # Read the next image from the camera
        ret, img = cam.read()
        # Make a copy of the half resolution image 
        img = img[::2,::2,:].copy()
        # Convert the image to grey scale
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        # Now we compute the optical flow.
        # The flow is passed as a reference and will be updated in the flow computation.
        # See also: http://docs.opencv.org/modules/video/doc/motion_analysis_and_object_tracking.html#calcopticalflowfarneback
        # Gray is the current image, prevgray is the old image
        res = cv2.calcOpticalFlowFarneback(prevgray, gray, flow, 0.5, 5, 10, 3, 5, 1.1,0) #, cv2.OPTFLOW_USE_INITIAL_FLOW) #, 0.5, 3, 5, 3, 3, 1, 1.5, 3) #, 15, 3, 5, 3, 0, 1)
        prevgray = gray
        # This sums up all the sumflow elements with the corresponding values of the computed flow
        # equivalent to:
        # for (int i=0; i<img.SizeX();i++) {
        #  for (int j=0; j<img.SizeY();j++) {
        #   for (int c=0; c<2;c++) {
        #    sumflow[i,j,c] += flow[i,j,c];
        #   }
        #  }
        # }
        sumflow += flow
        nflow += 1
        # display the img
        cv2.imshow('movie', img)
        # draw the arrows
        cv2.imshow('flow', draw_flow(gray, flow))
        # draw the hue saturation value
        if show_hsv:
            cv2.imshow('flow HSV', draw_hsv(flow))
        # draw the mean flow (exagerated by a factor of 100)
        cv2.imshow('mean flow HSV', draw_hsv(100*sumflow/nflow))

        # show the glitch image
        if show_glitch:
            cur_glitch = warp_flow(cur_glitch, flow)
            cv2.imshow('glitch', cur_glitch)

        # Detect a key in the gui and turn on/off glitch/hsv.
        ch = cv2.waitKey(5)
        if ch == 27:
            break
        if ch == ord('1'):
            show_hsv = not show_hsv
            print 'HSV flow visualization is', ['off', 'on'][show_hsv]
        if ch == ord('2'):
            show_glitch = not show_glitch
            if show_glitch:
                cur_glitch = cv2.imread('chessboard.jpg')
                # cur_glitch = img.copy()
            print 'glitch is', ['off', 'on'][show_glitch]
