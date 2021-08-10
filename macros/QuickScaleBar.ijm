// Written by https://github.com/lukmuk
// 2021/08
// This macro creates a scalebar with sensible size based on the image dimensions.

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

//AUTO-SCALE SMALL IMAGES
//Set to 1 to automatically scale small images to at least rescale_target_px width pixels
auto_rescale = 0;
rescale_target_px = 800;

// #########################
// ### END OF USER INPUT ###
// #########################

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

//Get scaled image size
getPixelSize(unit, pw, ph);
imw = getWidth()*pw;

// UNIT SWITCHING

//mm -> µm 
if(imw <= U && unit == "mm"){
	setVoxelSize(1E3*pw, 1E3*ph, 1, fromCharCode(0181)+'m');
	//Update pixel size variables
	getPixelSize(unit, pw, ph);
	imw = getWidth()*pw;
	//imh = getHeight()*ph;
}

//µm -> nm 
if(imw <= U && (unit == fromCharCode(0181)+'m' || unit == "microns")){
	setVoxelSize(1E3*pw, 1E3*ph, 1, "nm");
	//Update pixel size variables
	getPixelSize(unit, pw, ph);
	imw = getWidth()*pw;
	//imh = getHeight()*ph;
}


//nm -> Angstrom
if(imw <= U && (unit == 'nm')){
	setVoxelSize(1E+1*pw, 1E+1*ph, 1, fromCharCode(0x0212b));
	//Update pixel size variables
	getPixelSize(unit, pw, ph);
	imw = getWidth()*pw;
}

//Angstrom -> nm
if(imw >= U*1e1 && (unit == fromCharCode(0x0212b))) {
	setVoxelSize(1E-1*pw, 1E-1*ph, 1, 'nm');
	//Update pixel size variables
	getPixelSize(unit, pw, ph);
	imw = getWidth()*pw;
}

//nm -> µm
if(imw >= U*1e3 && (unit == 'nm')){
	setVoxelSize(1E-3*pw, 1E-3*ph, 1, fromCharCode(0181)+'m');
	//Update pixel size variables
	getPixelSize(unit, pw, ph);
	imw = getWidth()*pw;
}

//µm -> mm
if(imw >= U*1e3 && (unit == fromCharCode(0181)+'m' || unit == "microns")){
	setVoxelSize(1E-3*pw, 1E-3*ph, 1, 'mm');
	//Update pixel size variables
	getPixelSize(unit, pw, ph);
	imw = getWidth()*pw;
}


//Set height of scalebar
sb_h = round(sb_hfac*getHeight());
sb_fs = sb_h * sb_fsfac;

//Set width of scalebar
//Searches closest value from vals array to find sb width
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