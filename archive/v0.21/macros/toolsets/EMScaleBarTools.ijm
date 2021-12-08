/*
EMScaleBarTools is a suite of small functions to add a scale bar with reasonable size to a scaled image.
It was developed with electron microscopy in mind and therefore the unit range spans (currently) only from m to pm.

Installation:
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
* Author: Lukas Gruenewald, 11/2021, https://github.com/lukmuk/em-scalebartools

*/

// Initalize variables or recover currrent values from presets
var hfac = call("ij.Prefs.get", "sb.hfac", 0.02); // default 0.02
var sf = call("ij.Prefs.get", "sb.sf", 1); // default 1
var wfac = call("ij.Prefs.get", "sb.wfac", 0.2);  // default 0.2
var fsfac = call("ij.Prefs.get", "sb.fsfac", 3);  // default 2
var col = call("ij.Prefs.get", "sb.col", "Black");  // default "Black"
var bgcol = call("ij.Prefs.get", "sb.bg", "White");  // default "White"
var loc = call("ij.Prefs.get", "sb.loc", "Lower Right");  // default "Lower Right"

var bold = call("ij.Prefs.get", "sb.bold", true); //default true
var overlay = call("ij.Prefs.get", "sb.overlay", true); //default true
var hide = call("ij.Prefs.get", "sb.hide", false); //default false
var serif = call("ij.Prefs.get", "sb.serif", false); //default false

var sb_size_ref = call("ij.Prefs.get", "sb.sb_size_ref", "Larger"); //default "Larger"

var auto_unit_switching = call("ij.Prefs.get", "sb.auto_unit_switching", true); //default true
var auto_unit_ref = call("ij.Prefs.get", "sb.auto_unit_ref", "Width"); //default false
var U = call("ij.Prefs.get", "sb.U", 3); // default 3

var auto_rescale = call("ij.Prefs.get", "sb.auto_rescale", false); //default false
var rescale_target_px = call("ij.Prefs.get", "sb.rescale_target_px", 512); //default 512
//var rescale_create = call("ij.Prefs.get", "sb.rescale_create", true); //default true

var doExtraCmd = call("ij.Prefs.get", "sb.doExtraCmd", false); //default false
var extraCmd = call("ij.Prefs.get", "sb.extraCmd", "run('Enhance Contrast', 'saturated=0.35');"); //default "run('Enhance Contrast', 'saturated=0.35');"

//FEI CROP SCALEBAR
var FEIdoCrop = call("ij.Prefs.get", "sb.FEIdoCrop", true); //default true
var FEIuseList = call("ij.Prefs.get", "sb.FEIuseList", false); //default false
var FEIshowMeta = call("ij.Prefs.get", "sb.FEIshowMeta", false); //default false
var FEIdoExtraCmd = call("ij.Prefs.get", "sb.FEIdoExtraCmd", false); //default false
var FEIextraCmd = call("ij.Prefs.get", "sb.FEIextraCmd", "run('Enhance Contrast', 'saturated=0.35');"); //default "run('Enhance Contrast', 'saturated=0.35');"

//REMOVE OVERLAYS TOOL
//var doDeleteAll = call("ij.Prefs.get", "sb.doDeleteAll", true); //default true

//var restore_defaults = call("ij.Prefs.get", "sb.restore_defaults", false); //default false

// --------------------------------------------- //
// --------------- QuickScaleBar --------------- //
// ------------------ +options ----------------- //

