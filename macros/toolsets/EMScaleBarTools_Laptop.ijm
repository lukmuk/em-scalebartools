/*
EMScaleBarTools is a suite of small functions to add a scale bar with reasonable size to a scaled image.
It was developed with electron microscopy in mind and therefore the unit range spans (currently) from m to pm.

Installation:
1) Place "EMScaleBarTools.ijm" in Fiji -> macros -> toolsets folder.
2) Place "FEI_Crop_Scalebar.ijm" in Fiji -> macros folder.
3) Restart Fiji and select EMScaleBarTools from toolset (>>) menu.
4) For a help menu select the "?" button and enter the "Help" menu and/or visit the Github page.

* This code is under MIT licence.
* Author: Lukas Gruenewald, https://github.com/lukmuk/em-scalebartools

*/

var date = "04/2025"
var version = 0.5.0

//Initialize scale-bar parameters
var hfac = call("ij.Prefs.get", "sb.hfac", 0.02); // default 0.02
var sf = call("ij.Prefs.get", "sb.sf", 1); // default 1
var wfac = call("ij.Prefs.get", "sb.wfac", 0.2);  // default 0.2
var fsfac = call("ij.Prefs.get", "sb.fsfac", 3);  // default 2
var col = call("ij.Prefs.get", "sb.col", "Black");  // default "Black"
var bgcol = call("ij.Prefs.get", "sb.bgcol", "None");  // default "None"
var loc = call("ij.Prefs.get", "sb.loc", "Lower Right");  // default "Lower Right"
var switched = call("ij.Prefs.get", "sb.switched", false); //default false

var len = call("ij.Prefs.get", "sb.len", 1.0); 
var height = call("ij.Prefs.get", "sb.height", 1.0); 
var fontsize = call("ij.Prefs.get", "sb.fontsize", 1.0); 

var bold = call("ij.Prefs.get", "sb.bold", true); //default true
var overlay = call("ij.Prefs.get", "sb.overlay", true); //default true
var hide = call("ij.Prefs.get", "sb.hide", false); //default false
var serif = call("ij.Prefs.get", "sb.serif", false); //default false

var sb_size_ref = call("ij.Prefs.get", "sb.sb_size_ref", "Width"); //default "Width"

var auto_unit_switching = call("ij.Prefs.get", "sb.auto_unit_switching", true); //default true
var auto_unit_ref = call("ij.Prefs.get", "sb.auto_unit_ref", "Width"); //default false
var U = call("ij.Prefs.get", "sb.U", 3); // default 3
var use_angstrom = call("ij.Prefs.get", "sb.use_angstrom", true); //default true

var auto_rescale = call("ij.Prefs.get", "sb.auto_rescale", false); //default false
var rescale_target_px = call("ij.Prefs.get", "sb.rescale_target_px", 512); //default 512

var doExtraCmd = call("ij.Prefs.get", "sb.doExtraCmd", false); //default false
var extraCmd = call("ij.Prefs.get", "sb.extraCmd", "run('Enhance Contrast', 'saturated=0.35');"); //default "run('Enhance Contrast', 'saturated=0.35');"

var sample_tilt = call("ij.Prefs.get", "sb.sample_tilt", 52); //default 52, FEI FIB-SEM for normal FIB incidence

var warning_plugin_req = call("ij.Prefs.get", "sb.warning_plugin_req", true); // default true

//FEI CROP SCALEBAR
var FEIaddSB = call("ij.Prefs.get", "sb.FEIaddSB", true); //default true
var FEIdoCrop = call("ij.Prefs.get", "sb.FEIdoCrop", true); //default true
var FEIshowMeta = call("ij.Prefs.get", "sb.FEIshowMeta", false); //default false
var FEIdoExtraCmd = call("ij.Prefs.get", "sb.FEIdoExtraCmd", false); //default false
var FEIextraCmd = call("ij.Prefs.get", "sb.FEIextraCmd", "run('Enhance Contrast', 'saturated=0.35');"); //default "run('Enhance Contrast', 'saturated=0.35');"

// --------------------------------------------- //
// --------------- QuickScaleBar --------------- //
// ------------------ +options ----------------- //

macro "QuickScaleBar Action Tool - CfffCeeeCdddCcccCbbbCaaaC999C888C777C666C555C444C333C222C111C000D0dD0eD0fD11D12D13D14D15D16D19D1aD1bD1eD21D26D2bD2eD31D36D3bD3eD41D46D4bD4eD51D56D5bD5eD61D62D63D66D67D68D69D6aD6bD6eD7eD8eD91D92D93D94D95D96D97D98D99D9aD9bD9eDa1Da6DabDaeDb1Db6DbbDbeDc1Dc6DcbDceDd1Dd6DdbDdeDe2De3De4De5De7De8De9DeaDeeDfdDfeDff" {
	addScalebar();
}

macro "QuickScaleBar Action Tool Options [n*]" {

	// Options dialog
	Dialog.create("QuickScaleBar tool options");

	// Choices for some dialog options
	locs = newArray("Upper Right", "Lower Right", "Lower Left", "Upper Left", "At Selection");
	colors = newArray("White", "Black", "Gray", "Red", "Green", "Blue");
	colors_bg = newArray("None", "White", "Black", "Gray");
	rots = newArray("Rotate 90 Degrees Left", "Rotate 90 Degrees Right");
	sb_size_refs = newArray("Larger", "Smaller", "Width", "Height");
	auto_unit_refs = newArray("Width", "Height", "Both");
	
	Dialog.addNumber("Relative height: ", hfac);
	Dialog.addToSameRow();
	Dialog.addNumber("Scaling factor: ", sf);
	Dialog.addNumber("Relative width: ", wfac);
	Dialog.addNumber("Relative fontsize: ", fsfac);
	Dialog.addChoice("Scalebar color:", colors, col);
	Dialog.addChoice("Background color:", colors_bg, bgcol);
	Dialog.addChoice("Scalebar location:", locs, loc);

	Dialog.addCheckbox("Bold Text", bold);
	Dialog.addToSameRow();
	Dialog.addCheckbox("Overlay", overlay);
	Dialog.addCheckbox("Serif Font", serif);
	Dialog.addToSameRow();
	Dialog.addCheckbox("Hide Text (Creates image with scalebar length in title)", hide);
	
	Dialog.addChoice("Scalebar size reference:", sb_size_refs, sb_size_ref);
	Dialog.addCheckbox("Auto unit-switching", auto_unit_switching);
	Dialog.addToSameRow();
	Dialog.addChoice("Check:", auto_unit_refs, auto_unit_ref);
	Dialog.addToSameRow();
	Dialog.addNumber("Unit factor: ", U);
	Dialog.addToSameRow();
	Dialog.addCheckbox("Use Angstrom", use_angstrom);
	Dialog.addCheckbox("Auto re-scale images", auto_rescale);
	Dialog.addToSameRow();
	Dialog.addNumber("Min. height/width (pixels): ", rescale_target_px);
	Dialog.addCheckbox("Run custom macro commands", doExtraCmd);
	Dialog.addString("Custom macro commands:", extraCmd, 70);
	Dialog.addHelp("https://github.com/lukmuk/em-scalebartools");
	Dialog.show();
	
	// Grab values from UI
	hfac = Dialog.getNumber();
	sf = Dialog.getNumber();
	wfac = Dialog.getNumber();
	fsfac = Dialog.getNumber();
	col = Dialog.getChoice();
	bgcol = Dialog.getChoice();
	loc = Dialog.getChoice();
	bold = Dialog.getCheckbox();
	overlay = Dialog.getCheckbox();
	serif = Dialog.getCheckbox();
	hide = Dialog.getCheckbox();
	sb_size_ref = Dialog.getChoice();
	
	auto_unit_switching = Dialog.getCheckbox();
	auto_unit_ref = Dialog.getChoice();
	U = Dialog.getNumber();
	use_angstrom = Dialog.getCheckbox();
	
	auto_rescale= Dialog.getCheckbox();
	rescale_target_px = Dialog.getNumber();
	
	doExtraCmd = Dialog.getCheckbox();
	extraCmd = Dialog.getString(); 

	// store updated values for future use
	call("ij.Prefs.set", "sb.hfac", hfac); // default 0.02
	call("ij.Prefs.set", "sb.sf", sf); // default 1
	call("ij.Prefs.set", "sb.wfac", wfac);  // default 0.2
	call("ij.Prefs.set", "sb.fsfac", fsfac);  // default 2
	call("ij.Prefs.set", "sb.col", col);  // default "Black"
	call("ij.Prefs.set", "sb.bgcol", bgcol);  // default "White"
	call("ij.Prefs.set", "sb.loc", loc);  // default "Lower Right"
	call("ij.Prefs.set", "sb.bold", bold); //default true
	call("ij.Prefs.set", "sb.overlay", overlay); //default true
	call("ij.Prefs.set", "sb.serif", serif); //default false
	call("ij.Prefs.set", "sb.hide", hide); //default false
	call("ij.Prefs.set", "sb.sb_size_ref", sb_size_ref); //default false
	call("ij.Prefs.set", "sb.auto_unit_switching", auto_unit_switching);  // default true
	call("ij.Prefs.set", "sb.auto_unit_ref", auto_unit_ref);  // default "Width"
	call("ij.Prefs.set", "sb.U", U);  // default 3
	call("ij.Prefs.set", "sb.use_angstrom", use_angstrom); //default true
	call("ij.Prefs.set", "sb.auto_rescale", auto_rescale);  // default false
	call("ij.Prefs.set", "sb.rescale_target_px", rescale_target_px);  // default 512
	call("ij.Prefs.set", "sb.doExtraCmd", doExtraCmd);
	call("ij.Prefs.set", "sb.extraCmd", extraCmd);

	// Update scale bar
	addScalebar();
}

