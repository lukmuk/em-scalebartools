/*
IMPORTANT: This macro is meant to be used together with the "EMScaleBarTools.ijm" toolset.
EMScaleBarTools is a suite of small functions to add a scale bar with reasonable size to a scaled image.
It was developed with electron microscopy in mind and therefore the unit range spans (currently) only from m to pm.

Installtion:
1) Place "EMScaleBarTools.ijm" in Fiji -> macros -> toolsets folder.
2) Place "FEI_Crop_Scalebar.ijm" in Fiji -> macros folder.
3) Restart Fiji and select EMScaleBarTools from toolset >> menu.

The following macros are available as buttons:
* QuickScaleBar (with right-click option menu): Add a scale bar to a scaled image. 
* FEI Crop Scalebar: Crop FEI/TFS infobar at the bottom of the image, optionally perform image operations, and add a scale bar.
	   Standalone macro to allow for batch processing.
* Move Overlays: Drag and drop for overlays, directly copied from: https://imagej.nih.gov/ij/source/macros/Overlay%20Editing%20Tools.txt
* Remove Overlays: Remove all overlays (i.e. scale bars)
* ?: Opens help dialog.

* This code is under MIT licence.
* Author: lukmuk, 09/2021, https://github.com/lukmuk/em-scalebartools

*/

//Get settings for scale bar
hfac = call("ij.Prefs.get", "sb.hfac", 0.02); // default 0.02
wfac = call("ij.Prefs.get", "sb.wfac", 0.2);  // default 0.2
fsfac = call("ij.Prefs.get", "sb.fsfac", 3);  // default 3
col = call("ij.Prefs.get", "sb.col", "Black");  // default "Black"
bgcol = call("ij.Prefs.get", "sb.bg", "White");  // default "White"
loc = call("ij.Prefs.get", "sb.loc", "Lower Right");  // default "Lower Right"

bold = call("ij.Prefs.get", "sb.bold", true); //default true
overlay = call("ij.Prefs.get", "sb.overlay", true); //default true
hide = call("ij.Prefs.get", "sb.hide", false); //default false
serif = call("ij.Prefs.get", "sb.serif", false); //default false

sb_size_ref = call("ij.Prefs.get", "sb.sb_size_ref", "Larger");

auto_unit_switching = call("ij.Prefs.get", "sb.auto_unit_switching", true); //default true
auto_unit_ref = call("ij.Prefs.get", "sb.auto_unit_ref", "Width");
U = call("ij.Prefs.get", "sb.U", 3); // default 3

auto_rescale = call("ij.Prefs.get", "sb.auto_rescale", false); //default false
rescale_target_px = call("ij.Prefs.get", "sb.rescale_target_px", 512); //default 512

//FEI CROP SCALEBAR
FEIdoCrop = call("ij.Prefs.get", "sb.FEIdoCrop", true); //default true
FEIshowMeta = call("ij.Prefs.get", "sb.FEIshowMeta", false); //default false
FEIdoExtraCmd = call("ij.Prefs.get", "sb.FEIdoExtraCmd", false); //default false
FEIextraCmd = call("ij.Prefs.get", "sb.FEIextraCmd", "run('Enhance Contrast', 'saturated=0.35');"); //default "run('Enhance Contrast', 'saturated=0.35');"


if(FEIdoCrop) {
	//Get microscope info
	// Taken from https://github.com/IMBalENce/EM-tool/blob/master/SEM_FEI_metadata_Scale.ijm
	run("Bio-Formats Macro Extensions");
	path = getDirectory("image");
	if (path=="") exit ("path not available");
	name = getInfo("image.filename");
	if (name=="") exit ("name not available");
	id = path + name;
	Ext.setId(id);
	Ext.getSeriesCount(seriesCount);
	
	// Determine which microscope is used, can be expanded to accommondate more types
	Ext.getMetadataValue("[System] SystemType", SystemType);

	// Crop based on microscope type
	w=getWidth();
	h=getHeight();
	
	//HELIOS
	//Crop FEI infobar, which for HELIOS is the rest between the image 
	//height in pixels and the next smaller power of 2
	if(SystemType == "Helios G4 FX") {
		c = pow(2, floor(log(h)/log(2)));
		run("Specify...", "width=w height="+c+" x=0 y=0");
		run("Crop");
	}
	
	//STRATA and ESEM/Quanta
	//For Strata, the crop values are listed in the "heights" array
	if(SystemType == "Strata DB" || SystemType == "Quanta FEG") {
		heights = newArray(443 , 884, 884*2, 884*4);
		jndex = 0;
		for (j=0; j<heights.length; j++)
			if(h > heights[j])
				jndex = j;
				continue;
			break;
		run("Specify...", "width=w height="+heights[jndex]+" x=0 y=0");
		run("Crop");
	}
}