macro "QuickScaleBar Action Tool - C000D0eD0fD1eD1fD21D22D23D24D25D26D2aD2bD2eD2fD31D36D3bD3eD3fD41D46D4bD4eD4fD51D56D5bD5eD5fD61D66D6bD6eD6fD71D72D76D77D78D79D7aD7bD7eD7fD8eD8fD91D92D93D94D95D96D97D98D99D9aD9bD9eD9fDa1Da6DabDaeDafDb1Db6DbbDbeDbfDc1Dc6DcbDceDcfDd1Dd6DdbDdeDdfDe2De3De4De5De7De8De9DeaDeeDefDfeDffC000C111C222C333C444C555C666C777C888C999CaaaCbbbCcccCdddCeeeCfffD00D01D02D03D04D05D06D07D08D09D0aD0bD0cD0dD10D11D12D13D14D15D16D17D18D19D1aD1bD1cD1dD20D27D28D29D2cD2dD30D32D33D34D35D37D38D39D3aD3cD3dD40D42D43D44D45D47D48D49D4aD4cD4dD50D52D53D54D55D57D58D59D5aD5cD5dD60D62D63D64D65D67D68D69D6aD6cD6dD70D73D74D75D7cD7dD80D81D82D83D84D85D86D87D88D89D8aD8bD8cD8dD90D9cD9dDa0Da2Da3Da4Da5Da7Da8Da9DaaDacDadDb0Db2Db3Db4Db5Db7Db8Db9DbaDbcDbdDc0Dc2Dc3Dc4Dc5Dc7Dc8Dc9DcaDccDcdDd0Dd2Dd3Dd4Dd5Dd7Dd8Dd9DdaDdcDddDe0De1De6DebDecDedDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfd" {
	addScalebar();
}

macro "QuickScaleBar Action Tool Options" {

	//Options dialog
	Dialog.create("QuickScaleBar tool options");

	//Choices for some dialog options
	locs = newArray("Upper Right", "Lower Right", "Lower Left", "Upper Left", "At Selection");
	colors = newArray("White", "Black", "Gray", "Red", "Green", "Blue");
	colors_bg = newArray("None", "White", "Black", "Gray");
	rots = newArray("Rotate 90 Degrees Left", "Rotate 90 Degrees Right");
	sb_size_refs = newArray("Larger", "Smaller", "Width", "Height");
	auto_unit_refs = newArray("Width", "Height", "Both");
	
	//Dialog.addMessage("Scalebar appearance", 15);
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
	//Dialog.addMessage("Advanced settings:", 15);
	Dialog.addCheckbox("Auto unit-switching", auto_unit_switching);
	Dialog.addToSameRow();
	Dialog.addChoice("Check:", auto_unit_refs, auto_unit_ref);
	Dialog.addToSameRow();
	Dialog.addNumber("Unit factor: ", U);
	Dialog.addCheckbox("Auto re-scale images", auto_rescale);
	Dialog.addToSameRow();
	Dialog.addNumber("Min. height/width (pixels): ", rescale_target_px);
	//Dialog.addToSameRow();
	//Dialog.addCheckbox("Create window", rescale_create);
	Dialog.addCheckbox("Run custom macro commands", doExtraCmd);
	Dialog.addString("Custom macro commands:", extraCmd, 70);
	//Dialog.addCheckbox("Restore default settings", restore_defaults);
	
	Dialog.addHelp("https://github.com/lukmuk/em-scalebartools");
	Dialog.show();
	
	//Grab values from UI
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
	
	auto_rescale= Dialog.getCheckbox();
	rescale_target_px = Dialog.getNumber();
	
	doExtraCmd = Dialog.getCheckbox();
	extraCmd = Dialog.getString(); 
	
	//rescale_create = Dialog.getCheckbox();

	//Check if defaults should be restored
	//restore_defaults = Dialog.getCheckbox();
	//print(restore_defaults);
	
	// store updated values for future use
	call("ij.Prefs.set", "sb.hfac", hfac); // default 0.02
	call("ij.Prefs.set", "sb.sf", sf); // default 1
	call("ij.Prefs.set", "sb.wfac", wfac);  // default 0.2
	call("ij.Prefs.set", "sb.fsfac", fsfac);  // default 2
	call("ij.Prefs.set", "sb.col", col);  // default "Black"
	call("ij.Prefs.set", "sb.bg", bgcol);  // default "White"
	call("ij.Prefs.set", "sb.loc", loc);  // default "Lower Right"
	call("ij.Prefs.set", "sb.bold", bold); //default true
	call("ij.Prefs.set", "sb.overlay", overlay); //default true
	call("ij.Prefs.set", "sb.serif", serif); //default false
	call("ij.Prefs.set", "sb.hide", hide); //default false
	call("ij.Prefs.set", "sb.sb_size_ref", sb_size_ref); //default false
	call("ij.Prefs.set", "sb.auto_unit_switching", auto_unit_switching);  // default true
	call("ij.Prefs.set", "sb.auto_unit_ref", auto_unit_ref);  // default "Width"
	call("ij.Prefs.set", "sb.U", U);  // default 3
	call("ij.Prefs.set", "sb.auto_rescale", auto_rescale);  // default false
	call("ij.Prefs.set", "sb.rescale_target_px", rescale_target_px);  // default 512
	//call("ij.Prefs.set", "sb.rescale_create", rescale_create);  // default true
	call("ij.Prefs.set", "sb.doExtraCmd", doExtraCmd);
	call("ij.Prefs.set", "sb.extraCmd", extraCmd);

	/*
	//restore default settings if restore_defaults
	if(restore_defaults) {
		call("ij.Prefs.set", "sb.hfac", 0.02); // default 0.02
		call("ij.Prefs.set", "sb.wfac", 0.2);  // default 0.2
		call("ij.Prefs.set", "sb.fsfac", 2);  // default 2
		call("ij.Prefs.set", "sb.col", "Black");  // default "Black"
		call("ij.Prefs.set", "sb.bg", "White");  // default "White"
		call("ij.Prefs.set", "sb.loc", "Lower Right");  // default "Lower Right"
		call("ij.Prefs.set", "sb.bold", true); //default true
		call("ij.Prefs.set", "sb.overlay", true); //default true
		call("ij.Prefs.set", "sb.serif", false); //default false
		call("ij.Prefs.set", "sb.hide", false); //default false
		call("ij.Prefs.set", "sb.auto_unit_switching", true);  // default true
		call("ij.Prefs.set", "sb.U", 3);  // default 3
		call("ij.Prefs.set", "sb.auto_rescale", false);  // default false
		call("ij.Prefs.set", "sb.rescale_target_px", 512);  // default 512
		//call("ij.Prefs.set", "sb.rescale_create", rescale_create);  // default true
		call("ij.Prefs.set", "sb.restore_defaults", false);  // default false
	}
	*/
}