// --------------------------------------------- //
// ------------- FEI Crop Scalebar ------------- //
// --------------------------------------------- //

macro "FEI Crop Scalebar Action Tool - CfffCeeeCdddCcccCbbbCaaaC999C888C777C666C555C444C333C222C111C000D02D03D04D05D06D07D08D09D0aD0bD0cD0dD12D17D22D27D32D37D42D47D52D72D73D74D75D76D77D78D79D7aD7bD7cD7dD82D87D8dD92D97D9dDa2Da7DadDb2Db7DbdDc2Dc7DcdDf2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfd" {
	runMacro("FEI_Crop_Scalebar.ijm");
}

macro "FEI Crop Scalebar Action Tool Options" {
	// options dialog
	Dialog.create("FEI Crop Scalebar tool options");
	Dialog.addCheckbox("Add scale bar", FEIaddSB);
	Dialog.addCheckbox("Crop data bar", FEIdoCrop);
	Dialog.addCheckbox("Show metadata in log window", FEIshowMeta);
	Dialog.addCheckbox("Run custom macro commands", FEIdoExtraCmd);
	Dialog.addString("Custom macro commands:", FEIextraCmd, 30);
	Dialog.addHelp("https://github.com/lukmuk/em-scalebartools");
	Dialog.show();

	// grab values
	FEIaddSB = Dialog.getCheckbox();
	FEIdoCrop = Dialog.getCheckbox();
	FEIshowMeta = Dialog.getCheckbox();
	FEIdoExtraCmd = Dialog.getCheckbox();
	FEIextraCmd = Dialog.getString();

	// store updated values
	call("ij.Prefs.set", "sb.FEIaddSB", FEIaddSB);
	call("ij.Prefs.set", "sb.FEIdoCrop", FEIdoCrop);
	call("ij.Prefs.set", "sb.FEIshowMeta", FEIshowMeta);
	call("ij.Prefs.set", "sb.FEIdoExtraCmd", FEIdoExtraCmd);
	call("ij.Prefs.set", "sb.FEIextraCmd", FEIextraCmd);
}


// --------------------------------------------- //
// ------------- Move Overlay tool ------------- //
// --------------------------------------------- //
// Copied from: https://imagej.nih.gov/ij/source/macros/Overlay%20Editing%20Tools.txt

macro "Move Overlay Tool - C037O33aaL03f3L303f" { 
  getCursorLoc( x, y, z, flags ); 
  selectNone(); 
  r = newArray( 0, getWidth / 2, getWidth, 0, getHeight / 2, getHeight ); 
  n = Overlay.size; 
  if( n < 1 ) exit( "Overlay required" ); 
  id = Overlay.indexAt( x, y ); 
  for( i = 0; i < n; i ++ ) { 
    if( i != id ) { 
      Overlay.getBounds( i, bx, by, bw, bh ); 
      er = newArray( bx, bx + bw / 2, bx + bw, by, by + bh / 2, by + bh ); 
      r = Array.concat( r, er ); 
    } 
  } 
  while( flags & 16 > 0 ) { 
    getCursorLoc( x, y, z, flags ); 
    Overlay.getBounds( id, bx, by, bw, bh ); 
    if( id < 0 ) break; 
    Overlay.moveSelection( id, x - bw / 2, y - bh / 2 ); 
    Overlay.getBounds( id, bx, by, bw, bh ); 
    d = newArray( bx, bx + bw / 2, bx + bw, by, by + bw / 2, by + bh ); 
    while( Overlay.size > n ) Overlay.removeSelection( Overlay.size - 1 ); 
    hit = 0x00; 
    for( i = 0; i < r.length; i = i + 6 ) { // each element
      for( p = 0; p < 6; p ++ ) // each remarkable point
      if( abs( d [ p ]- r [ i + p ] )< 5 ) { 
        hit = hit |( 0x01 << p ); // allows for multiple hits
      } 
      if( hit > 0 ) { 
        ihit = i; 
        break; 
      } 
    } 
    for( i = 0; i < 6; i ++ ) { 
      if( hit &( 1 << i )> 0 ) { 
        if( i < 3 ) { 
          Overlay.getBounds( id, bx, by, bw, bh ); 
          Overlay.drawLine( r [ ihit + i ], 0, r [ ihit + i ], getHeight ); 
          if( i == 0 ) Overlay.moveSelection( id, r [ ihit + i ], by ); 
          if( i == 1 ) Overlay.moveSelection( id, r [ ihit + i ]- bw / 2, by ); 
          if( i == 2 ) Overlay.moveSelection( id, r [ ihit + i ]- bw, by ); 
        } 
        if( i >= 3 ) { 
          Overlay.getBounds( id, bx, by, bw, bh ); 
          Overlay.drawLine( 0, r [ ihit + i ], getWidth, r [ ihit + i ] ); 
          if( i == 3 ) Overlay.moveSelection( id, bx, r [ ihit + i ] ); 
          if( i == 4 ) Overlay.moveSelection( id, bx, r [ ihit + i ]- bh / 2 ); 
          if( i == 5 ) Overlay.moveSelection( id, bx, r [ ihit + i ]- bh ); 
        } 
      } 
    } 
    Overlay.show; 
    wait( 20 ); 
  } 
  while( Overlay.size > n ) Overlay.removeSelection( Overlay.size - 1 ); 
}

