// Written by https://github.com/lukmuk
// 2021/08
// This macro can be used in conjunction with FEI/Thermo Fisher Scientific SEM/FIB images.
// It will crop the infobar, process the image (see process_image() function) and add a scalebar with sensible size.

// ##################
// ### USER INPUT ###
// ##################

//	SCALEBAR:
sb_hfac = 0.02; // height of sb: (sb_hfac * image_height) in pixels 
sb_wfac = 0.2;  // width of sb: (sb_wfac * scaled image_width), will be rounded to closest "vals" array value
sb_fsfac = 2;   // fontsize: (sb_fsfac * sb_hfac) in pixels, i.e. factor of sb_hfac
sb_col = 'Black'; //font color
sb_bg = 'White'; //Background color, choose 'None' for no background
sb_loc = 'Lower Right'; //Position

//Switch units automatically by factor U:
//E.g. below 3 µm, scale will be set to U*1e3=3000 nm
//E.g. Above U*1e3=3000 nm, scale will be set to 3 µm, etc.  
U = 3;

//	IMAGE PROCESSING
function process_image() {
	//Default: Simple Auto CB, then 8-bit
	run("Enhance Contrast", "saturated=0.35");
	//run('8-bit');

	//E.g. bin 2 average, auto CB with histogram equalization, then 8-bit and viridis LUT
	/*
	run("Bin...", "x=2 y=2 bin=Average");
	run("Enhance Contrast", "saturated=0.35 equalize");
	run("mpl-viridis");
	run('8-bit');
	*/
}

// #########################
// ### END OF USER INPUT ###
// #########################

//Get image size in pixels
w = getWidth();
h = getHeight();

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

//Scale with "EM tool" script by IMBalENce
//https://imagej.net/plugins/imbalence

run("SEM FEI metadata Scale");

// Run image processing
process_image();

//Get scaled image size
getPixelSize(unit, pw, ph);
imw = getWidth()*pw;

//Switch units: nm -> µm
if(imw >= U*1e3 && (unit == 'nm')){
	setVoxelSize(1e-3*pw, 1e-3*ph, 1, fromCharCode(0181)+'m');
	//Update pixel size variables
	getPixelSize(unit, pw, ph);
	imw = getWidth()*pw;
}

//Switch units: µm -> nm
if(imw <= U && (unit == fromCharCode(0181)+'m')){
	setVoxelSize(1e3*pw, 1e3*ph, 1, 'nm');
	//Update pixel size variables
	getPixelSize(unit, pw, ph);
	imw = getWidth()*pw;
}


//Set height of scalebar
sb_h = round(sb_hfac*getHeight());
sb_fs = sb_h * sb_fsfac;

//Set width of scalebar
//Searches closest value from vals array to find suitable sb width
vals = newArray(1, 2, 5, 10, 20, 50, 100, 200, 250, 500, 1000, 2000, 5000, 10000);

//Get initial size of scalebar as percentage of image width
sb_w = round(sb_wfac*imw);

//Find next smaller value to sb_w in vals
index = 0;
for (i=0; i<vals.length; i++)
	if(sb_w > vals[i])
		index = i;
		continue;
	break;

//Run scale bar command
run("Scale Bar...", "width="+vals[index]+" height="+sb_h+" font="+sb_fs+" color="+sb_col+" background="+sb_bg+" location=["+sb_loc+"] bold overlay");