// --------------------------------------------- //
// ------------- FEI Crop Scalebar ------------- //
// --------------------------------------------- //

macro "FEI Crop Scalebar Action Tool - C000D03D04D05D06D07D08D09D0aD0bD0cD13D17D23D27D33D37D43D47D73D74D75D76D77D78D79D7aD7bD7cD83D87D8cD93D97D9cDa3Da7DacDb3Db7DbcDe3De4De5De6De7De8De9DeaDebDecC000C111C222C333C444C555C666C777C888C999CaaaCbbbCcccCdddCeeeCfffD00D01D02D0dD0eD0fD10D11D12D14D15D16D18D19D1aD1bD1cD1dD1eD1fD20D21D22D24D25D26D28D29D2aD2bD2cD2dD2eD2fD30D31D32D34D35D36D38D39D3aD3bD3cD3dD3eD3fD40D41D42D44D45D46D48D49D4aD4bD4cD4dD4eD4fD50D51D52D53D54D55D56D57D58D59D5aD5bD5cD5dD5eD5fD60D61D62D63D64D65D66D67D68D69D6aD6bD6cD6dD6eD6fD70D71D72D7dD7eD7fD80D81D82D84D85D86D88D89D8aD8bD8dD8eD8fD90D91D92D94D95D96D98D99D9aD9bD9dD9eD9fDa0Da1Da2Da4Da5Da6Da8Da9DaaDabDadDaeDafDb0Db1Db2Db4Db5Db6Db8Db9DbaDbbDbdDbeDbfDc0Dc1Dc2Dc3Dc4Dc5Dc6Dc7Dc8Dc9DcaDcbDccDcdDceDcfDd0Dd1Dd2Dd3Dd4Dd5Dd6Dd7Dd8Dd9DdaDdbDdcDddDdeDdfDe0De1De2DedDeeDefDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdDfeDff" {
	runMacro("FEI_Crop_Scalebar.ijm");
}

