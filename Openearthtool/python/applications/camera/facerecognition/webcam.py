import cv
import pygame
import pygame.camera
import pygame.draw
import numpy as np
from pygame.locals import *

pygame.init()
pygame.camera.init()

class Capture(object):
    def __init__(self):
        self.size = (640,480)
        # create a display surface. standard pygame stuff
        self.display = pygame.display.set_mode(self.size, 0)
        
        # this is the same as what we saw before
        self.clist = pygame.camera.list_cameras()
        if not self.clist:
            raise ValueError("Sorry, no cameras detected.")
        self.cam = pygame.camera.Camera(self.clist[0], self.size)
        self.cam.start()

        # create a surface to capture to.  for performance purposes
        # bit depth is the same as that of the display surface.
        self.snapshot = pygame.surface.Surface(self.size, 0, self.display)

    def get_and_flip(self):
        # if you don't want to tie the framerate to the camera, you can check 
        # if the camera has an image ready.  note that while this works
        # on most cameras, some will never return true.
        #if self.cam.query_image():
        self.snapshot = self.cam.get_image(self.snapshot)
        
        faces = self.detect_face(self.snapshot)
        
        if faces:
            for face in faces:
                pygame.draw.rect(self.snapshot, (0,255,0), list(face[0]), 3)

        # blit it to the display surface.  simple!
        self.display.blit(self.snapshot, (0,0))
        pygame.display.flip()
        
    def detect_face(self, image):
        arr = pygame.surfarray.array3d(image)
        arr = np.ascontiguousarray(arr)
        image = cv.fromarray(arr)
    	storage = cv.CreateMemStorage()
	haar = cv.Load('haarcascade_frontalface_default.xml')
	detected = cv.HaarDetectObjects(image, haar, storage, 1.2, 2, cv.CV_HAAR_DO_CANNY_PRUNING, (100,100))
	if detected:
            for face in detected:
                print face
                
	return detected #[((311,324,117,117),3)]

    def main(self):
        going = True
        while going:
            events = pygame.event.get()
            for e in events:
                if e.type == QUIT or (e.type == KEYDOWN and e.key == K_ESCAPE):
                    # close the camera safely
                    self.cam.stop()
                    going = False

            self.get_and_flip()
            
Capture().main()