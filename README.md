# Post Processing App Notes

## Overview
<!-- TODO -->
<!-- Put updated GUI pictures here!
<img src="https://user-images.githubusercontent.com/558053/71764036-261b5200-2ee3-11ea-9140-258850ba51ee.png" width="200"> -->

## Installation & Requirements

### If you know how to use GIT

- clone to local folder, make sure to also initialize and pull all submodules

### If you don't how to use GIT

- download and unzip the latest [release](https://github.com/razanskylab/PostProGUI/releases) (TODO)

### Requirements

- created and tested on Matlab 9.7.0.1261785 (R2019b) Update 3
- requires at least Matlab R2018b (not tested)
- required toolboxes:
  - [Control System Toolbox](https://mathworks.com/de/products/control.html)
  - [Signal Processing Toolbox](https://mathworks.com/de/products/signal.html)
  - [Image Processing Toolbox](https://mathworks.com/de/products/image.html)
  - [Computer Vision Toolbox](https://mathworks.com/de/products/computer-vision.html)

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
3. [MVolume Class](https://github.com/razanskylab/MVolume)
4. Tiff or Tiff-Stack
   - needs more testing but should be working 
5. Load variables (Vol/Map) from workspace
   - needs more testing but should be working 

## General Structure

- MasterGui
  - calls sub-guis and provides some info on the currently used data
- @PostProBackEnd
  - class that does the actual processing, i.e. loading, processing and exporting of data
- Sub-Guis
  - LoadGui -> loading of raw data from drive or workspace and simple preview
  - VolGui -> processing of volumetric data, such as frequency filtering, cropping...
  - MapGui ->
  - VesselGui ->
  - ExportGui ->

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
  3. smoothing
     - apply smoothing operation using the predefined fspecial filter
     - options
       - 'average' Averaging filter
       - 'disk' Circular averaging filter (pillbox)
       - 'gaussian' Gaussian lowpass filter
       - 'laplacian' Approximates the two-dimensional Laplacian operator
       - 'log' Laplacian of Gaussian filter
       - 'prewitt' Prewitt horizontal edge-emphasizing filter
       - 'sobel' Sobel horizontal edge-emphasizing filter
  4. clahe filtering
     - Contrast-limited adaptive histogram equalization (CLAHE)
     - <https://ch.mathworks.com/help/images/ref/adapthisteq.html?s_tid=doc_ta> 
     - Zuiderveld, Karel. “Contrast Limited Adaptive Histograph Equalization.” Graphic Gems IV. San Diego: Academic Press Professional, 1994. 474–485.
  5. [wiener filtering](<https://ch.mathworks.com/help/images/ref/wiener2.html?searchHighlight=wiener2&s_tid=doc_srchtitle>)
     - 2-D adaptive noise-removal filtering
     - Lim, Jae S., Two-Dimensional Signal and Image Processing, Englewood Cliffs, NJ, Prentice Hall, 1990, p. 548, equations 9.26, 9.27, and 9.29.
  6. image guided filtering
     - the guided filter computes the filtering output by considering the content of a guidance image, which can be the input image itself or another different image
     - the guided filter can be used as an edge-preserving smoothing operator
     - <https://ch.mathworks.com/help/images/ref/imguidedfilter.html>
     - <http://kaiminghe.com/eccv10/>

### Vessel Analysis

Performs vessel detection, and extracts location, diameter, direction of the vessels and many more useful parameters (see Parameters list below). Vessel analysis is based in large parts on the excelent [ARIA (Automated Retinal Image Analyzer)](https://github.com/petebankhead/ARIA
) algorithm developed by [Pete Bankhead](https://petebankhead.github.io/). It is explained in detail at:

[Bankhead P, Scholfield CN, McGeown JG, Curtis TM (2012)
*Fast Retinal Vessel Detection and Measurement Using Wavelets and Edge Location Refinement.*
PLoS ONE 7(3): e32435. doi:10.1371/journal.pone.0032435](http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0032435)

Noteworthy changes were made in the pre-processing where we don't use Wavelet filtering but rather rely on our onw pre-processing or a Frangi-Filtering processing prior to the binarization step. The binarization is also much more powerfull now and we export many more parameters which are calculate based on what the ARIA algorithm found.

#### Nomenclature
![Suppl_Figure_x_4_1](https://user-images.githubusercontent.com/558053/87024361-4b15b800-c1d9-11ea-8eeb-fba63c0b9a4f.jpg)
This figure should help to explain what we call a vessel, a branch point and a vessel segment. In short, vessels are defined between two branch points and we use a spline fit with an arbitrary number of segments for this fit. 

For each vessel we have: 
- length (length of spline) 
- distance between end-points 
- turtosity 

For each branch point we have: 
- location segment (points) 

For each segment we have 
- location 
- diameter 
- angle

#### Processing Steps
- Binarization
- Cleaning and Thinnging
- Skeletonization
- Spline-Fitting
- Width 




#### Parameters

- **min obj size**
  - the minimum size an object needs to exceed in order to be kept
  - defined as number of pixels
- **fill hole size**
  - minimum size of a 'hole' (i.e. an undetected region entirely surrounded by detected pixels)
  - defined as number of pixels
  - smaller holes will be filled in
- **min spur length**
  - length of spurs that should be removed from the thinned vessel centrelines
  - spurs are offshoots from the centreline, thus they cause branches - which can lead to vessels being erroneously sub-divided
  - On the other hand, some spurs can really be the result of actual vessel branches - and should probably be kept.
  - parameter is a length (in pixels) that a spur must exceed for it % to be kept (Default = 10).
- **clear near branch**
  - TRUE if centre lines should be shortened approaching branch points, so that any pixel is removed from the centre line if it is closer to the branch than to the background (i.e. FALSE pixels in BW).
  - If measurements do not need to be made very close to branches (where they may be less accurate), this can give a cleaner result
- **min spline length**
  - The minimum length of a vessel segment centre line for it to be kept. Must be >= 3 because of need for angles.
  - The spur removal will only get rid of terminal segments, but very short segments might remain between branches, in which case this parameter becomes relevant.
- **remove fat vessels**
  - remove vessels with diameter greater than the number of pixels in their centreline.
  - Such segments are usually not measureable vessels.
  - Keeping them can have a disproportionate effect upon processing time, because longer image profiles need to be computed for every vessel just to make sure that enough pixels are included for these extreme segements
- **spline smoothness**
  - The approximate spacing that should occur between spline pieces (in pixels)
  - A higher value implies fewer pieces, and therefore a smoother spline fit
- **smooth parallel & smooth perpend**
  - scaling parameters that multiply the estimate width computed for the vessel under consideration to determine how much smoothing is applied
  - SMOOTH_PARALLEL/PERPENDICULAR is multiplied by the width, and the square root of the result gives the sigma for the Gaussian filter
  - Although not essential, SMOOTH_SCALE_PERPENDICULAR should be >= SMOOTH_SCALE_PARALLEL
- **force connectivity**
  - TRUE if all pixels along the vessel edge should be connected to one another, i.e. within a distance of approximately one pixel from one another, FALSE otherwise.
  - Setting this to TRUE can improve the results by reducing the risk that the edges of neighbouring structures or the central light reflex are erroneously linked to the vessel, but in some images it might cause even vessels that appear clearly visible to be missed because their edge (as determined by the algorithm) is too variable or fragmented

#### Variable description

- area: full area of the wound /non wound region 
- growthArea: area of wound region where vessels are growing, for non-wounded regions area = growthArea, for wounded regions, growthArea is smaller than area
- nBranches: number of overall branch points
- nVessel: number of vessels
- nSegments: number of vessel segments
- branchDensity: branch points per area
- vesselDensity: vessels per area
- totalLength: sum of the length of all vessels
- lengthFraction: ratio of totalLength to area, smaller values mean less vessel coverage
- vesselGrowthDensity: vessels per growthArea (bigger or equal to vesselDensity)
- branchGrowthDensity: branch points per growthArea
- lengthGrowthFraction:  ratio of totalLength to growthArea, smaller values mean less vessel coverage
- meanDiameter: average diameter of all vessels segments
- meanLength: average length of all vessels
- meanTurtosity: average turtosity of all vessels
- meanCtrAngle: average deviation of vessel segment angle with respect to angle pointing at the wound center
- medianDiameter: median diameter of all vessels segments
- medianLength: median length of all vessels
- medianTurtosity: median turtosity of all vessels
- medianCtrAngle: median deviation of vessel segment angle with respect to angle pointing at the wound center

## ToDos

- optimize unsharp masking or get rid of it, find better sharping tools?

## Acknowledgement

- icons used troughout GUI from [FontAwesome](<https://fontawesome.com/license/free>) under CC BY 4.0 license
