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

* One-click action to add a scale bar to an image. Right click opens the options menu.

* The scale bar height and font size is adjusted based on image height (or width).

* The scale bar width is adjusted based on scaled image width (or height, or larger/smaller of the two) and rounded to next "good looking" number.

* The scale bar appearance can be set up just like the normal settings for `Analyze -> Tools -> Scale bar...`.

* Optional: Automatically switch units to make scale bar more appealing. E.g., an image with horizontal field width of 0.25 µm will be switched to 250 nm. The scale bar will then also be in nm.

* Optional: Automatically re-scale image to (at least) a specified image size in pixels without interpolation (= nearest neighbor interpolation). This is convenient for programs like PowerPoint which like to automatically interpolate "small" images.

* Optional: Run custom macro commands provided in the options menu, e.g. `run('mpl-viridis');` to change LUT to viridis.

##### FEI Crop Scalebar Tool (Icon: FEI)

* One-click action to crop away the databar from an FEI/TFS SEM/FIB image and to add a scale bar. Right click opens the options menu.

* Scale bar behaviour is the same as for QuickScaleBar tool and settings are taken from the QuickScaleBar options.

* Optional: Run custom macro commands provided in the options menu, e.g. `run('mpl-viridis');` to change LUT to viridis.

* Especially useful for batch conversion of SEM/FIB images (run from `Process -> Batch -> Macro...` ): In the batch processing menu insert the macro command `runMacro('FEI_Crop_Scalebar.ijm');`.

##### Move Overlays Tool (Circle icon)

* Move around scale bar for fine tuning of the position. Will anchor to special positions for easier alignment.