// --------------------------------------------- //
// ------------ Remove Overlays tool ----------- //
// --------------------------------------------- //

macro "Remove Overlays Action Tool - C037R00ddB58Cd00L0088L0880" {
	run("Remove Overlay");
}

// --------------------------------------------- //
// --------- Misc. Functions Menu Tool --------- //
// --------------------------------------------- //
var mCmds = newMenu("Misc. Functions Menu Tool", newArray("Set pixel size and unit", "Set voxel size and unit", "Set image width and unit", "-", "Correct for tilted perspective", "Calculate electron wavelength", "-","Export scale-bar parameters", "Import scale-bar parameters", "Edit source code (advanced)", "Preferences", "Help"));
macro "Misc. Functions Menu Tool - CfffCeeeCdddCcccCbbbCaaaC999C888C777C666C555C444C333C222C111C000D23D24D27D28D2bD2cD33D34D37D38D3bD3cD43D44D47D48D4bD4cD53D54D57D58D5bD5cD63D64D67D68D6bD6cD73D74D77D78D7bD7cD83D84D87D88D8bD8cD93D94D97D98D9bD9cDa3Da4Da7Da8DabDacDb3Db4Db7Db8DbbDbcDc3Dc4Dc7Dc8DcbDccDd3Dd4Dd7Dd8DdbDdc" {
	cmd = getArgument();
	if (cmd!="-" && cmd == "Set pixel size and unit") setPxAndUnit();
	if (cmd!="-" && cmd == "Set voxel size and unit") setVoxAndUnit();
	if (cmd!="-" && cmd == "Set image width and unit") setWidthAndUnit();
	if (cmd!="-" && cmd == "Correct for tilted perspective") correctSampleTilt();
	if (cmd!="-" && cmd == "Calculate electron wavelength") calcWav();
	if (cmd!="-" && cmd == "Export scale-bar parameters") exportEMScaleBarToolsParams();
	if (cmd!="-" && cmd == "Import scale-bar parameters") importEMScaleBarToolsParams();
	if (cmd!="-" && cmd == "Edit source code (advanced)") editSourceCode();
	if (cmd!="-" && cmd == "Preferences") editPreferences();
	if (cmd!="-" && cmd == "Help") HelpMenu();
}
	


// --------------------------------------------- //
// ------------------ HOTKEYS ------------------ //
// --------------------------------------------- //


// JPEG saving
macro "Save As JPEG... [j]" {
	quality = call("ij.plugin.JpegWriter.getQuality");
	quality = getNumber("JPEG quality (0-100):", quality);
	run("Input/Output...", "jpeg="+quality);
	saveAs("Jpeg");
}

// PNG saving
macro "Save As PNG... [p]" {
	saveAs("PNG");
}

// SVG saving
// Requires BioVoxxel Figure Tools
macro "Save as SVG... [s]" {
	// Warning for required plugin
	warning_plugin_req = call("ij.Prefs.get", "sb.warning_plugin_req", true);
	if(warning_plugin_req) {
		Dialog.create("Warning");
		Dialog.addMessage("Requires the plugin: BioVoxxel Figure Tools\nClick:\n   - 'Ok' to continue\n   - 'Cancel' to stop the action\n   - 'Help' to open the plugin page.\nThis warning can be disabled in the preferences.");
		Dialog.addHelp("https://github.com/biovoxxel/BioVoxxel-Figure-Tools");
		Dialog.show();
	}
	
	svg_dir = getDirectory("Choose a directory for saving the svg");
	img_title = getTitle();
	save_title = substring(img_title, 0, lastIndexOf(img_title, "."));
	run("Export SVG", "filename="+save_title+" folder="+svg_dir+" keepcomposite=false exportchannelsseparately=None exportalsononvisiblechannels=false interpolationrange=0.0 locksensitiverois=true");
}

// "Copy to system shortcut" -> quickly copy to other programs
macro "Copy to system... [c]" {
	// Auto rescale images below rescale_target_px
	if(auto_rescale && (getWidth() < rescale_target_px || getHeight() < rescale_target_px)) {
		id = getImageID();
		w = getWidth();
		h = getHeight();
		facw = Math.ceil(rescale_target_px/w);
		fach = Math.ceil(rescale_target_px/h);

		// Handle stacks, copy only active slice to clipboard
		d = 1;
		if(nSlices > 1) d = nSlices;
		
		if(facw >= fach) {
			run("Scale...", "x="+facw+" y="+facw+" width="+(facw*w)+" height="+(facw*h)+" depth="+d+" interpolation=None average create");
		}
		else {
			run("Scale...", "x="+fach+" y="+fach+" width="+(fach*w)+" height="+(fach*h)+" depth="+d+" interpolation=None average create");
		}
		
		// copy the scaled image to the clipboard, then close it
		run("Copy to System");
		close();
		
		selectImage(id);
	}
	else {
		run("Copy to System");
	}
}

// Add scale bar
// ALT: Invert color
macro "Add Scale Bar [5]"{
	//Invert color if ALT is pressed
	if(isKeyDown("alt")) {
		//Get current values
		col = call("ij.Prefs.get", "sb.col", "Black");
		bgcol = call("ij.Prefs.get", "sb.bgcol", "White");  
		
		while(true) {
			if(col == "Black" && bgcol == "None") {
				col = "White";
				break;
			}
			if(col == "White" && bgcol == "None") {
				col = "Black";
				break;
			}
			if(col == "Black" && bgcol == "White") {
				col = "White";
				bgcol = "Black";
				break;
			}
			if(col == "White" && bgcol == "Black") {
				col = "Black";
				bgcol = "White";
				break;
			}
			break;
		}

		//Set value
		call("ij.Prefs.set", "sb.col", col);
		call("ij.Prefs.set", "sb.bgcol", bgcol); 
		updateScalebar();
	}

	//Toggle scale-bar on/off
	else {
		if(Overlay.size != 0) run("Remove Overlay");
		else updateScalebar();
	}
}

// Decrease scale-bar size
// ALT: Specify scale-bar size from user input by modifying size factor sf
macro "Shrink Scale Bar [3]"{
	sf_old = parseFloat(call("ij.Prefs.get", "sb.sf", 1.0));
	if(isKeyDown("alt")) {
		//Set scaling factor from user input
		Dialog.create("Set scaling factor");
		Dialog.addNumber("Set scaling factor: ", sf_old, 2, 10, "");
		Dialog.addHelp("https://github.com/lukmuk/em-scalebartools/wiki/Hotkeys#2-8---de-increase-scale-bar-size-via-scaling-factor-with-alt-key-pressed-specify-the-scaling-factor");
		Dialog.show();

		//Grab values from UI
		sf_new = Dialog.getNumber();
	}
	else {
		sf_new = sf_old - 0.1;
	}
	call("ij.Prefs.set", "sb.sf", sf_new);
	updateScalebar();
}

