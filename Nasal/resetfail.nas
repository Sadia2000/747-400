var enginefirereset = func {								
  if (getprop("/engines/engine[0]/smoke") == 1) {						
								setprop("engines/engine[0]/on-fire", 0);
								setprop("engines/engine[0]/extinguished", 0);
								setprop("engines/engine[0]/extinguisher", 0);    
								setprop("engines/engine[0]/extinguisher-A", 0); 		
								setprop("engines/engine[0]/extinguisher-B", 0); 
								setprop("engines/engine[0]/extinguisher-arm", 0); 								
								setprop("engines/engine[0]/smoke", 0);     								
}							   
  if (getprop("/engines/engine[1]/smoke") == 1) {						
								setprop("engines/engine[1]/on-fire", 0);
								setprop("engines/engine[1]/extinguished", 0);
								setprop("engines/engine[1]/extinguisher", 0); 
								setprop("engines/engine[1]/extinguisher-A", 0); 		
								setprop("engines/engine[1]/extinguisher-B", 0); 
								setprop("engines/engine[1]/extinguisher-arm", 0); 
								setprop("engines/engine[1]/smoke", 0);  								
}							   
  if (getprop("/engines/engine[2]/smoke") == 1) {						
								setprop("engines/engine[2]/on-fire", 0);
								setprop("engines/engine[2]/extinguished", 0);
								setprop("engines/engine[2]/extinguisher", 0); 
								setprop("engines/engine[2]/extinguisher-A", 0); 		
								setprop("engines/engine[2]/extinguisher-B", 0);
								setprop("engines/engine[2]/extinguisher-arm", 0); 								
								setprop("engines/engine[2]/smoke", 0);  								
}	
  if (getprop("/engines/engine[3]/smoke") == 1) {						
								setprop("engines/engine[3]/on-fire", 0);
								setprop("engines/engine[3]/extinguished", 0);
								setprop("engines/engine[3]/extinguisher", 0); 
								setprop("engines/engine[3]/extinguisher-A", 0); 		
								setprop("engines/engine[3]/extinguisher-B", 0);
								setprop("engines/engine[3]/extinguisher-arm", 0);  								
								setprop("engines/engine[3]/smoke", 0);  								
}
}				