//Scale with "EM tool" script by IMBalENce
//https://imagej.net/plugins/imbalence
run("SEM FEI metadata Scale");

// Add the scale bar
addScalebar();

//Optionally close log window with metadata
if(FEIshowMeta == false) {
	selectWindow("Log");
	run("Close");
}


// --------------------------------------------- //
// ----------------- FUNCTIONS ----------------- //
// --------------------------------------------- //

function addScalebar() {
	//Auto rescale images below rescale_target_px
	if(auto_rescale && (getWidth() < rescale_target_px || getHeight() < rescale_target_px)) {
		w = getWidth();
		h = getHeight();
		facw = Math.ceil(rescale_target_px/w);
		fach = Math.ceil(rescale_target_px/h);
		if(facw >= fach) {
			run("Scale...", "x="+facw+" y="+facw+" width="+(facw*w)+" height="+(facw*h)+" interpolation=None average create");
		}
		else {
			run("Scale...", "x="+fach+" y="+fach+" width="+(fach*w)+" height="+(fach*h)+" interpolation=None average create");
		}
		
	}

	//Switch units
	if(auto_unit_switching) unit_switcher(auto_unit_ref);

	//Run extra commands
	if (FEIdoExtraCmd) eval(FEIextraCmd);

	//Calculate height of scalebar
	if(sb_size_ref == "Larger") {
		if(getHeight() >= getWidth()) {height = round(getHeight()*hfac);}
		else {height = round(getWidth()*hfac);}
	}
	if(sb_size_ref == "Smaller") {
		if(getHeight() >= getWidth()) {height = round(getWidth()*hfac);}
		else {height = round(getHeight()*hfac);}
	}
	if(sb_size_ref == "Width") height = round(getWidth()*hfac);
	if(sb_size_ref == "Height") height = round(getHeight()*hfac);

	//Calculate fontsize
	fontsize = height * fsfac;
	
	//Set width of scalebar
	//Searches closest value from vals array to find sb width
	if(auto_unit_switching) {
		vals = newArray(1, 2, 5, 10, 20, 50, 100, 200, 250, 500, 1000, 2000, 5000, 10000);
	}
	else {
		vals = newArray(0.01, 0.02, 0.025, 0.05, 0.1, 0.2, 0.25, 0.5, 1, 2, 5, 10, 20, 50, 100, 200, 250, 500, 1000, 2000, 5000, 10000);
	}
	//Get initial size of scalebar as percentage of image width
	getPixelSize(unit, pw, ph);
	imw = getWidth()*pw;
	sb_w = round(wfac*imw);
	
	//Find next smaller value to sb_w in vals
	index = 0;
	for (i=0; i<vals.length; i++)
		if(sb_w > vals[i])
			index = i;
			continue;
		break;

	//Other cosmetics
	b=""; //bold
	o=""; //overlay
	h=""; //hide text
	s=""; //serif font
	if(bold) b="bold";
	if(overlay) o="overlay";
	if(hide) h="hide";
	if(serif) s="serif";
	
	//Run scale bar command
	run("Scale Bar...", "width="+vals[index]+" height="+height+" font="+fontsize+" color="+col+" background="+bgcol+" location=["+loc+"] "+b+" "+h+" "+s+" "+o);
	if(hide) {
		if(auto_rescale) name = getTitle();
		run("Duplicate...", "title="+substring(getTitle(), 0, lastIndexOf(getTitle(), '.'))+"_scale-"+vals[index]+unit+".tif");
		if(auto_rescale) close(name);
	}
}