// Increase scale-bar size
// ALT: Specify scale-bar size from user input by modifying size factor sf
macro "Enlarge Scale Bar [4]" {
	sf_old = parseFloat(call("ij.Prefs.get", "sb.sf", 1.0));
	height_old = parseFloat(call("ij.Prefs.get", "sb.height", 1.0));
	fontsize_old = parseFloat(call("ij.Prefs.get", "sb.fontsize", 1.0));
	
	if(isKeyDown("alt")) {
		//Set scaling factor from user input
		Dialog.create("Set scaling factor");
		Dialog.addNumber("Set scaling factor: ", sf_old, 2, 10, "");
		Dialog.addHelp("https://github.com/lukmuk/em-scalebartools/wiki/Hotkeys#2-8---de-increase-scale-bar-size-via-scaling-factor-with-alt-key-pressed-specify-the-scaling-factor");
		Dialog.show();
		
		//Grab values from UI
		sf_new = Dialog.getNumber();
		height_new = height_old * sf_new;
		fontsize_new = fontsize_old * sf_new;
	}
	else {
		sf_new = sf_old + 0.1;
	}
	
	call("ij.Prefs.set", "sb.sf", sf_new);	
	updateScalebar();
}

// Increase scale-bar length in measurement units in 1-2-5 series
// ALT: Specify scale-bar length from user input in length units
macro "Increase Scale Bar Size Increment [2]" {
	scalebarlen = parseFloat(call("ij.Prefs.get", "sb.len", 1.0));

	scalebarlen_new = round((scalebarlen*2.3)/(Math.pow(10,(floor(Math.log10(abs(scalebarlen*2.3)))))))*(Math.pow(10,(floor(Math.log10(abs(scalebarlen*2.3))))));
	
	// Calculate image width in length unit
	getPixelSize(unit,w_px,h_px);
	imagewidth = w_px*getWidth();
	
	// Set scale-bar length from user input
	if(isKeyDown("alt")) {
		Dialog.create("Set scale bar length");
		Dialog.addNumber("Set scale-bar length: ", scalebarlen, 2, 10, "");
		Dialog.addHelp("https://github.com/lukmuk/em-scalebartools/wiki/Hotkeys#4-6---de-increase-scale-bar-length-in-1-2-5-series-with-alt-key-pressed-specify-a-custom-scale-bar-length-in-measurement-units");
		Dialog.show();
		
		// Grab values from UI
		scalebarlen_new = Dialog.getNumber();
		if(scalebarlen_new > imagewidth) print("Desired scale-bar length exceeds image width (",toString(imagewidth,2), ").");
		if(scalebarlen_new < 1)  print("Please choose a value >= 1 or switch length unit prefix (e.g. µm to nm).");
	}
	
	// Update len
	// if clause to prevent scale bar length being (i) larger than actual image width and (ii) smaller than 1
	if(scalebarlen_new <= imagewidth && scalebarlen_new >= 1)  call("ij.Prefs.set", "sb.len", scalebarlen_new);
	updateScalebar();
	
}

// Decrease scale-bar length in measurement units in 1-2-5 series
// ALT: Specify scale-bar length from user input in length units
macro "Decrease Scale Bar Size Increment [1]" {
	scalebarlen = parseFloat(call("ij.Prefs.get", "sb.len", 1.0));
	height = call("ij.Prefs.get", "sb.height", 1.0);
	fontsize = call("ij.Prefs.get", "sb.fontsize", 1.0);

	scalebarlen_new = scalebarlen/10;
	while (1)  {
	 	tmp = round((scalebarlen_new*2.3)/(Math.pow(10,(floor(Math.log10(abs(scalebarlen_new*2.3)))))))*(Math.pow(10,(floor(Math.log10(abs(scalebarlen_new*2.3))))));
		if (tmp >= scalebarlen) {
			break;
		}
		else {
			scalebarlen_new = tmp;
		}
	}
	
		
	// Calculate image width in length unit
	getPixelSize(unit,w_px,h_px);
	imagewidth = w_px*getWidth();

	// Set scale-bar length from user input
	if(isKeyDown("alt")) {
		Dialog.create("Set scale bar length");
		Dialog.addNumber("Set scale-bar length: ", scalebarlen, 2, 10, "");
		Dialog.addHelp("https://github.com/lukmuk/em-scalebartools/wiki/Hotkeys#4-6---de-increase-scale-bar-length-in-1-2-5-series-with-alt-key-pressed-specify-a-custom-scale-bar-length-in-measurement-units");
		Dialog.show();
		
		// Grab values from UI
		scalebarlen_new = Dialog.getNumber();
		if(scalebarlen_new > imagewidth) print("Desired scale-bar length exceeds image width (",toString(imagewidth,2), ").");
		if(scalebarlen_new < 1)  print("Please choose a value >= 1 or switch length unit prefix (e.g. µm to nm).");
	}
	
	// Update len
	// if clause to prevent scale bar length being (i) larger than actual image width and (ii) smaller than 1
	if(scalebarlen_new <= imagewidth && scalebarlen_new >= 1)  call("ij.Prefs.set", "sb.len", scalebarlen_new);
	updateScalebar();

}


// Set scale-bar position via numpad keys
macro "Scale Bar Corner Position Toggle  [6]" {
	loc = call("ij.Prefs.get", "sb.loc", "Lower Right");
	loc_changed = false;
	if (loc == "Lower Right" && loc_changed == false) {
		call("ij.Prefs.set", "sb.loc", "Upper Right");
		loc_changed = true;
	}
	if (loc == "Upper Right" && loc_changed == false) {
		call("ij.Prefs.set", "sb.loc", "Upper Left");
		loc_changed = true;
	}
	if (loc == "Upper Left" && loc_changed == false) {
		call("ij.Prefs.set", "sb.loc", "Lower Left");
		loc_changed = true;
	}
	if (loc == "Lower Left" && loc_changed == false) {
		call("ij.Prefs.set", "sb.loc", "Lower Right");
		loc_changed = true;
	}
	updateScalebar();
}


// Reset scale bar location to "Lower Right" and scaling factor back to 1.0
macro "Reset Scale Bar [7]" {
	// Add a scalebar if no overlay is present
	if(Overlay.size == 0) {
		call("ij.Prefs.set", "sb.loc", "Lower Right");
		call("ij.Prefs.set", "sb.sf", 1.0);
		addScalebar();
	}
	else {
		call("ij.Prefs.set", "sb.loc", "Lower Right");
		call("ij.Prefs.set", "sb.sf", 1.0);
		updateScalebar();
	}
}

