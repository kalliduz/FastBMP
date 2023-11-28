# FastBMP
A lightweight wrapper for direct pixel data access. The current implementation is limited to 24-bit Bitmap and will enforce this pixel format.

## Usage
You can attach to an existing Bitmap and use it like a wrapper.
```
LBMP:= TFastBMP.Create(0,0);
LBMP.AttachToBitmap(Image1.Picture.Bitmap);
//Pixel access code
Image1.Repaint;
```
Create your own Bitmap
```
LBMP:= TFastBMP.Create(640,480);  
```
Or copy an existing Bitmap
```
LBMP:= TFastBMP.Create(Image1.Picture.Bitmap);
```

Afterwards, you can access the pixels with
```
LBMP.Pixels[42,42].R:= 42;
```
This works around 1000 times faster than the access through Bitmap.Canvas.Pixels, since it makes use of ScanLine.

## Future plans
- support for several pixel formats

