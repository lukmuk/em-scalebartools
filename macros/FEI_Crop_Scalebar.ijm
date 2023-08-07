/*
IMPORTANT: This macro is meant to be used together with the "EMScaleBarTools.ijm" toolset.

EMScaleBarTools is a suite of small functions to add a scale bar with reasonable size to a scaled image.
It was developed with electron microscopy in mind and therefore the unit range spans (currently) from m to pm.

Installation:
1) Place "EMScaleBarTools.ijm" in Fiji -> macros -> toolsets folder.
2) Place "FEI_Crop_Scalebar.ijm" in Fiji -> macros folder.
3) Restart Fiji and select EMScaleBarTools from toolset (>>) menu.
4) For a help menu select the "?" button and enter the "Help" menu and/or visit the Github page.

* This code is under MIT licence.
* Author: Lukas Gruenewald, 08/2023, https://github.com/lukmuk/em-scalebartools

*/

//Get settings for scale bar
hfac = call("ij.Prefs.get", "sb.hfac", 0.02); // default 0.02
sf = call("ij.Prefs.get", "sb.sf", 1); // default 1
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
use_angstrom = call("ij.Prefs.get", "sb.use_angstrom", true); //default true

auto_rescale = call("ij.Prefs.get", "sb.auto_rescale", false); //default false
rescale_target_px = call("ij.Prefs.get", "sb.rescale_target_px", 512); //default 512

doExtraSBvals = call("ij.Prefs.get", "sb.doExtraSBvals", false); //default false
extraSBvals = call("ij.Prefs.get", "sb.extraSBvals", "75,150"); // default "75,150"

//FEI CROP SCALEBAR
FEIaddSB = call("ij.Prefs.get", "sb.FEIaddSB", true); //default true
FEIdoCrop = call("ij.Prefs.get", "sb.FEIdoCrop", true); //default true
//FEIuseList = call("ij.Prefs.get", "sb.FEIuseList", false); //default false
FEIshowMeta = call("ij.Prefs.get", "sb.FEIshowMeta", false); //default false
FEIdoExtraCmd = call("ij.Prefs.get", "sb.FEIdoExtraCmd", false); //default false
FEIextraCmd = call("ij.Prefs.get", "sb.FEIextraCmd", "run('Enhance Contrast', 'saturated=0.35');"); //default "run('Enhance Contrast', 'saturated=0.35');"


if(FEIdoCrop) {
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
		Ext.getMetadataValue("[Scan] PixelHeight", VerPixelsize); //in m
		Ext.getMetadataValue("[Scan] VerFieldsize", VerFieldsize); //in m

		// Crop based on microscope type
		w=getWidth();
		
		// Crop
		run("Specify...", "width=w height="+round(VerFieldsize/VerPixelsize)+" x=0 y=0");
		run("Crop");
}

//Scale with "EM tool" script by IMBalENce
//https://imagej.net/plugins/imbalence
run("SEM FEI metadata Scale");

//Optionally close log window with metadata
if(FEIshowMeta == false) {
	selectWindow("Log");
	run("Close");
}

// Add the scale bar
if(FEIaddSB) addScalebar();





// --------------------------------------------- //
// ----------------- FUNCTIONS ----------------- //
// --------------------------------------------- //

function addScalebar() {
	/* 
	Function to calculate size and position of a scale bar.
	Adds it to the currently selected image.
	*/
	
	
	// Check if any image is present. If not, exit function by returning 0
	if(nImages==0) return 0

	// Get current parameter values which may be changed by other functions
	sf = parseFloat(call("ij.Prefs.get", "sb.sf", 1));
	loc = call("ij.Prefs.get", "sb.loc", "Lower Right");
	switched = call("ij.Prefs.get", "sb.switched", false);
	if(switched) run("Remove Overlay");
	
	// Auto rescale images below rescale_target_px
	if(auto_rescale && (getWidth() < rescale_target_px || getHeight() < rescale_target_px)) {
		w = getWidth();
		h = getHeight();
		facw = Math.ceil(rescale_target_px/w);
		fach = Math.ceil(rescale_target_px/h);

		// Handle stacks, i.e. add scale bar to all images in a stack
		d = 1;
		if(nSlices > 1) d = nSlices;
		
		if(facw >= fach) {
			run("Scale...", "x="+facw+" y="+facw+" width="+(facw*w)+" height="+(facw*h)+" depth="+d+" interpolation=None average process create");
		}
		else {
			run("Scale...", "x="+fach+" y="+fach+" width="+(fach*w)+" height="+(fach*h)+" depth="+d+" interpolation=None average process create");
		}
		
	}

	// Switch length units
	if(auto_unit_switching) UnitSwitcher(auto_unit_ref);

	//Run extra commands
	if (FEIdoExtraCmd) eval(FEIextraCmd);

	// Calculate height in pixels of scale bar
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

	// Multiply height with scaling factor
	height = height * sf;

	// Calculate fontsize
	fontsize = height * fsfac;

	// Calculate scale-bar size using a 1-2-5 series
	// Code by Ales Kladnik (aleskl)  
	
	getPixelSize(unit,w_px,h_px);
	imw = w_px*getWidth(); // image width in measurement units
	
	scalebarlen = 0.01*imw; // initial scale bar length in measurement units
	maxscalebarlen = imw * wfac; // maximum scale bar width in measurement units
	
	// recursively calculate a 1-2-5 series until the length reaches scalebarsize, default to 1/10th of image width
	// 1-2-5 series is calculated by repeated multiplication with 2.3, rounded to one significant digit
	while (scalebarlen < maxscalebarlen) {
		scalebarlen = round((scalebarlen*2.3)/(Math.pow(10,(floor(Math.log10(abs(scalebarlen*2.3)))))))*(Math.pow(10,(floor(Math.log10(abs(scalebarlen*2.3))))));
	}
	
	// Check for possible rounding errors
	if(scalebarlen < 1)  {
		print("Scale bar length in physical units < 1 unit. Possible rounding error.");
		print("Please DOUBLE-CHECK SCALE BAR LENGTH!");
		print("Doubling scale bar length until it is at least 1 unit.");
		print("Before: ", scalebarlen);
		while(scalebarlen < 1) scalebarlen *= 2;
		print("After: ", scalebarlen);
	}

	// Update len variable with found scale-bar length, required for other macros
	call("ij.Prefs.set", "sb.len", scalebarlen);
	call("ij.Prefs.set", "sb.height", height); 
	call("ij.Prefs.set", "sb.fontsize", fontsize); 

	// Other cosmetics
	b=""; //bold
	o=""; //overlay
	h=""; //hide text
	s=""; //serif font
	if(bold) b="bold";
	if(overlay) o="overlay";
	if(hide) h="hide";
	if(serif) s="serif";
	
	// Run ImageJ scale-bar command
	run("Scale Bar...", "width="+scalebarlen+" height="+height+" font="+fontsize+" color="+col+" background="+bgcol+" location=["+loc+"] "+b+" "+h+" "+s+" "+o);
	
	// Flip vertical positions of scale bar and the label
	if(switched) switchScaleBarLabel();
	
	// Hide label
	if(hide) {
		if(auto_rescale) name = getTitle();
		run("Duplicate...", "title="+substring(getTitle(), 0, lastIndexOf(getTitle(), '.'))+"_scale-"+vals[index]+unit+".tif");
		if(auto_rescale) close(name);
	}
}