// Switch vertical positions of the scale bar and the label
macro "Switch Scale Bar and Label [t]" {
	switched = call("ij.Prefs.get", "sb.switched", false);
	if(switched) {
		run("Remove Overlay");
		call("ij.Prefs.set", "sb.switched", false);
	}
	else {
		run("Remove Overlay");
		call("ij.Prefs.set", "sb.switched", true);
	}
	updateScalebar();
}

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

	// Run extra commands
	if (doExtraCmd) eval(extraCmd);

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
	
	scalebarlen = 0.0001*imw; // initial scale bar length in measurement units
	maxscalebarlen = imw * wfac; // maximum scale bar width in measurement units
	
	// recursively calculate a 1-2-5 series until the length reaches scalebarsize, default to 1/10th of image width
	// 1-2-5 series is calculated by repeated multiplication with 2.3, rounded to one significant digit
	while (scalebarlen < maxscalebarlen) {
		scalebarlen = round((scalebarlen*2.3)/(Math.pow(10,(floor(Math.log10(abs(scalebarlen*2.3)))))))*(Math.pow(10,(floor(Math.log10(abs(scalebarlen*2.3))))));
	}
	
	// Check for possible rounding errors, set scalebarlen to 1 if it is < 1
	if(scalebarlen < 1)  {
		print("Scale bar length in physical units < 1 unit. Possible rounding error.");
		print("Please double-check the scale-bar length by measuring with the straight line tool.");
		print("Setting scale bar to 1 unit.");
		print("Before: ", scalebarlen);
		if(scalebarlen < 1) scalebarlen = 1;
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
		if (indexOf(name, "_scale-") >= 0) {
			newtitle = substring(getTitle(), 0, lastIndexOf(getTitle(), "_scale-"));
		}
		else {
			newtitle = substring(getTitle(), 0, lastIndexOf(getTitle(), '.'));
		}
		run("Duplicate...", "title="+newtitle+"_scale-"+scalebarlen+unit+".tif");
		if(auto_rescale) close(name);
	}
	
}

