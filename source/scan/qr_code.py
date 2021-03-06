'''
Reading QR codes and identifying pages.
'''

import libzbar as zb
from . import image_utils
from .errors import CouldNotGetQRCode
from .constants import PAPER

def make_square(image):
    h, w = image.shape
    d = abs(h - w) // 2
    if h == w:
        return image
    elif h > w:
        return image[d:-(h - w - d), : ]
    else:  # w > h.
        return image[ : ,d:-(w - h - d)]

def read_qr_via_smoothings(image):
    '''We try various transforms to improve recognitition'''
    image = make_square(image)  # For some reason zb.Image.scan() only works on square images!
    for sigma in [0, 1, 2]:
        smoothed = image_utils.smooth_image(image, sigma)  # Smooth out speckles to make QR codes less jagged.
        ans = zb.Image.from_np(smoothed.shape, smoothed).scan()
        if ans:
            return ans
    return []

def read_qr(image):
    ans = read_qr_via_smoothings(image)
    if len(ans) != 2:  # One last trick
        image = image_utils.square_dilation(image, size=2)
        alt = read_qr_via_smoothings(image)
        if len(ans) < len(alt):
            ans = alt
    return ans

def read_qr_from_lower_corners(image, paper='letter'):
    return [code for qr in ['qr_left', 'qr_right'] for code in read_qr(image_utils.image_fraction(image, PAPER[paper][qr]))]

def read_page_id(image):
    codes = read_qr_from_lower_corners(image)
    if len(codes) == 0:
        raise CouldNotGetQRCode('No codes found')
    data = {qr.data for qr in codes}
    if len(data) > 1:
        raise CouldNotGetQRCode('Different codes found')
    code = codes[0].data.decode('ascii')
    return code.replace('(', '').replace(')', '')
