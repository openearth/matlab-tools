from pyramid.view import view_config
from pyramid.response import Response

import numpy as np
import cox
from cox.enums import *

@view_config(route_name='home', renderer='templates/mytemplate.pt')
def my_view(request):
    return {'project': 'cox'}

@view_config(route_name='image')
def my_image(request):
    
    #print cox.convert.ConvertCelsToFah(12)
    
    cHandle, cTimerID = cox.connection.OpenConnect()
    #cox.SendMessageToCamera(cHandle, cTimerID, messageID=IRF_MESSAGE_TYPE_T._IRF_SET_CAM_DATA, messageType=CMD_FLIP, rCode=0)
    #cox.SendMessageToCamera(cHandle, cTimerID, messageID=IRF_MESSAGE_TYPE_T._IRF_SET_CAM_DATA, messageType=CMD_COLORBAR, rCode=1)
    #cox.SendMessageToCamera(cHandle, cTimerID, messageID=IRF_MESSAGE_TYPE_T._IRF_SET_CAM_DATA, messageType=CMD_LEVEL, rCode=25)
    #cox.SendMessageToCamera(cHandle, cTimerID, messageID=IRF_MESSAGE_TYPE_T._IRF_SET_CAM_DATA, messageType=CMD_SPAN, rCode=1)
    #cox.SendMessageToCamera(cHandle, cTimerID, messageID=IRF_MESSAGE_TYPE_T._IRF_SET_CAM_DATA, messageType=CMD_TEMP_VIEW, rCode=0)
    #cox.SendMessageToCamera(cHandle, cTimerID, messageID=IRF_MESSAGE_TYPE_T._IRF_SET_CAM_DATA, messageType=CMD_ZOOM, rCode=0)
    
    #cox.SendMessageToCamera(cHandle, cTimerID, messageID=IRF_MESSAGE_TYPE_T._IRF_REQ_SYS_INFO)
    #cox.SendMessageToCamera(cHandle, cTimerID, messageID=IRF_MESSAGE_TYPE_T._IRF_SYS_INFO)
    
    cox.connection.SendCameraMessage(cHandle, cTimerID, messageID=IRF_MESSAGE_TYPE_T._IRF_STREAM_ON)
    
    #cFileHandle = cox.SaveIRImage(r"d:\COX\teststreamXX.crd")
    
    #for i in range(3):
    #  cCamData = cox.GetIRBuffer(cHandle, cTimerID)
    #  cox.SetIRImageToStream(cFileHandle, cCamData.ir_image, millisecond=1000, frameCnt=60)
    
    cCamData = cox.connection.GetIRBuffer(cHandle, cTimerID)
    T = cox.temperature.GetRawToTemp(cCamData.ir_image)
    
    cox.netcdf.add_to_netcdf(r"d:\COX\test.nc", T)
    
    img = cox.image.GetIRImages(cHandle, cTimerID)
    img = cox.image.GetImage(img, autoScale='manual', level=20, span=20)
    img = cox.image.GetGrayToPaletteImage(img, palette=cox.temperature.GetImageLUT(IRF_PALETTE_TYPE_T.GREY_COLOR_MAP, invert=False))
    img = cox.plot.plot_image(img)
    
    #cox.CloseIRStream(cFileHandle)
    cox.connection.CloseConnect(cHandle, cTimerID)
    
    return Response(body=img, content_type='image/jpeg')
    
@view_config(route_name='video', renderer='templates/video.pt')
def my_video(request):
    return {'project': 'cox'}
    
@view_config(route_name='test')
def my_test(request):

    #hist = cox.GetIRHistogram(cam_data.ir_image)
    #print hist
    
    print cox.GetTempRangeValue(IRF_DYNAMIC_RANGE_T._IRF_LOW_RANGE)
    print cox.GetTempRangeValue(IRF_DYNAMIC_RANGE_T._IRF_MIDDLE_RANGE)
    print cox.GetTempRangeValue(IRF_DYNAMIC_RANGE_T._IRF_HIGH_RANGE)
    
    tempLUT = cox.GetTempMapTable()
    print tempLUT[:100]
    
    palette = cox.GetImageLUT()
    print palette[:100]
    
    return Response(body='DONE', content_type='text/plain')