macro "FEI Crop Scalebar Action Tool Options" {
	// options dialog
	Dialog.create("FEI Crop Scalebar tool options");
	Dialog.addCheckbox("Crop data bar", FEIdoCrop);
	Dialog.addCheckbox("Use list from code for cropping value (legacy option)", FEIuseList);
	Dialog.addCheckbox("Show metadata in log window", FEIshowMeta);
	Dialog.addCheckbox("Run custom macro commands", FEIdoExtraCmd);
	Dialog.addString("Custom macro commands:", FEIextraCmd, 30);
	Dialog.addHelp("https://github.com/lukmuk/em-scalebartools");
	Dialog.show();

	// grab values
	FEIdoCrop = Dialog.getCheckbox();
	FEIuseList = Dialog.getCheckbox();
	FEIshowMeta = Dialog.getCheckbox();
	FEIdoExtraCmd = Dialog.getCheckbox();
	FEIextraCmd = Dialog.getString();

	// store updated values
	call("ij.Prefs.set", "sb.FEIdoCrop", FEIdoCrop);
	call("ij.Prefs.set", "sb.FEIuseList", FEIuseList);
	call("ij.Prefs.set", "sb.FEIshowMeta", FEIshowMeta);
	call("ij.Prefs.set", "sb.FEIdoExtraCmd", FEIdoExtraCmd);
	call("ij.Prefs.set", "sb.FEIextraCmd", FEIextraCmd);
}


// --------------------------------------------- //
// ------------- Move Overlay tool ------------- //
// --------------------------------------------- //
//Copied from: https://imagej.nih.gov/ij/source/macros/Overlay%20Editing%20Tools.txt

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

/* Under development, might replace 
macro "Remove Overlays Tool - C037R00ddB58Cd00L0088L0880" { 
	 if(doDeleteAll) run("Remove Overlay");
	 else {
	 	  getCursorLoc( x, y, z, flags ); 
		  selectNone( ); 
		  call( 'ij.Prefs.set', 'overlaytoolset.selected', '' ); 
		  id = Overlay.indexAt( x, y ); 
		  if( id != - 1 ) { 
		  showWarning = call( "ij.Prefs.get", "overlaytoolset.deletewarning", true ); 
		  mustDelete = true; 
		  if( showWarning == true ) { 
	      Dialog.create( "Delete ROI tool options" ); 
	      Dialog.addCheckbox( "Delete this ROI", true ); 
	      Dialog.addCheckbox( "Show this dialog", showWarning ); 
	      Dialog.show( );  
	      mustDelete = Dialog.getCheckbox( ); 
	      showWarning = Dialog.getCheckbox( ); 
	      call( "ij.Prefs.set", "overlaytoolset.deletewarning", showWarning ); 
    	  } 
    	if( mustDelete ) Overlay.removeSelection( id ); 
  		} 
	 }
}

macro "Remove Overlays Tool Options" {
	Dialog.create("Remove Overlays options");
	Dialog.addCheckbox("Delete all overlays on click", doDeleteAll);
	Dialog.addHelp("https://github.com/lukmuk/em-scalebartools");
	Dialog.show();

	doDeleteAll = Dialog.getCheckbox();
	call("ij.Prefs.set", "sb.doDeleteAll", doDeleteAll);	
} 
*/

// Drop down menu tool

var mCmds = newMenu("Misc. Functions Menu Tool", newArray("Set pixel size and unit", "Help"));
macro "Misc. Functions Menu Tool - C037T3f18?"{
	cmd = getArgument();
	if (cmd!="-" && cmd == "Set pixel size and unit") setPxAndUnit();
	if (cmd!="-" && cmd == "Help") HelpMenu();
}
	

// --------------------------------------------- //
// ------------------ HOTKEYS ------------------ //
// --------------------------------------------- //

//JPEG saving, please do not use for publications...
macro "Save As JPEG... [j]" {
	quality = call("ij.plugin.JpegWriter.getQuality");
	quality = getNumber("JPEG quality (0-100):", quality);
	run("Input/Output...", "jpeg="+quality);
	saveAs("Jpeg");
}