function unit_switcher(auto_unit_ref) {
	//Get scaled image size
	getPixelSize(unit, pw, ph);
	if(auto_unit_ref == "Width") {val = getWidth()*pw;}
	if(auto_unit_ref == "Height") {val = getHeight()*pw;}
	if(auto_unit_ref == "Both") {
		if(getWidth()*pw <= getHeight()*pw) {val = getWidth()*pw;}
		else {val = getHeight()*pw;}
	}

	//m -> mm 
	if(val <= U && unit == "m"){
		setVoxelSize(1E3*pw, 1E3*ph, 1, 'mm');
		getPixelSize(unit, pw, ph);
		if(auto_unit_ref == "Width") {val = getWidth()*pw;}
		if(auto_unit_ref == "Height") {val = getHeight()*pw;}
		if(auto_unit_ref == "Both") {
		if(getWidth()*pw <= getHeight()*pw) {val = getWidth()*pw;}
		else {val = getHeight()*pw;}
		}
	}

	//mm -> µm 
	if(val <= U && unit == "mm"){
		setVoxelSize(1E3*pw, 1E3*ph, 1, fromCharCode(0181)+'m');
		getPixelSize(unit, pw, ph);
		if(auto_unit_ref == "Width") {val = getWidth()*pw;}
		if(auto_unit_ref == "Height") {val = getHeight()*pw;}
		if(auto_unit_ref == "Both") {
		if(getWidth()*pw <= getHeight()*pw) {val = getWidth()*pw;}
		else {val = getHeight()*pw;}
		}
	}
	
	//µm -> nm 
	if(val <= U && (unit == fromCharCode(0181)+'m' || unit == "microns")){
		setVoxelSize(1E3*pw, 1E3*ph, 1, "nm");
		getPixelSize(unit, pw, ph);
		if(auto_unit_ref == "Width") {val = getWidth()*pw;}
		if(auto_unit_ref == "Height") {val = getHeight()*pw;}
		if(auto_unit_ref == "Both") {
		if(getWidth()*pw <= getHeight()*pw) {val = getWidth()*pw;}
		else {val = getHeight()*pw;}
		}
	}
	
	//nm -> Angstrom
	if(val <= U && (unit == 'nm')){
		setVoxelSize(1E+1*pw, 1E+1*ph, 1, fromCharCode(0x0212b));
		getPixelSize(unit, pw, ph);
		if(auto_unit_ref == "Width") {val = getWidth()*pw;}
		if(auto_unit_ref == "Height") {val = getHeight()*pw;}
		if(auto_unit_ref == "Both") {
		if(getWidth()*pw <= getHeight()*pw) {val = getWidth()*pw;}
		else {val = getHeight()*pw;}
		}
	}
	
	//Other direction starts from here
	
	//Angstrom -> nm
	if(val >= U*1e1 && (unit == fromCharCode(0x0212b))) {
		setVoxelSize(1E-1*pw, 1E-1*ph, 1, 'nm');
		getPixelSize(unit, pw, ph);
		if(auto_unit_ref == "Width") {val = getWidth()*pw;}
		if(auto_unit_ref == "Height") {val = getHeight()*pw;}
		if(auto_unit_ref == "Both") {
		if(getWidth()*pw <= getHeight()*pw) {val = getWidth()*pw;}
		else {val = getHeight()*pw;}
		}
	}
	
	//nm -> µm
	if(val >= U*1e3 && (unit == 'nm')){
		setVoxelSize(1E-3*pw, 1E-3*ph, 1, fromCharCode(0181)+'m');
		getPixelSize(unit, pw, ph);
		if(auto_unit_ref == "Width") {val = getWidth()*pw;}
		if(auto_unit_ref == "Height") {val = getHeight()*pw;}
		if(auto_unit_ref == "Both") {
		if(getWidth()*pw <= getHeight()*pw) {val = getWidth()*pw;}
		else {val = getHeight()*pw;}
		}
	}
	
	//µm -> mm
	if(val >= U*1e3 && (unit == fromCharCode(0181)+'m' || unit == "microns")){
		setVoxelSize(1E-3*pw, 1E-3*ph, 1, 'mm');
		getPixelSize(unit, pw, ph);
		if(auto_unit_ref == "Width") {val = getWidth()*pw;}
		if(auto_unit_ref == "Height") {val = getHeight()*pw;}
		if(auto_unit_ref == "Both") {
		if(getWidth()*pw <= getHeight()*pw) {val = getWidth()*pw;}
		else {val = getHeight()*pw;}
		}
	}
		
	//mm -> m
	if(val >= U*1e3 && (unit == 'mm')){
		setVoxelSize(1E-3*pw, 1E-3*ph, 1, 'm');
		getPixelSize(unit, pw, ph);
		if(auto_unit_ref == "Width") {val = getWidth()*pw;}
		if(auto_unit_ref == "Height") {val = getHeight()*pw;}
		if(auto_unit_ref == "Both") {
		if(getWidth()*pw <= getHeight()*pw) {val = getWidth()*pw;}
		else {val = getHeight()*pw;}
		}
	}
}