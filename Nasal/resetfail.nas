var enginefirereset = func {								
  if (getprop("/engines/engine[0]/on-fire") == 1) {						
								setprop("engines/engine[0]/on-fire", 0);
								setprop("engines/engine[0]/extinguished", 0);
								setprop("engines/engine[0]/extinguisher", 0);                           
}							   
  if (getprop("/engines/engine[1]/on-fire") == 1) {						
								setprop("engines/engine[1]/on-fire", 0);
								setprop("engines/engine[1]/extinguished", 0);
								setprop("engines/engine[1]/extinguisher", 0);                           
}							   
  if (getprop("/engines/engine[2]/on-fire") == 1) {						
								setprop("engines/engine[2]/on-fire", 0);
								setprop("engines/engine[2]/extinguished", 0);
								setprop("engines/engine[2]/extinguisher", 0);                           
}	
  if (getprop("/engines/engine[3]/on-fire") == 1) {						
								setprop("engines/engine[3]/on-fire", 0);
								setprop("engines/engine[3]/extinguished", 0);
								setprop("engines/engine[3]/extinguisher", 0);                           
}
}			