* Taken from: [Overlay Editing Tools](https://imagej.nih.gov/ij/source/macros/Overlay%20Editing%20Tools.txt)

##### Remove Overlays Tool (x icon)

* Remove all overlays including the scale bar.

##### Misc. Functions (Icon: ?)

* `Set pixel size and unit`: Change image scale and unit. Default values are fetched from the selected image. You can then specify the values directly. For the unit, you can also choose from a list of special units for electron microscopy from the `Use special unit` menu. The latter do not shown on my Windows system, but on Linux. Currently in the list: Å, Å$^{-1}$ , and nm$^{-1}$ .
* `Help`: Opens the help menu.

## Requirements and Installation

* Cropping the FEI/TFS info bar requires the useful [EM tool](https://imagej.net/plugins/imbalence) plugin by **IMBalENce**  as FEI/TFS images are scaled with [SEM FEI metadata scale](https://imagej.net/plugins/sem-fei-metadata-scale). Install via the Fiji update site.

* Download the latest [release](https://github.com/lukmuk/em-scalebartools/releases), extract the `macros` folder, and copy it to your Fiji installation folder. It will add the``FEI_Crop_Scalebar.ijm`` macro to the macros folder and the `EMScaleBarTools.ijm` toolset to the `macros/toolset` folder.

* Restart Fiji and select the `EMScaleBarTools` from `More Tools...` (>>) menu. 

##### Add a new microscope system type

**Important: Should not be required for version 0.21 and higher. The cropping value will be determined automatically based on the extracted metadata.**

Currently, only the system types `Helios G4 FX`, `Strata DB`, and `Quanta FEG` are implemented in `FEI Crop Scalebar`. You can add others in the following way:

- Open a SEM/FIB image of your FEI/TFS machine.

- Run ``EM tool->SEM FEI metadata scale`` and check the Log window for the system type:  ``[System] SystemType : ScopeName`` 

- For images of different size (e.g. 4096 by Y, 2048 by Y, 1024 by Y, ...) check the cut-off point (pixel) between the image and the databar (zoom in). Add a new ``if`` clause to the macro similar to the ones already in the macro (starting with ``if(SystemType == ScopeName)``. E.g., for newer systems (`Helios G4 FX`) the cut-off is a power of two (512, 1024, ...) but for older scopes (such as ``Strata DB``) the values are more 'random' and you can simply specify a list with the cut-off values for different image sizes.

## A short code documentation

Warning: Code is not optimized in any way, but should work (?). :-) 

###### QuickScaleBar Options

``Relative height``: Height of scale bar wrt image height in pixel (default: ``0.02``, 2% of image height)

`Scaling factor`: Additional scaling factor that is multiplied with `Relative height` (default: `1`). Useful to quickly adjust scale-bar size by a scaling factor.

`Relative width`: Width of scale bar with respect to  `Scalebar size reference`option (default: `0.2`, 20% of image width), will get rounded to next smaller "nice" value, see (``vals`` array in the code).

`Relative fontsize`: Font size wrt `Scalebar height` (default: `3`, point size of scale bar height).

`Scalebar color`: Font size color (default: ``'Black'``).

`Background color`: Background color (default: `'White'`). Use ``'None'`` to remove background.

``Scalebar location``: Location/position of scale bar (default: ``'Lower Right'``).

`Bold`: Bold font (default: `true`).

`Overlay`: Add scale bar as an overlay (default: `true`).

`Serif font`: Serif font (default: `false`).

`Hide`: Hide font, only plot scale bar (default: `false`). Will create a copy of the image with the scale-bar length in the title.

`Scalebar size reference`: Base scale bar size on width/height/smaller/larger edge of the image (default: `'Larger'`). You can adjust this for narrow images to modify scale bar appearance. Use `Height`/`Width` if you want to have identical scale bar sizes for images of same `Height`/`Width`.

`Auto unit-switching`: Automatically adjusts units between m and Å based on `Check`and `U` values. (default: `true`).

`(Auto unit-switching) Check`: Check width/height/both of image for unit switching (default: `'Width'`).

``U``: Unit switching factor (default: ``3``). Example: Will switch from µm to nm if image width is below 3 µm. Will switch from nm to µm if image width is larger than 3000 nm.

`Auto re-scale images`: If true/1, automatically rescale (using no interpolation/nearest interpolation) small image width or height to at least `rescale_target_px` value. (default: `0`, false). Useful to resize small cropped areas of larger images. This is the same as using `CTRL+E` and rescaling with `Interpolation: None`.

`rescale_target_px`: Target minimum pixel size for `auto_rescale`. (default: `512`)

`Run custom macro commands`: Run commands specified in next line (default: `false`). In the `Custom macro commands` field, multiple commands must be separated by `;`.

###### FEI Crop Scalebar Options

`Crop data bar`: Crop data bar of FEI/TFS image (default: `true`)

`Use list from code for cropping value (legacy option)`). Use list-based cropping value as in v0.2 and earlier. **Important: If your cropping does not work with the version 0.21 and higher, copy your determined cropping values into the new if-clause in the code and activate the aforementioned menu option.**

`Show metadata in log window`: Keep log window open or close it (default: `false`).

`Run custom macro commands`: Run commands specified in next line (default: `false`). In the `Custom macro commands` field, multiple commands must be separated by `;`.

###### Hotkeys:

[ j ] - Save image as jpeg. Prompts for quality/compression factor.

[ p ] - Save images as png.

[ c ] - Copy image to system clipboard.

## EMScaleBarTools in action

Examples are from v0.2.

Basic usage with cropping of a TFS/FEI databar, addition of a scale bar, moving and removing of the scale bar:
<img title="Basic usage" src="images/EMscalebartools_01.gif" alt="Example" data-align="center">

The next GIF shows the application of `Auto re-scale images` to upscale a small (in pixels) inset of an image:
<img title="Using Auto re-scale" src="images/EMscalebartools_02.gif" alt="Example" data-align="center">

The next GIF shows an example workflow when working with presentations (here Microsoft PowerPoint). For a horizontal alignment of images (here an SEM and an HAADF-STEM image) with the same desired image height, the scale bar reference is switched to `Height`. Note the automatic handling of unit-switching and rescaling as in the previous example. The image are then copied via the hotkey c to the system clipboard and pasted into PowerPoint.
<img title="Workflow for presentations" src="images/EMscalebartools_03.gif" alt="Example" data-align="center">

## Other useful scalebar tools

* Python: [matplotlib-scalebar](https://github.com/ppinard/matplotlib-scalebar) by ppinard

* DM/GMS: [Scale Bar Control](http://www.dmscripting.com/scalebarcontrol.html) by D. R. G. Mitchell

* Fiji/ImageJ: [asc-ImageJ-Fancy-Labels](https://github.com/peterjlee/asc-ImageJ-Fancy-Labels) by peterjlee

* Fiji/ImageJ: [Scale Bar Tools for Microscopes](http://image.bio.methods.free.fr/ImageJ/?Scale-Bar-Tools-for-Microscopes.html&lang=en) by Gilles Carpentier

## Changelog

### v0.21

* Rewrote ``FEI_crop_scalebar.ijm `` to crop the FEI/TFS info bar based on the `[Scan] VerFieldSize` and `[Scan]PixelHeight` values. This should make the cropping work for every FEI/TFS machine as long as both values are found in the tiff metadata.

* Added an legacy option to use "list-based" cropping as in the old v0.2 version in the `FEI_crop_scalebar.ijm` option menu (`Use list from code for cropping value (legacy option)`). **Important: If your cropping does not work with the new version, copy your determined cropping values into the new if-clause in the code and activate the aforementioned menu option.**

* The `Help` is now found in a new drop-down menu.

* A new function `Set pixel size and unit` was added to the drop-down menu. IT will fetch the values from the front-most image. You can then specify the values directly or use some special formats for electron microscopy from the `Use special unit`  menu. The latter do not shown on my Windows system, but on Linux. Currently in the list: Å, Å$^{-1}$, and nm$^{-1}$.

* Updated the readme.
  
  

### v0.2

* Renamed `ScaleBarTools.ijm` to `EMScaleBarTools.ijm` because there is also a plugin by [Gilles Carpentier](http://image.bio.methods.free.fr/ImageJ/?Scale-Bar-Tools-for-Microscopes.html&lang=en) with a similar name. Makes it clear that is meant for EM.

* Reorganization of the code: `QuickScaleBar.ijm` was merged into `EMScaleBarTools.ijm`. `FEI_Crop_Scalebar.ijm` is still a stand-alone macro for easier use with batch processing.

* Included option menus for some icon tools, which can be accessed by right-click. More convenient editing than in the source code.

* Options parameters are stored internally in java variables and saved for future sessions (`ij.get` and `ij.set` calls). I took inspiration from another toolsets macro: [Roi 1-click tools](https://imagej.net/plugins/roi-1-click-tools)

* Added more options for scale bar appearance (serif font, bold, hide, ...).

* Added two additional tools in the menu: Move Overlays and Remove Overlays for quick manipulation of the scale bar (which is often an overlay).