function UnitSwitcher(auto_unit_ref) {
	/* 
	Function to switch the length units automatically. The value of auto_unit_ref is used to decide when to switch.
	E.g. auto_unit_ref = 3 will switch images with a width of >3000 nm to um, or images with a width of <3 um to nm.
	*/
	
	// Get scaled image size
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

	if(use_angstrom) {
	//nm -> Angstrom
	if(val <= U && (unit == "nm")){
		setVoxelSize(1E+1*pw, 1E+1*ph, 1, fromCharCode(0x0212b));
		getPixelSize(unit, pw, ph);
		if(auto_unit_ref == "Width") {val = getWidth()*pw;}
		if(auto_unit_ref == "Height") {val = getHeight()*pw;}
		if(auto_unit_ref == "Both") {
		if(getWidth()*pw <= getHeight()*pw) {val = getWidth()*pw;}
		else {val = getHeight()*pw;}
		}
	}

	//Angstrom -> pm
	if(val <= U && (unit == fromCharCode(0x0212b))){
		setVoxelSize(1E+2*pw, 1E+2*ph, 1, "pm");
		getPixelSize(unit, pw, ph);
		if(auto_unit_ref == "Width") {val = getWidth()*pw;}
		if(auto_unit_ref == "Height") {val = getHeight()*pw;}
		if(auto_unit_ref == "Both") {
		if(getWidth()*pw <= getHeight()*pw) {val = getWidth()*pw;}
		else {val = getHeight()*pw;}
		}
	}
	}

	if(use_angstrom == false) {
	//nm -> pm
	if(val <= U && (unit == "nm")){
		setVoxelSize(1E+3*pw, 1E+3*ph, 1, "pm");
		getPixelSize(unit, pw, ph);
		if(auto_unit_ref == "Width") {val = getWidth()*pw;}
		if(auto_unit_ref == "Height") {val = getHeight()*pw;}
		if(auto_unit_ref == "Both") {
		if(getWidth()*pw <= getHeight()*pw) {val = getWidth()*pw;}
		else {val = getHeight()*pw;}
		}
	}
	}
	

	// Other direction starts from here
	if(use_angstrom == false) {
	//pm -> nm
	if(val >= U*1e3 && (unit == "pm")){
		setVoxelSize(1E-3*pw, 1E-3*ph, 1, "nm");
		getPixelSize(unit, pw, ph);
		if(auto_unit_ref == "Width") {val = getWidth()*pw;}
		if(auto_unit_ref == "Height") {val = getHeight()*pw;}
		if(auto_unit_ref == "Both") {
		if(getWidth()*pw <= getHeight()*pw) {val = getWidth()*pw;}
		else {val = getHeight()*pw;}
		}
	}
	}

	if(use_angstrom) {
	//pm -> Angstrom
	if(val >= U*1e2 && (unit == "pm")) {
		setVoxelSize(1E-2*pw, 1E-2*ph, 1, fromCharCode(0x0212b));
		getPixelSize(unit, pw, ph);
		if(auto_unit_ref == "Width") {val = getWidth()*pw;}
		if(auto_unit_ref == "Height") {val = getHeight()*pw;}
		if(auto_unit_ref == "Both") {
		if(getWidth()*pw <= getHeight()*pw) {val = getWidth()*pw;}
		else {val = getHeight()*pw;}
		}
	}
	
	//Angstrom -> nm
	if(val >= U*1e1 && (unit == fromCharCode(0x0212b))) {
		setVoxelSize(1E-1*pw, 1E-1*ph, 1, "nm");
		getPixelSize(unit, pw, ph);
		if(auto_unit_ref == "Width") {val = getWidth()*pw;}
		if(auto_unit_ref == "Height") {val = getHeight()*pw;}
		if(auto_unit_ref == "Both") {
		if(getWidth()*pw <= getHeight()*pw) {val = getWidth()*pw;}
		else {val = getHeight()*pw;}
		}
	}
	}
	
	//nm -> µm
	if(val >= U*1e3 && (unit == "nm")){
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
	if(val >= U*1e3 && (unit == "mm")){
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
