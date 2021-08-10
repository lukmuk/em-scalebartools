macro "Convert Image to Icon..." {
  if (bitDepth!=8 || getWidth>16 || getHeight>16)
     exit("This macro requires an 8-bit image no larger than 16x16");
  Dialog.create("Image 2 Tool");
  Dialog.addString("Tool name", "myTool");
  Dialog.addCheckbox("Transparent Color", true);
  Dialog.addNumber("Value", 0);
  Dialog.show();
  mytool = Dialog.getString();
  allPixels = !Dialog.getCheckbox();
  transparent = Dialog.getNumber();
  getLut(r,g,b);
  getRawStatistics(area, mean, min, max);
  ts='macro "'+mytool+' Tool - ';
  for (i=0; i<=max; i++) {
      if (allPixels || i!=transparent) {
          r2=floor(r[i]/256*16);
          g2=floor(g[i]/256*16);
          b2=floor(b[i]/256*16);
          color = "C"+toHex(r2)+toHex(g2)+toHex(b2);
          if (!endsWith(ts, color)) ts=ts+color;
          for (x=0; x<getWidth; x++) {
              for (y=0; y<getHeight; y++) {
                  if (getPixel(x,y)==i)
                      ts=ts+"D"+toHex(x)+toHex(y);
              }
          }
      }
  }
  ts=ts+'"{\n\n}';
  macrodir = getDirectory("macros");
  if (!endsWith(mytool,".txt")) mytool = mytool+".txt";
  f = File.open(macrodir+mytool);
  print (f, ts);
  File.close(f);
  open(macrodir+mytool);
}