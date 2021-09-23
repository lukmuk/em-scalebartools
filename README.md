# em-scalebartools

Fiji macro toolset to quickly add a scale bar with reasonable size to an image. Developed for electron microscopy.

## Examples

Using QuickScaleBar on a HRTEM image. Note the similar size of the scale bars for the 4096²  image (center) and the cropped 512² ROI image (right).

<img title="Example 0" src="images/example0.png" alt="Example" data-align="center">

Using FEI Crop Scalebar on an SEM image.

<img title="Example 1" src="images/example1.png" alt="Example" data-align="center">

Batch conversion of SEM images (``Process -> Batch -> Macro...``) from tiff to png using ``FEI_Crop_Scalebar.ijm``.

<img title="Example 1" src="images/example2.png" alt="Example" data-align="center">

## Macro description

##### QuickScaleBar Tool (Icon: <u>SB</u>)

* One-click action to add a scale bar to an image.

* The scale bar height and font size is adjusted based on image height.

* The scale bar width is adjusted based on scaled image width and rounded to next "good looking" number.

* Will automatically switch units to make scale bar more appealing: E.g. an image with horizontal field width of 0.25 µm will be switched to 250 nm. The scale bar will then also be in nm.

##### FEI Crop Scalebar Tool (Icon: FEI)

* One-click action to crop away the databar from an FEI/TFS SEM/FIB image and to add a scale bar.

* Scale bar behaviour is the same as for QuickScaleBar tool.

* Other image operations can be specified in the script (`process_image()` function). By default a simple "Auto Contrast/Brightness" contrast stretching is run.

* Especially useful for batch conversion of SEM/FIB images (run from `Process->Batch->Macro...` )

* **Note:** The boundaries for the cropping area **depend on the microscope system type** because older FIB/SEMs use a nearly quadratic image format whereas modern microscope use landscape mode by default. You may need to adjust the microscope list once in the macro for your SEM, see instructions below. 

* 

##### Edit ScaleBarTools macros... Tool (Icon: ?)

* Opens the Fiji code editor to quickly edit the macros for future use.

* Adjust the scalebar looks here and add fancy image operations for the FEI Crop Scalebar Tool!

## Requirements and Installation

* Requires the useful [EM tool](https://imagej.net/plugins/imbalence) plugin by **IMBalENce**  as FEI/TFS images are scaled with [SEM FEI metadata scale](https://imagej.net/plugins/sem-fei-metadata-scale). Install via the Fiji update site.

* Download the latest [release](https://github.com/lukmuk/em-scalebartools/releases), extract the `macros` folder, and copy it to your Fiji installation folder. It will add the `QuickScaleTools.ijm` and `FEI_Crop_Scalebar.ijm` macros to the macros folder and the `ScaleBarTools.ijm` toolset to the `macros/toolset` folder.

* Restart Fiji and select the `ScaleBarTools` from `More Tools...` (>>) menu. 

##### Add a new microscope system type

Currently, only the system types `Helios G4 FX`, `Strata DB`, and `Quanta FEG` are implemented in `FEI Crop Scalebar`. You can add others in the following way:

- Open a SEM/FIB image of your FEI/TFS machine.

- Run ``EM tool->SEM FEI metadata scale`` and check the Log window for the system type:  ``[System] SystemType : ScopeName`` 

- For images of different size (e.g. 4096 by Y, 2048 by Y, 1024 by Y, ...) check the cut-off point (pixel) between the image and the databar (zoom in). Add a new ``if`` clause to the macro similar to the ones already in the macro (starting with ``if(SystemType == ScopeName)``. E.g., for newer systems (`Helios G4 FX`) the cut-off is a power of two (512, 1024, ...) but for older scopes (such as ``Strata DB``) the values are more 'random' and you can simply specify a list with the cut-off values for different image sizes.

## A short code documentation

Warning: Code is not optimized in any way, but should work (?). :-) 

###### Scalebar looks:

``sb_hfac``: Height of scale bar wrt image height in pixel (default: ``0.02``, 2% of image height)

`sb_wfac`: Width of scale bar wrt image width (default: `0.2`, 20% of image width), will get rounded to next smaller "nice" value, see (``vals`` array in the code).

`sb_fsfac`: Font size wrt `sb_hfac` (default: `2`, double of point size of scale bar height).

`sb_col`: Font size color (default: ``'Black'``).

`sb_bg`: Background color (default: `'White'`). Use ``'None'`` to remove background.

``sb_loc``: Location/position of scale bar (default: ``'Lower Right'``).

``U``: Unit switching factor (default: ``3``). Example: Will switch from µm to nm if image width is below 3 µm. Will switch from nm to µm if image width is larger than 3000 nm.

###### QuickScaleBar

``auto_rescale``: If true/1, automatically rescale (using no interpolation/nearest interpolation) small image width or height to at least ``rescale_target_px`` value. (default: ``0``, false). Useful to resize small cropped areas of larger images. This is the same as using ``CTRL+E`` and rescaling with ``Interpolation: None``.

`rescale_target_px`: Target minimum pixel size for ``auto_rescale``.  (default: ``800``)

###### FEI Crop Scalebar

``function process_image()``: Add image processing here, especially useful for batch conversion. (default: Auto C/B, i.e. ``run("Enhance Contrast", "saturated=0.35")``)

## Other useful scalebar tools

* Python: [matplotlib-scalebar](https://github.com/ppinard/matplotlib-scalebar) by ppinard

* DM/GMS: [Scale Bar Control](http://www.dmscripting.com/scalebarcontrol.html) by D. R. G. Mitchell

* Fiji/ImageJ: [asc-ImageJ-Fancy-Labels](https://github.com/peterjlee/asc-ImageJ-Fancy-Labels) by peterjlee
