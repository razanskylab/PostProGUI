# Post Processing App Notes

## Overview
<!-- TODO -->
<!-- Put updated GUI pictures here!
<img src="https://user-images.githubusercontent.com/558053/71764036-261b5200-2ee3-11ea-9140-258850ba51ee.png" width="200"> -->


## Usage

### Supported Data Formats

1. Map Data - .mat file with the following variables:
   - mapRaw: nX x nY matrix of type single/double
   - depthMap: same size as mapRaw, containing depth info for each xy position
   - x, y: vectors of size nX/nY of type single/double defining size of image
   - ![image](https://user-images.githubusercontent.com/558053/71764251-bc507780-2ee5-11ea-8d90-28584292e991.png)

2. Volumetric Data - .mat file with the following variables:
   - volData
   - dt
   - x, y, z
   - ![image](https://user-images.githubusercontent.com/558053/71764000-b9a05300-2ee2-11ea-82dc-31744f20bc9c.png)
3. MVolume Class - see <https://github.com/razanskylab/MVolume>
4. TODO Tiff or Tiff-Stack
5. TODO Load variables (Vol/Map) from workspace

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

### Vessel Analysis

#### Parameters

- min obj size
  - the minimum size an object needs to exceed in order to be kept
  - defined as number of pixels
- fill hole size
  - minimum size of a 'hole' (i.e. an undetected region entirely surrounded by detected pixels)
  - defined as number of pixels
  - smaller holes will be filled in
- min spur length
  - length of spurs that should be removed from the thinned vessel centrelines
  - spurs are offshoots from the centreline, thus they cause branches - which can lead to vessels being erroneously sub-divided
  - On the other hand, some spurs can really be the result of actual vessel branches - and should probably be kept.
  - parameter is a length (in pixels) that a spur must exceed for it % to be kept (Default = 10).
- clear near branch
  - TRUE if centre lines should be shortened approaching branch points, so that any pixel is removed from the centre line if it is closer to the branch than to the background (i.e. FALSE pixels in BW).
  - If measurements do not need to be made very close to branches (where they may be less accurate), this can give a cleaner result
- min spline length
  - The minimum length of a vessel segment centre line for it to be kept. Must be >= 3 because of need for angles.
  - The spur removal will only get rid of terminal segments, but very short segments might remain between branches, in which case this parameter becomes relevant.
- remove fat vessels
  - remove vessels with diameter greater than the number of pixels in their centreline.
  - Such segments are usually not measureable vessels.
  - Keeping them can have a disproportionate effect upon processing time, because longer image profiles need to be computed for every vessel just to make sure that enough pixels are included for these extreme segements
- spline smoothness
  - The approximate spacing that should occur between spline pieces (in pixels)
  - A higher value implies fewer pieces, and therefore a smoother spline fit
- smooth parallel & smooth perpend.
  - scaling parameters that multiply the estimate width computed for the vessel under consideration to determine how much smoothing is applied
  - SMOOTH_PARALLEL/PERPENDICULAR is multiplied by the width, and the square root of the result gives the sigma for the Gaussian filter
  - Although not essential, SMOOTH_SCALE_PERPENDICULAR should be >= SMOOTH_SCALE_PARALLEL
- force connectivity
  - TRUE if all pixels along the vessel edge should be connected to one another, i.e. within a distance of approximately one pixel from one another, FALSE otherwise.
  - Setting this to TRUE can improve the results by reducing the risk that the edges of neighbouring structures or the central light reflex are erroneously linked to the vessel, but in some images it might cause even vessels that appear clearly visible to be missed because their edge (as determined by the algorithm) is too variable or fragmented

## ToDos

- optimize unsharp masking or get rid of it, find better sharping tools?

## Acknowledgement

- icons used troughout GUI from <https://fontawesome.com/license/free>[FontAwesome (CC BY 4.0)]

ENFORCE_CONNECTEDNESS - 

