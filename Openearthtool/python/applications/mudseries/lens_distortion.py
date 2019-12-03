import cv2
from exifread import process_file as pf
from lensfunpy import Database as LensDB
from lensfunpy import Modifier as LensMF


def get_distortion(exiftags, distance=1.0):
    """Determine distortion of picture based on it's exif values."""

    def gettagvalue(tag, exiftags=exiftags):
        if tag in exiftags:
            return exiftags[tag].values
        else:
            return None

    # Determine camera and lenses
    cam_maker = gettagvalue("Image Make")
    cam_model = gettagvalue("Image Model")
    lens_model = gettagvalue("MakerNote LensModel")

    # Determine image size
    width = gettagvalue("EXIF ExifImageWidth")[0]
    height = gettagvalue("EXIF ExifImageLength")[0]

    # Determine focal length, aperture and distance
    focal_length = gettagvalue("EXIF FocalLength")[0]
    aperture = gettagvalue("EXIF FNumber")[0]
    focal_length = focal_length.num / float(focal_length.den)
    aperture = aperture.num / float(aperture.den)

    # Find camera
    db = LensDB()
    cams = db.find_cameras(cam_maker, cam_model)
    cam = cams[0] if len(cams) > 0 else None

    # Find lens
    lenses = db.find_lenses(cam, lens=lens_model)
    lens = lenses[0] if len(lenses) > 0 else None

    # Set up modifier
    mod = LensMF(lens, cam.crop_factor, width, height)
    mod.initialize(focal_length, aperture, float(distance))
    undist_coords = mod.apply_geometry_distortion()

    return undist_coords


if __name__ == "__main__":

    fn = "mask_white.JPG"
    fn_out = "mask_white_rectified.JPG"
    jpg = open(fn, 'rb')
    tags = pf(jpg)

    # pp = PP()  # pretty printer
    # pp.pprint(tags)

    im = cv2.imread(fn)
    undist_coords = get_distortion(tags)
    im_undistorted = cv2.remap(im, undist_coords, None, cv2.INTER_LANCZOS4)
    cv2.imwrite(fn_out, im_undistorted)

    fn2 = "IMG_2952.JPG"
    fn_out2 = "IMG_2952_rectified.JPG"

    im2 = cv2.imread(fn2)
    im_undistorted2 = cv2.remap(im2, undist_coords, None, cv2.INTER_LANCZOS4)
    cv2.imwrite(fn_out2, im_undistorted2)