function updateScalebar() {
	/* 
	Function to update/redraw the scale bar.
	*/

	// Get current parameter values which may be changed by other functions
	sf = parseFloat(call("ij.Prefs.get", "sb.sf", 1));
	fsfac = parseFloat(call("ij.Prefs.get", "sb.fsfac", 3));
	loc = call("ij.Prefs.get", "sb.loc", "Lower Right");
	scalebarlen = call("ij.Prefs.get", "sb.len", 1.0);

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
	height = height * sf;
	
	// Calculate fontsize
	fontsize = height * fsfac;

	col = call("ij.Prefs.get", "sb.col", "Black");
	bgcol = call("ij.Prefs.get", "sb.bgcol", "White");  
	switched = call("ij.Prefs.get", "sb.switched", false);
	if(switched) run("Remove Overlay");

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
		if (indexOf(name, "_scale-") >= 0) {
			newtitle = substring(getTitle(), 0, lastIndexOf(getTitle(), "_scale-"));
		}
		else {
			newtitle = substring(getTitle(), 0, lastIndexOf(getTitle(), '.'));
		}
		run("Duplicate...", "title="+newtitle+"_scale-"+scalebarlen+unit+".tif");
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


// Helper function for overlay tools
// from: https://imagej.nih.gov/ij/source/macros/Overlay%20Editing%20Tools.txt
function selectNone( ) { 
  Overlay.removeRois( 'ToolSelectedOverlayElement' ); 
  Overlay.show; 
} 

function selectElement( id, add ) { 
  if( add == true ) { 
    selected = getSelectedElements( ); 
    s = split( selected, ',' ); 
    isSelected = false; 
    for( i = 0; i < s.length; i ++ ) { 
      if( 1 * s [ i ]== id ) isSelected = true; 
    } 
    if( ! isSelected ) { 
      call( 'ij.Prefs.set', 'overlaytoolset.selected', selected + ',' + id  ); 
      selected = getSelectedElements( ); 
    } else { 
      unselectElement( id ); 
    } 
  } else { 
    call( 'ij.Prefs.set', 'overlaytoolset.selected',  id  ); 
  } 
  highlightSelectedROIs( ); 
} 

function unselectElement( id ) { 
  selected = getSelectedElements( ); 
  s = split( selected, ',' ); 
  selected = ''; 
  for( i = 0; i < s.length; i ++ ) { 
    if( s [ i ]!= id ) selected = selected +  s [ i ]+ ','; 
  } 
  call( 'ij.Prefs.set', 'overlaytoolset.selected', selected ); 
  selected = getSelectedElements( ); 
  highlightSelectedROIs( ); 
  run( "Select None" ); 
}

function getSelectedElements( ) { 
  selected = call( 'ij.Prefs.get', 'overlaytoolset.selected', '' ); 
  while( selected.endsWith( "," ) ) selected = substring( selected, 0, lengthOf( selected )- 1 ); 
  while( selected.startsWith( "," ) ) selected = substring( selected, 1, lengthOf( selected ) ); 
  return selected; 
} 

// Set pixel size and unit 
// Used to set image scale by a given pixel size. Default value is the current pixel size and length unit.
function setPxAndUnit() {
	// Grab pixel size and unit from current image
	getPixelSize(u, pw, ph);

	// Options dialog
	Dialog.create("Set pixel size and unit");

	// Special character list
	// Angstrom, Angstrom-1, nm-1
	special = newArray(fromCharCode(0x0212b), fromCharCode(0x0212b, 0x0207b, 0x000b9), 'nm'+fromCharCode(0x0207b, 0x000b9));
	
	Dialog.addNumber("Pixel size: ", pw, 8, 10, "");
	Dialog.addString("Unit: ", u);
	Dialog.addCheckbox("Use special unit: ", false);
	Dialog.addToSameRow();
	Dialog.addChoice("", special, fromCharCode(0x0212b));
	Dialog.addHelp("https://github.com/lukmuk/em-scalebartools");
	Dialog.show();
	
	// Grab values from UI
	pw_new = Dialog.getNumber();
	ph_new = pw_new;
	u_new = Dialog.getString();
	UseUnitFromMenu = Dialog.getCheckbox();
	if(UseUnitFromMenu) {
		u_new = Dialog.getChoice();
	}

	setVoxelSize(pw_new, ph_new, 1, u_new);
}

// Set voxel size and unit 
// Used to set image scale by a given voxel size. Default value is the current pixel size and length unit.
function setVoxAndUnit() {
	// Grab voxel size and unit from current image
	getPixelSize(u, pw, ph);
	getVoxelSize(pw, ph, depth, u);

	// Options dialog
	Dialog.create("Set voxel size and unit");

	// Special character list
	// Angstrom, Angstrom-1, nm-1
	special = newArray(fromCharCode(0x0212b), fromCharCode(0x0212b, 0x0207b, 0x000b9), 'nm'+fromCharCode(0x0207b, 0x000b9));
	
	Dialog.addNumber("Voxel size x: ", pw, 8, 10, "");
	Dialog.addNumber("Voxel size y: ", ph, 8, 10, "");
	Dialog.addNumber("Voxel size z: ", depth, 8, 10, "");
	Dialog.addString("Unit: ", u);
	Dialog.addCheckbox("Use special unit: ", false);
	Dialog.addToSameRow();
	Dialog.addChoice("", special, fromCharCode(0x0212b));
	Dialog.addHelp("https://github.com/lukmuk/em-scalebartools");
	Dialog.show();
	
	// Grab values from UI
	pw_new = Dialog.getNumber();
	ph_new = Dialog.getNumber();
	depth_new = Dialog.getNumber();
	u_new = Dialog.getString();
	UseUnitFromMenu = Dialog.getCheckbox();
	if(UseUnitFromMenu) {
		u_new = Dialog.getChoice();
	}

	setVoxelSize(pw_new, ph_new, depth_new, u_new);
}

// Set image width and unit 
// Used to set image scale by a given image width. Default value is the current scaled image width and length unit.
function setWidthAndUnit() {
	// Grab pixel size and unit from current image
	getPixelSize(u, pw, ph);
	w_px = getWidth();
	w = w_px*pw;
	
	//Options dialog
	Dialog.create("Set image width and unit");

	// Special character list
	// Angstrom, Angstrom-1, nm-1
	special = newArray(fromCharCode(0x0212b), fromCharCode(0x0212b, 0x0207b, 0x000b9), 'nm'+fromCharCode(0x0207b, 0x000b9));
	
	Dialog.addNumber("Image width: ", w, 8, 10, "");
	Dialog.addString("Unit: ", u);
	Dialog.addCheckbox("Use special unit: ", false);
	Dialog.addToSameRow();
	Dialog.addChoice("", special, fromCharCode(0x0212b));
	Dialog.addHelp("https://github.com/lukmuk/em-scalebartools");
	Dialog.show();
	
	// Grab values from UI
	w_input = Dialog.getNumber();
	pw_new = w_input/w_px;
	ph_new = pw_new;
	u_new = Dialog.getString();

	UseUnitFromMenu = Dialog.getCheckbox();
	if(UseUnitFromMenu) {
		u_new = Dialog.getChoice();
	}
	setVoxelSize(pw_new, ph_new, 1, u_new);
}

// Calculate relativistic electron wavelength
function calcWav() {
	// Options dialog
	Dialog.create("Calculate electron wavelength");
	Dialog.addMessage("Calculate electron wavelength", 15);
	Dialog.addNumber("Electron energy (keV): ", 30);
	Dialog.addHelp("https://github.com/lukmuk/em-scalebartools");
	Dialog.show();
	
	// Grab values from UI
	E = Dialog.getNumber();
	
	e0 = E*1e3*1.602176565e-19; // beam energy, J 
	m0 = 9.1093837015e-31; // electron mass, kg
	h = 6.62607015e-34; // Plancks constant, eV s
	c = 299792458; // speed of light in vacuum, m/s
	wav = h/Math.sqrt(2*m0*e0*(1.0+e0/(2.0*m0*c*c))); //relativistic wavelength, pm
	print("Wavelength at "+E+" keV in pm: "+wav*1e12);
}

// Set pixel size of tilted stage or scale image in y-direction (vertical)
// Use to measure features in tilted image, e.g., from SEM-EBSD or FIB-SEM cross-sections
function correctSampleTilt() {
	// Grab pixel size and unit from current image
	getPixelSize(u, pw, ph);

	// Options dialog
	Dialog.create("Tilted View - Pixel Size / Image Re-Scaler");
	Dialog.addMessage("Please enter a sample tilt and select the desired output options.");
	Dialog.addMessage("Note: The vertical / y-direction is assumed to be the tilted direction.");
	Dialog.addNumber("       Sample tilt: ", sample_tilt, 1, 5, "");
	Dialog.addMessage("Rescale pixel size:");
	Dialog.addCheckbox("Cross-section ", true);
	Dialog.addCheckbox("Surface ", false);
	Dialog.addMessage("Rescale image size (requires TransformJ):");
	Dialog.addCheckbox("Cross-section ", true);
	Dialog.addCheckbox("Surface ", false);
	
	Dialog.addHelp("https://github.com/lukmuk/em-scalebartools");
	Dialog.show();
	
	// Grab values from UI
	sample_tilt = Dialog.getNumber();
	do_cross_section_tilt_correction = Dialog.getCheckbox();
	do_surface_tilt_correction = Dialog.getCheckbox();
	
	do_cross_section_tilt_correction_image = Dialog.getCheckbox();
	do_surface_tilt_correction_image = Dialog.getCheckbox();
	

	// Evalute
	id = getImageID();
	
	if(do_cross_section_tilt_correction) {
		selectImage(id);
		title_tmp = substring(getTitle(), 0, indexOf(getTitle(), '.'));
		run("Duplicate...", "title="+title_tmp+"-TC_"+sample_tilt+"deg_XSec.tif");
		
		ph_new = ph * 1/sin(sample_tilt*PI/180);
		setVoxelSize(pw, ph_new, 1, u);
	}
		
	if(do_surface_tilt_correction) {
		selectImage(id);
		title_tmp = substring(getTitle(), 0, indexOf(getTitle(), '.'));
		run("Duplicate...", "title="+title_tmp+"-TC_"+sample_tilt+"deg_Surf.tif");
		
		ph_new = ph * 1/cos(sample_tilt*PI/180);
		setVoxelSize(pw, ph_new, 1, u);
	}
	
	
	if(do_cross_section_tilt_correction_image) {
		// Warning for required plugin
		warning_plugin_req = call("ij.Prefs.get", "sb.warning_plugin_req", true);
		if(warning_plugin_req) {
			Dialog.create("Warning");
			Dialog.addMessage("Requires the plugin: TransformJ\nPlease acknowledge the author/paper (see Help).\nClick:\n   - 'Ok' to continue\n   - 'Cancel' to stop the action\n   - 'Help' to open the plugin page.\nThis warning can be disabled in the preferences.");
			Dialog.addHelp("https://imagescience.org/meijering/software/transformj/");
			Dialog.show();
		}
		
		selectImage(id);
		title_tmp = substring(getTitle(), 0, indexOf(getTitle(), '.'));
		run("Duplicate...", "title="+title_tmp+"-TC_"+sample_tilt+"deg_XSec_ImgRescale.tif");
		id_tmp = getImageID();
		
		rescale_factor = 1/sin(sample_tilt*PI/180);
		run("TransformJ Scale", "x-factor=1.0 y-factor="+rescale_factor+" z-factor=1.0 interpolation=[Quintic B-Spline]");
		selectImage(id_tmp);
		close();
	}
	
	if(do_surface_tilt_correction_image) {
		// Warning for required plugin
		if(warning_plugin_req) {
			Dialog.create("Warning");
			Dialog.addMessage("Requires the plugin: TransformJ\nPlease acknowledge the author/paper (see Help).\nClick:\n   - 'Ok' to continue\n   - 'Cancel' to stop the action\n   - 'Help' to open the plugin page.\nThis warning can be disabled in the preferences.");
			Dialog.addHelp("https://imagescience.org/meijering/software/transformj/");
			Dialog.show();
		}
		selectImage(id);
		title_tmp = substring(getTitle(), 0, indexOf(getTitle(), '.'));
		run("Duplicate...", "title="+title_tmp+"-TC_"+sample_tilt+"deg_Surf_ImgRescale.tif");
		id_tmp = getImageID();
		
		rescale_factor = 1/cos(sample_tilt*PI/180);
		run("TransformJ Scale", "x-factor=1.0 y-factor="+rescale_factor+" z-factor=1.0 interpolation=[Quintic B-Spline]");
		selectImage(id_tmp);
		close();
	}
	
	selectImage(id);
	
	// store variables for later use
	call("ij.Prefs.set", "sb.sample_tilt", sample_tilt); // default 52
}

// Open the source code (advanced)
// Edit/adjust/inspect code
function editSourceCode() {
	SB_path = getDirectory("macros") + "/toolsets/" + "EMScaleBarTools_Laptop.ijm";
	FEImacro_path = getDirectory("macros") + "FEI_Crop_Scalebar.ijm";
	run("Edit...", "open="+FEImacro_path);
	run("Edit...", "open="+SB_path);
	
}

// Preferences
function editPreferences() {
	// Options dialog to set some general preferences
	
	// Options dialog
	Dialog.create("Preferences");
	Dialog.addCheckbox("Show warnings if extra plugins are required", warning_plugin_req);
		
	Dialog.addHelp("https://github.com/lukmuk/em-scalebartools");
	Dialog.show();
	
	// Grab values from UI
	warning_plugin_req_new = Dialog.getCheckbox();
	
	// store variables for later use
	call("ij.Prefs.set", "sb.warning_plugin_req", warning_plugin_req_new); // default true
}

// Switch vertical positions of scale bar and scale-bar label
function switchScaleBarLabel() {
	// Save possible open "Results" window
	storeResultsWindow();

	// Get length, color and unit of current scale bar
	scalebarlen = call("ij.Prefs.get", "sb.len", 1.0);
	col = call("ij.Prefs.get", "sb.col", "White");
	getPixelSize(unit, pixelWidth, pixelHeight);

	// Grab overlay elements and list them in a "Results" table
	run("List Elements");
	IJ.renameResults("Overlay Elements of "+getTitle(),"Results");
	run("Remove Overlay");

	// Store coordinates of overlay objects (scale bar and label with units)
	sb_index = getValue("results.count") - 2;
	lbl_index = getValue("results.count") - 1;	
	
	sb_Y = getResult("Y", sb_index); //Scale bar
	sb_X = getResult("X", sb_index); //Scale bar
	sb_width = getResult("Width", sb_index); //Scale bar
	sb_height = getResult("Height", sb_index); //Scale bar
	
	lbl_Y = getResult("Y", lbl_index); //Label
	lbl_X = getResult("Y", lbl_index); //Label
	lbl_height = getResult("Height", lbl_index); //Label
	lbl_width = getResult("Width", lbl_index); //Label

	// Create new scale bar position at the base line of the label
	makeRectangle(sb_X, sb_Y+lbl_height-sb_height, sb_width, sb_height);
	Overlay.addSelection("", 0, col);

	// Create new label at position of the scale bar
	// NOTE: It is not horizontally centered yet, so another centering step is performed below
	Overlay.drawString(scalebarlen+" "+unit, sb_X, sb_Y+2*sb_height);
	
	close("Results");

	// This part centers the new label horizontally above the new scale bar
	run("List Elements");
	IJ.renameResults("Overlay Elements of "+getTitle(),"Results");

	sb_index = getValue("results.count") - 2;
	lbl_index = getValue("results.count") - 1;	
	
	lbl_Y = getResult("Y", lbl_index); //Label
	lbl_X = getResult("Y", lbl_index); //Label
	lbl_height = getResult("Height", lbl_index); //Label
	lbl_width = getResult("Width", lbl_index); //Label
	
	setColor(col);
	
	run("Remove Overlay");
	makeRectangle(sb_X, sb_Y+lbl_height-sb_height, sb_width, sb_height);
	Overlay.addSelection("", 0, col);
	
	sb_X_center = sb_X + sb_width/2;
	lbl_X_center = lbl_X + lbl_width/2;
	lbl_X_new = lbl_X - (lbl_X_center - sb_X_center);
	
	// The value of "0.25" in the following modifies the distance between label and scale bar
	// May give non-optimal results for specific fsfac values, i.e.
	// that the label is far away from the scale bar
	ypos = (sb_Y+lbl_height-sb_height) - 0.25*lbl_height;
	Overlay.drawString(scalebarlen+" "+unit, lbl_X_new, ypos);

	// Clean Up
	run("Select None");
	close("Results");

	// Restore old "Results" window if necessary
	restoreResultsWindow();
}

// Functions to handle any currently open "Results" windows, so that they are "stored"
// Some functions of this tool require data from results windows
function storeResultsWindow() {
	// Check for already open Results window
	if(isOpen("Results")) {
		IJ.renameResults("Results_stored");
	}
}

function restoreResultsWindow() {
	// Check for stored results window Results window
	if(isOpen("Results_stored")) {
		IJ.renameResults("Results_stored", "Results");
	}
}

// Check for possible overlays on current image, return true/false
function OverlaysPresent() {
	run("List Elements");
	if(isOpen("Overlay Elements of "+getTitle())) {
		close("Overlay Elements of "+getTitle());
		return true;
	}
	else return false;
}

// Functions to export and load scale-bar parameters
function exportEMScaleBarToolsParams() {
	storeResultsWindow();
	
	setResult("Variable", 0, "hfac"); setResult("Value", 0, call("ij.Prefs.get", "sb.hfac", 0.02));
	setResult("Variable", 1, "sf"); setResult("Value", 1, call("ij.Prefs.get", "sb.sf", 1.0));                       
	setResult("Variable", 2, "wfac"); setResult("Value", 2, call("ij.Prefs.get", "sb.wfac", 1.0)); 
    setResult("Variable", 3, "fsfac"); setResult("Value", 3, call("ij.Prefs.get", "sb.fsfac", 3.0));
    setResult("Variable", 4, "col"); setResult("Value", 4, call("ij.Prefs.get", "sb.col", "Black"));                                   
	setResult("Variable", 5, "bgcol"); setResult("Value", 5, call("ij.Prefs.get", "sb.bgcol", "None"));
	setResult("Variable", 6, "loc"); setResult("Value", 6, call("ij.Prefs.get", "sb.loc", "Lower Right"));
	setResult("Variable", 7, "switched"); setResult("Value", 7, call("ij.Prefs.get", "sb.switched", false)); 
	
	setResult("Variable", 8, "len"); setResult("Value", 8, call("ij.Prefs.get", "sb.sb_en", 1.0));
	setResult("Variable", 9, "height"); setResult("Value", 9, call("ij.Prefs.get", "sb.height", 1.0)); 
	setResult("Variable", 10, "fontsize"); setResult("Value", 10, call("ij.Prefs.get", "sb.fontsize", 1.0)); 
	
	setResult("Variable", 10, "bold"); setResult("Value", 10, call("ij.Prefs.get", "sb.bold", true));
	setResult("Variable", 11, "overlay"); setResult("Value", 11, call("ij.Prefs.get", "sb.overlay", true));
	setResult("Variable", 12, "hide"); setResult("Value", 12, call("ij.Prefs.get", "sb.hide", false));
	setResult("Variable", 13, "serif"); setResult("Value", 13, call("ij.Prefs.get", "sb.serif", false));
	
	setResult("Variable", 14, "sb_size_ref"); setResult("Value", 14, call("ij.Prefs.get", "sb.sb_size_ref", "Width"));
	
	setResult("Variable", 15, "auto_unit_switching"); setResult("Value", 15, call("ij.Prefs.get", "sb.auto_unit_switching", true));
	setResult("Variable", 16, "auto_unit_ref"); setResult("Value", 16, call("ij.Prefs.get", "sb.auto_unit_ref", "Width"));
	setResult("Variable", 17, "U"); setResult("Value", 17, call("ij.Prefs.get", "sb.U", 3));
	setResult("Variable", 18, "use_angstrom"); setResult("Value", 18, call("ij.Prefs.get", "sb.use_angstrom", true));
	
	setResult("Variable", 19, "auto_rescale"); setResult("Value", 19, call("ij.Prefs.get", "sb.auto_rescale", false));
	setResult("Variable", 20, "rescale_target_px"); setResult("Value", 20, call("ij.Prefs.get", "sb.rescale_target_px", 512));
	
	setResult("Variable", 21, "doExtraCmd"); setResult("Value", 21, call("ij.Prefs.get", "sb.doExtraCmd", false));
	setResult("Variable", 22, "extraCmd"); setResult("Value", 22, call("ij.Prefs.get", "sb.extraCmd", "run('Enhance Contrast', 'saturated=0.35');"));

	// FEI CROP SCALEBAR
	setResult("Variable", 23, "FEIaddSB"); setResult("Value", 23, call("ij.Prefs.get", "sb.FEIaddSB", true));
	setResult("Variable", 24, "FEIdoCrop"); setResult("Value", 24, call("ij.Prefs.get", "sb.FEIdoCrop", true));
	setResult("Variable", 25, "FEIshowMeta"); setResult("Value", 25, call("ij.Prefs.get", "sb.FEIshowMeta", false));
	setResult("Variable", 26, "FEIdoExtraCmd"); setResult("Value", 26, call("ij.Prefs.get", "sb.FEIdoExtraCmd", false));
	setResult("Variable", 27, "FEIextraCmd"); setResult("Value", 27, call("ij.Prefs.get", "sb.FEIextraCmd", "run('Enhance Contrast', 'saturated=0.35');"));

	IJ.renameResults("EMScaleBarToolsParameters");
	restoreResultsWindow();
}

function importEMScaleBarToolsParams() {
	storeResultsWindow();

	// LOAD PARAMETERS FROM FILE TO RESULTS TABLE
	// From the example here: https://imagej.nih.gov/ij/macros/Import_Results_Table.txt
	lineseparator = "\n";
	cellseparator = ",\t";
	
	// copies the whole RT to an array of lines
	lines=split(File.openAsString(File.openDialog("")), lineseparator);
	
	// recreates the columns headers
	labels=split(lines[0], cellseparator);
	if (labels[0]==" ")
		k=1; // it is an ImageJ Results table, skip first column
	else
		k=0; // it is not a Results table, load all columns
	for (j=k; j<labels.length; j++)
		setResult(labels[j],0,0);
	
	// dispatches the data into the new RT
	run("Clear Results");
	for (i=1; i<lines.length; i++) {
		items=split(lines[i], cellseparator);
			for (j=k; j<items.length; j++)
	   		setResult(labels[j],i-1,items[j]);
	}
	updateResults();

	// Update internal parameters based on loaded values
	for (i = 0; i < nResults; i++) {
		call("ij.Prefs.set", "sb."+Table.getString("Variable", i), Table.getString("Value", i))
	}
	
	IJ.renameResults("EMScaleBarToolsParameters_loaded");
	restoreResultsWindow();
	
	// OK dialog, asking to reload toolset to update variables
	Dialog.create("Please reload EMScaleBarTools");
	Dialog.addMessage("Please reload EMScaleBarTools to update the imported values. Select 'EMScaleBarTools' again from the 'More Tools >>' menu.", 12);
	Dialog.addHelp("https://github.com/lukmuk/em-scalebartools");
	Dialog.show();
}

// Help Menu
function HelpMenu() {
	Dialog.create("About EMScaleBarTools (Laptop edition)");
	about="------------------------ EMScaleBarTools --------------------------";
	about= about+"\nThe \"EMScaleBarTools\" toolset allows drawing of scale bars based on the relative image size.";
	about= about+"\nSEM images from Thermo Fisher Scientific (TFS)/FEI are often saved with a data bar which can be cropped.";
	about= about+"\nFor scaling FEI/TFS SEM images, the plugin \"SEM FEI metadata scale\" is required:";
	about= about+"\nLink: https://imagej.net/plugins/imbalence";
	about= about+"\nClick on the \"Help\" button below to open the Github repository for more information.";
	about= about+"\nI hope you can find use in \"EMScaleBarTools\"! :-)";
	about=about + "\n---------------------------------------------------------------------------------";
	about= about+"\nShort documentation:";
	about=about+"\n";
	about= about+"\n- \"QuickScaleBar\" tool: Creates a scale bar on a scaled image. Right click to open the options menu.";
	about= about+"\n- \"FEI Crop Scalebar\": Use it on FEI/TFS tiff files to crop data bar and add a scale bar based on QSB settings.";
	about= about+"\n- \"Move Overlay\" tool: Enables fine-tuning of overlays (i.e.) scale bar position by mouse dragging.";
	about= about+"\n- \"Remove Overlay\" tool: Remove all overlays from the image, including the scale bar.";
	about= about+"\n- \"Misc. Functions\" menu: Drop-down menu with miscellaneous functions:";
	about= about+"\n       \"Set pixel size and unit\": Scale image based on pixel size and unit.";
	about= about+"\n       \"Set voxel size and unit\": Scale image based on voxel size (3D) and unit. Allows to set x, y, and z individually (anisotropic).";
	about= about+"\n       \"Set image width and unit\": Scale image based on image width and unit.";
	about= about+"\n       \"Correct for tilted perspective\": Correct pixel size and/or re-scale image in vertical direction to account for tilted perspective.";
	about= about+"\n       \"Calculate electron wavelength\": Calculate relativistic de Broglie-wavelength from an electron energy.";
	about= about+"\n       \"Export/Import scale-bar parameters: Export creates a Fiji table that can be saved as csv and loaded with Import.";
	about= about+"\n       \"Edit source code\": Opens the source code in the editor.";
	about= about+"\n       \"Preferences\": Change some preferences for EMScaleBarTools.";
	about= about+"\n       \"Help\": Show help dialog.";
	about=about + "\n---------------------------------------------------------------------------------";
	about= about+"\nDefault hotkeys:";
	about=about+"\n";
	about= about+"\n- \"Save As PNG... [ p ]\": Save image as PNG.";
	about= about+"\n- \"Save As SVG... [ s ]\": Save image as SVG. Reqires BioVoxxel Figure Tools.";
	about= about+"\n- \"Save As JPEG... [ j ]\": Save image as JPEG, prompts for compression factor. Do not use in publications.";
	about= about+"\n- \"Copy to system... [ c ]\": Copy current image to system clipboard. Will re-scale copied simage if 'Auto re-scale images' is enabled.";
	about= about+"\n- \"Switch positions [ t ]\": Switch scale bar and label positions.";
	about= about+"\nNumber bar:";
	about= about+"\n- 5: Add/remove scale bar. Use with ALT key pressed to invert black/white color.";
	about= about+"\n- 6: Move scale bar to (1) Lower left, (3) lower right, (7) upper left, (9) upper right.";
	about= about+"\n- 3, 4: De-/Increase scale-bar size. Use with ALT key pressed to enter a scaling factor.";
	about= about+"\n- 1, 2: De-/Increase scale-bar length. Use with ALT key pressed to enter a specific length.";
	about= about+"\n- 7: Reset scale bar to scaling factor 1.0 and lower-right position.";
	about= about+"\n- 8: Open \"QuickScaleBar\" tool options menu.";
	about=about + "\n---------------------------------------------------------------------------------";
	about=about +"\nVersion: "+version+"";
	about=about +"\nAuthor: Lukas Gr"+fromCharCode(0x00FC)+"newald, "+date+", https://github.com/lukmuk/em-scalebartools";

	Dialog.addMessage(about);
	Dialog.addHelp("https://github.com/lukmuk/em-scalebartools");
	Dialog.show();
}	