//PNG saving
macro "Save As PNG... [p]" {
	saveAs("PNG");
}

//"Copy to system shortcut" to quickly copy to other programs
macro "Copy to system... [c]" {
	run("Copy to System");
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
	if (doExtraCmd) eval(extraCmd);

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

	// Multiply height with scaling factor
	height = height * sf;

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

//Helper function for overlay tools
//from: https://imagej.nih.gov/ij/source/macros/Overlay%20Editing%20Tools.txt
function selectNone( ) { 
  Overlay.removeRois( 'ToolSelectedOverlayElement' ); 
  Overlay.show; 
  //call( 'ij.Prefs.set', 'overlaytoolset.selected', '' ); 
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

// Set pixel size and unit...
function setPxAndUnit() {
	// Grab pixel size and unit from current image
	getPixelSize(u, pw, ph);
	
	//Options dialog
	Dialog.create("Set pixel size and unit");

	//Special character list
	//Angstrom, Angstrom-1, nm-1
	special = newArray(fromCharCode(0x0212b), fromCharCode(0x0212b, 0x0207b, 0x000b9), 'nm'+fromCharCode(0x0207b, 0x000b9));
	
	//Dialog.addMessage("Scalebar appearance", 15);
	Dialog.addNumber("Pixel size: ", pw);
	Dialog.addString("Unit: ", u);

	Dialog.addCheckbox("Use special unit: ", false);
	Dialog.addToSameRow();
	Dialog.addChoice("", special, fromCharCode(0x0212b));
	//Dialog.addString("Custom string:", "", 20);
	
	Dialog.addHelp("https://github.com/lukmuk/em-scalebartools");
	Dialog.show();
	
	//Grab values from UI
	pw_new = Dialog.getNumber();
	ph_new = pw_new;
	u_new = Dialog.getString();
	//custom_string = Dialog.getString();

	UseUnitFromMenu = Dialog.getCheckbox();
	if(UseUnitFromMenu) {
		u_new = Dialog.getChoice();
		//if(eval(custom_string) != "") u_new = eval(custom_string);
	}

	//setVoxelSize(width, height, depth, unit);
	setVoxelSize(pw_new, ph_new, 1, u_new);
}

// Help Menu
function HelpMenu() {
	Dialog.create("About EMScaleBarTools");
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
	about= about+"\n- \"QuickScaleBar\" (QSB) tool: Creates a scale bar on a scaled image. Right click to open the options menu.";
	about= about+"\n- \"FEI Crop Scalebar\": Use it on FEI/TFS tiff files to crop data bar and add a scale bar based on QSB settings.";
	about= about+"\n- \"Move Overlay\" tool: Enables fine-tuning of overlays (i.e.) scale bar position by mouse dragging.";
	about= about+"\n- \"Remove Overlay\" tool: Remove all overlays from the image, including the scale bar.";
	about= about+"\n- \"Misc. Functions\" menu: Drop-down menu with miscellaneous functions:";
	about= about+"\n       \"Set pixel size and unit:\" function: Scale image based on pixel size and unit.";
	about=about + "\n---------------------------------------------------------------------------------";
	about= about+"\nDefault hotkeys:";
	about=about+"\n";
	about= about+"\n- \"Save As JPEG... [ j ]\": Save image as JPEG, prompts for compression factor.";
	about= about+"\n- \"Save As PNG... [ p ]\": Save image as PNG.";
	about= about+"\n- \"Copy to system... [ c ]\": Copy current image to system clipboard.";
	about=about + "\n---------------------------------------------------------------------------------";
	about=about +"\nVersion: 0.21";
	about=about +"\nAuthor: Lukas Gr"+fromCharCode(0x00FC)+"newald, 11/2021, https://github.com/lukmuk/em-scalebartools";

	Dialog.addMessage(about);
	Dialog.addHelp("https://github.com/lukmuk/em-scalebartools");
	Dialog.show();
}	
