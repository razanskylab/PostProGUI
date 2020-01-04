# Post Processing App Notes

## Overview

### Volume Processing
![image](https://user-images.githubusercontent.com/558053/71764015-dfc5f300-2ee2-11ea-8aa4-a475496632a7.png)

### Image Processing
![image](https://user-images.githubusercontent.com/558053/71764025-0be17400-2ee3-11ea-84a9-e20000e0f01a.png)

## Usage

### Supported Data Formats

1. Map Data - .mat file with the following variables:
   - map: nX x nY matrix of type single/double
   - dt: sampling period, i.e. 1./(sampling frequency), scalar 
   - x, y: vectors of size nX/nY of type single/double defining size of image
2. Volumetric Data - .mat file with the following variables:
   - volData
   - dt
   - x, y, z
   - ![image](https://user-images.githubusercontent.com/558053/71764000-b9a05300-2ee2-11ea-82dc-31744f20bc9c.png)
3. MVolume Class - see <https://github.com/razanskylab/MVolume>
4. TODO Tiff or Tiff-Stack

## General Structure

- PostProGUI.mlapp
  - defines GUI layout and callbacks but basically no functionality
- @PostProBackEnd
  - class that does the actual processing, i.e. loading, processing and exporting of data

## PostProApp sub classes

- FRFilt - Frangi Filter
- FreqFilt - Filter Class
  - class for volumetric frequency filtering
- Image Filter
- ToDo: add AOVA vessels analysis

## processing workflow

### Volumetric Processing

- rawVol during load, format is [zxy]
- dsVol by downsampling along xy and z
- cropVol by cropping along z
- freqVol by frequency filtering, input format is [zxy], output format is [xyz]
- filtVol by median filtering in xyz
- procVol by applying signal polarity

### Map Processing

- base image is PPA.procVolProj, i.e. processed volumetric projection
  - projection of volumetric data after all filtering etc. on volume has been performed
- processing steps (all optional)
  1. spot removal
     - custom made function, see remove_spot_noise.m
  2. interpolation
     - using interp2, works for both up (factor > 1) and downsampling (factor < 1)
  3. clahe filtering
     - Contrast-limited adaptive histogram equalization (CLAHE)
     - <https://ch.mathworks.com/help/images/ref/adapthisteq.html?s_tid=doc_ta> 
     - Zuiderveld, Karel. “Contrast Limited Adaptive Histograph Equalization.” Graphic Gems IV. San Diego: Academic Press Professional, 1994. 474–485.
  4. wiender filtering
     - 2-D adaptive noise-removal filtering
     - <https://ch.mathworks.com/help/images/ref/wiener2.html?searchHighlight=wiener2&s_tid=doc_srchtitle>
     - Lim, Jae S., Two-Dimensional Signal and Image Processing, Englewood Cliffs, NJ, Prentice Hall, 1990, p. 548, equations 9.26, 9.27, and 9.29.
  5. unsharp masking
     - work in progress, don't use yet...
  6. image guided filtering
     - the guided filter computes the filtering output by considering the content of a guidance image, which can be the input image itself or another different image
     - the guided filter can be used as an edge-preserving smoothing operator
     - <https://ch.mathworks.com/help/images/ref/imguidedfilter.html>
     - <http://kaiminghe.com/eccv10/>

## ToDos

- optimize unsharp masking or get rid of it, find better sharping tools?
