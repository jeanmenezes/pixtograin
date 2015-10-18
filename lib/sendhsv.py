#!/usr/bin/python2

#from PIL import Image
import colorsys
from sklearn.cluster import KMeans
import numpy as np
import OSC


def HSVColor(r, g, b):
    return colorsys.rgb_to_hsv(r/255., g/255., b/255.)


def meanColor(img):
    a = np.array(img, dtype=np.float64)
    w, h, d = tuple(a.shape)
    assert d == 3
    image_array = np.reshape(a, (w * h, d))

    kmeans = KMeans(n_clusters=1, random_state=0).fit(image_array)
    labels = kmeans.predict(image_array)

    def recreate_image(codebook, labels, w, h):
        d = codebook.shape[1]
        image = np.zeros((w, h, d))
        label_idx = 0
        for i in range(w):
            for j in range(h):
                image[i][j] = codebook[labels[label_idx]]
                label_idx += 1
        return image

    bar = recreate_image(kmeans.cluster_centers_, labels, w, h)
    r, g, b = bar[0][0]
    return HSVColor(r, g, b)


def pixelValues(img, x=None, y=None):
    thepixels = []
    if not (x and y):
        print "getting values for every pixel..."
        pix = img.load()
        halfwidth = img.width / 2
        for y in range(img.height):
            for x in range(img.width):
                sig = -1 if x < halfwidth else 0 if x == halfwidth else 1
                r, g, b = pix[x,y]
                thepixels.append((x, y, HSVColor(r, g, b), sig))
    else:
        print "getting values for pixel at ({0}, {1})...".format(x, y)
        pix = img.load()
        halfwidth = img.width / 2
        r, g, b = pix[x,y]
        sig = -1 if x < halfwidth else 0 if x == halfwidth else 1
        thepixels.append((x, y, HSVColor(r, g, b), sig))
    thepixels.append((-1, 0, (0, 0, 0), 0))
    return thepixels


def sliceValues(img, tilesize=None, linesize=None, columnsize=None):
    slicedata = []
    w, h = img.size
    if linesize > 0:
        print "getting values for every line..."
        for l in range(0, h, linesize):
            sig = 0
            slicedata.append((0, l, meanColor(img.crop((0, l, w, l+linesize))), sig))
    elif columnsize > 0:
        print "getting values for every column..."
        for c in range(0, w, columnsize):
            sig = -1 if c < (w / 2) else 0 if c == (w / 2) else 1
            slicedata.append((c, 0, meanColor(img.crop((c, 0, c+columnsize, h))), sig))
    else:
        print "getting values for every segment..."
        if isinstance(tilesize, tuple):
            tilewidth, tileheight = tilesize
        elif isinstance(tilesize, int):
            tilewidth = tilesize
            tileheight = tilesize
        for hs in range(0, h, tileheight):
            for ws in range(0, w, tilewidth):
                sig = -1 if ws < (w / 2) else 0 if ws == (w / 2) else 1
                slicedata.append((hs, ws, meanColor(img.crop((ws, hs, ws+tilewidth, hs+tileheight))), sig))
    slicedata.append((-1, 0, (0, 0, 0), 0))
    return slicedata


def imageMeanColor(img):
    return meanColor(img)


def communicateWithChuck(vals):
    print "sending OSC messages to ChucK..."
    client = OSC.OSCClient()
    client.connect(('127.0.0.1', 6172))
    for val in vals:
        msg = OSC.OSCMessage()
        msg.setAddress("/hsl")
        msg.append(val)
        client.send(msg)
    client.close()
