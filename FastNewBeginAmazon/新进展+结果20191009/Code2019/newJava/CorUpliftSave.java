package uplifts;

import java.util.List;
import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.security.KeyStore.Entry;
import java.sql.Date;
import java.text.DateFormat;
import java.text.DecimalFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.TreeMap;

//type order:
//"lex_uplifts/lexp_study.txt", //0
//"lex_uplifts/lexp_romantic.txt",//1
//"lex_uplifts/lexp_friends.txt",//2
//"lex_uplifts/lexp_self.txt",//3	         
//"lex_uplifts/lexp_family.txt", //4
//"lex_uplifts/lexp_enter.txt",//5

//[DaySta] accumulated stress, stressful tweets, total tweets

//Function: find stressful intervals and stressful intervals impacted by uplifts, output measures (stress, topic)
public class CorUpliftSave {

	//Addition function0:getCharset
	private static String getCharset(String fileName) throws IOException{
        
        BufferedInputStream bin = new BufferedInputStream(new FileInputStream(fileName));  
        int p = (bin.read() << 8) + bin.read();  
        
        String code = null;  
        
        switch (p) {  
            case 0xefbb:  
                code = "UTF-8";  
                break;  
            case 0xfffe:  
                code = "Unicode";  
                break;  
            case 0xfeff:  
                code = "UTF-16BE";  
                break;  
            default:  
                code = "GBK";  
        }  
        return code;
	}
	
	//Function: [Not so useful] find stress intervals (with obvious positive or with almost no positive), and compare the few measures
	static void compareStress(int teenNum) throws IOException{	
			//threshold for identify the stress intervals or other intervals is individual (each person a threshold)
			//you not statistic all slides yet...(to do!)
			
			//initial threshold
			ArrayList<ArrayList<Double> > threAry = new ArrayList<ArrayList<Double> >();
			for(int k=0; k<teenNum; k++){
				ArrayList<Double> tmpAry = new ArrayList<Double>();
				for(int i=0; i<8; i++)
					tmpAry.add(0.0);
				threAry.add(tmpAry);
			}
					
			String typeID = "0";
			ArrayList<ArrayList<Double> > newAry = findSlide(threAry,0,typeID);//true threshold
			
			for(int i=0; i<5; i++){
				typeID = i+"";
				findSlide(newAry,1,typeID);
			}	
	}
	
	//Function: [Not so useful] find stress intervals
	static ArrayList<ArrayList<Double> > findSlide (ArrayList<ArrayList<Double> > threshAry, int flag, String typeID) throws IOException{		
		
		ArrayList<ArrayList<Double> > res = new ArrayList<ArrayList<Double>>();	
		
		//---------------------------------OUT1: 124 teens (all/small positive/big positive) slides (specific stress type)------------------------------------------------------------
		//5-1-0 124 each one average
		String allTeen = "E:\\TEST\\POSITIVE\\Pair\\allTeen"+typeID+".txt";	
		File allTeenFile = new File(allTeen);
		if(!allTeenFile.exists()){
			allTeenFile.createNewFile();
		}	
		FileWriter all_fw = new FileWriter(allTeenFile.getAbsoluteFile());
		BufferedWriter bw_all_pair = new BufferedWriter(all_fw);
		
		//5-1-1 124 each teen small
		String allTeenS = "E:\\TEST\\POSITIVE\\Pair\\allTeenSmall"+typeID+".txt";	
		File allTeenSFile = new File(allTeenS);
		if(!allTeenSFile.exists()){
			allTeenSFile.createNewFile();
		}	
		FileWriter all_small_fw = new FileWriter(allTeenSFile.getAbsoluteFile());
		BufferedWriter bw_teen_small = new BufferedWriter(all_small_fw);
		
		//5-1-2 124 each teen big
//		format: 
//				bw_teen_big.write(fileList[pos_file]+
//				" "+df.format(B_AVG1_s/BIG_NUM)+" "+df.format(B_AVG2_s/BIG_NUM)+" "+df.format(B_AVG_s/BIG_NUM)+
//				" "+df.format(B_ACC1_s/BIG_NUM)+" "+df.format(B_ACC2_s/BIG_NUM)+" "+df.format(B_ACC_s/BIG_NUM)+
//				" "+df.format(B_RMS1_s/BIG_NUM)+" "+df.format(B_RMS2_s/BIG_NUM)+
//				" "+df.format(B_SLOPE1/BIG_NUM)+" "+df.format(B_SLOPE2/BIG_NUM)+" "+df.format(B_PEAK/BIG_NUM)+
//				" "+df.format(B_AVG1_u/BIG_NUM)+" "+df.format(B_AVG2_u/BIG_NUM)+
//				" "+df.format(B_ACC1_u/BIG_NUM)+" "+df.format(B_ACC2_u/BIG_NUM)+
//				" "+df.format(B_RMS1_u/BIG_NUM)+" "+df.format(B_RMS2_u/BIG_NUM)+
//				" "+df.format(B_LEN1/BIG_NUM)+" "+df.format(B_LEN2/BIG_NUM)+" "+df.format(B_LEN/BIG_NUM)+"\r\n");
		
		String allTeenB = "E:\\TEST\\POSITIVE\\Pair\\allTeenBig"+typeID+".txt";	
		File allTeenFileB = new File(allTeenB);
		if(!allTeenFileB.exists()){
			allTeenFileB.createNewFile();
		}	
		FileWriter all_big_fw = new FileWriter(allTeenFileB.getAbsoluteFile());
		BufferedWriter bw_teen_big = new BufferedWriter(all_big_fw);
		//---------------------------------------------------------------------------------------------
		
		
		//---------------------OUT2: 124 all pair slides-----------------------------------------------------
		//5-2-0 124 all pairs
		//format: [average stress in phase1, average stress in phase2, accumulated stress in phase1, accumulated stress in phase2]
		//		  [RMS stress in phase1, RMS stress in phase2]
		//	      [slope in phase1, slope in phase2]
		//format: [UP the same as stress above]
		
		//bw_big_pair.write(AVG1_s+" "+AVG2_s+" "+ACC1_s+" "+ACC2_s+
		//		" "+RMS1_s+" "+RMS2_s+
		//		" "+SLOPE1+" "+SLOPE2+" "+PEAK+
		//		" "+AVG1_u+" "+AVG2_u+" "+ACC1_u+" "+ACC2_u+
		//		" "+RMS1_u+" "+RMS2_u+
		//		" "+LEN1 + " " + LEN2 + " " + LEN + "\r\n");
		
		String allPair = "E:\\TEST\\POSITIVE\\Pair\\allPair.txt";	
		File allPairFile = new File(allPair);
		if(!allPairFile.exists()){
			allPairFile.createNewFile();
		}	
		FileWriter all_pair_fw = new FileWriter(allPairFile.getAbsoluteFile());
		BufferedWriter all_pair_bw = new BufferedWriter(all_pair_fw);			
			
		//5-2-1 124 all pairs big  ---------------！！！！！！！！！！！！！！！！！！！！！！！！
		String allPairBig = "E:\\TEST\\POSITIVE\\Pair\\allPairBig.txt";	
		File allPairFileBig = new File(allPairBig);
		if(!allPairFileBig.exists()){
			allPairFileBig.createNewFile();
		}	
		FileWriter all_big_fw_pair = new FileWriter(allPairFileBig.getAbsoluteFile());
		BufferedWriter bw_big_pair = new BufferedWriter(all_big_fw_pair);
		
		//5-2-2 all pairs small ---------------！！！！！！！！！！！！！！！！！！！！！！！！
		String allPairSmall = "E:\\TEST\\POSITIVE\\Pair\\allPairSmall.txt";	
		File allPairFileSmall = new File(allPairSmall);
		if(!allPairFileSmall.exists()){
			allPairFileSmall.createNewFile();
		}	
		FileWriter all_small_fw_pair = new FileWriter(allPairFileSmall.getAbsoluteFile());
		BufferedWriter bw_small_pair = new BufferedWriter(all_small_fw_pair);
		
		//5-3 1)same type; 2)up or not (a-b;b-c;a-c)
		//format [5 stress type in phase 1][5 stress type in phase 2][5 stress type all phase][6 up type in phase 1]
		//[6 up type in phase 2][6 up type in all phase]
		String type1 = "E:\\TEST\\POSITIVE\\Pair\\COMPARE\\type.txt";	
		File type1File = new File(type1);
		if(!type1File.exists()){
			type1File.createNewFile();
		}	
		FileWriter type_fw = new FileWriter(type1File.getAbsoluteFile());
		BufferedWriter bw_type = new BufferedWriter(type_fw);
		
		//5-4 same type rate
		//1)same type; 2)up or not (a-b;b-c;a-c)
		//format [5 stress rate in phase 1][5 stress rate in phase 2][5 stress rate all phase][6 up rate in phase 1][6 up rate in phase 2][6 up rate in all phase]
		String typeRate = "E:\\TEST\\POSITIVE\\Pair\\COMPARE\\type_rate.txt";	
		File typeRateFile = new File(typeRate);
		if(!typeRateFile.exists()){
			typeRateFile.createNewFile();
		}	
		FileWriter rate_fw = new FileWriter(typeRateFile.getAbsoluteFile());
		BufferedWriter bw_rate = new BufferedWriter(rate_fw);
		//--------------------------------------------------------------------------------------
		
		DecimalFormat df = new DecimalFormat("#####0.0000");  
		
		String dirParseIn = "E:\\TEST\\POSITIVE\\smoothUp\\";//accumulated level per Day after regression
		File files2parse = new File(dirParseIn);
		if(files2parse.isDirectory()){
			
			String [] fileList = files2parse.list();
			
//			//find standard for all teen
//			ArrayList<Double> up_avgAllAry = new ArrayList<Double>();//up
//			ArrayList<Double> up_accAllAry = new ArrayList<Double>();//up			
//			ArrayList<Double> str_avgAllAry = new ArrayList<Double>();//str
//			ArrayList<Double> str_accAllAry = new ArrayList<Double>();//str
			
			for(int pos_file=0; pos_file<fileList.length; pos_file++){
				
				//find standard for current teen
				ArrayList<Double> up_avgAllAry = new ArrayList<Double>();//up
				ArrayList<Double> up_accAllAry = new ArrayList<Double>();//up			
				ArrayList<Double> str_avgAllAry = new ArrayList<Double>();//str
				ArrayList<Double> str_accAllAry = new ArrayList<Double>();//str
				
				ArrayList<Double> threAry = threshAry.get(pos_file);
				
				String PPath = dirParseIn+fileList[pos_file];
				
				//1-input positive			
				InputStreamReader isr = new InputStreamReader(new FileInputStream(PPath),getCharset(PPath));
				BufferedReader reader = new BufferedReader(isr);
				
				//1-2 input positive category
				String posiCatPath = PPath.replace("smoothUp", "upCateSta");
				InputStreamReader isrCateUp = new InputStreamReader(new FileInputStream(posiCatPath),getCharset(posiCatPath));
				BufferedReader up_cat_reader = new BufferedReader(isrCateUp);
				
				//2-input stress
				String SPath = PPath.replace("smoothUp", "smoothStr");
				InputStreamReader s_isr = new InputStreamReader(new FileInputStream(SPath),getCharset(SPath));
				BufferedReader s_reader = new BufferedReader(s_isr);
				
				//2-2 input stress category
				String strCatPath = PPath.replace("smoothUp", "CateSta");
				InputStreamReader isrCateStr = new InputStreamReader(new FileInputStream(strCatPath),getCharset(strCatPath));
				BufferedReader str_cat_reader = new BufferedReader(isrCateStr);
				
				//--------------------------------OUT 3: each teen a file: all pairs/values--------------------------------------
				//3-out put file for pair interval
				String PCombinePath = PPath.replace("smoothUp", "Pair\\intervalPair");	
				File PFile = new File(PCombinePath);
				if(!PFile.exists()){
					PFile.createNewFile();
				}	
				FileWriter fw = new FileWriter(PFile.getAbsoluteFile());
				BufferedWriter bw_pair = new BufferedWriter(fw);
				
				//4-output file for values in pair interval
				String SCombinePath = PPath.replace("smoothUp", "Pair\\valuePair");	
				File SFile = new File(SCombinePath);
				if(!SFile.exists()){
					SFile.createNewFile();
				}	
				FileWriter s_fw = new FileWriter(SFile.getAbsoluteFile());
				BufferedWriter bw_pair_value = new BufferedWriter(s_fw);
				//---------------------------------------------------------------------------------------------------------------
				
				//now read in...
				String line = "", s_line="", up_cat_line="", str_cat_line="";
				int tID = 0;
				double maxUp = 0, maxStr = 0, avgUp = 0, avgStr = 0, totalUp=0, totalStr=0, minUp = 0, minStr = 0;
				ArrayList<Double> upAry = new ArrayList<Double>();
				ArrayList<Double> strAry = new ArrayList<Double>();
				ArrayList<ArrayList<Integer>> upCateAry = new ArrayList<ArrayList<Integer>>();
				ArrayList<ArrayList<Integer>> strCateAry = new ArrayList<ArrayList<Integer>>();
				
				while((line = reader.readLine()) != null && (s_line = s_reader.readLine()) != null
						&& (up_cat_line = up_cat_reader.readLine())!= null 
						&&(str_cat_line = str_cat_reader.readLine()) != null){
					
					if(line.length()>0 && s_line.length()>0 && up_cat_line.length()>9 && str_cat_line.length()>0){
																		
						double p = Double.valueOf(line.toString());
						double s = Double.valueOf(s_line.toString());
						if(tID == 0){
							maxUp = p*(-1);
							minUp = p*(-1);
							maxStr = s;
							minStr = s;
						}						
						if(p*(-1)>maxUp) maxUp = p*(-1);
						if(p*(-1)<minUp) minUp = p*(-1);						
						if(s>maxStr) maxStr = s;
						if(s<minStr) minStr = s;
						
						String[] up_elem = up_cat_line.split(" ");
						String[] str_elem = str_cat_line.split(" ");
						ArrayList<Integer> upTmpAry = new ArrayList<Integer>();
						ArrayList<Integer> strTmpAry = new ArrayList<Integer>();
						for(int k=0; k<up_elem.length && k<6; k++){
							upTmpAry.add(Integer.parseInt(up_elem[k].toString()));
						}
						for(int k=0; k<str_elem.length && k<5; k++){
							strTmpAry.add(Integer.parseInt(str_elem[k].toString()));
						}										
						
						//to be add here: the http(3) 
						
						upCateAry.add(upTmpAry);
						strCateAry.add(strTmpAry);
						upAry.add(p);
						strAry.add(s);
						totalUp += p;
						totalStr += s;
						tID++;
											
					}
				}
				
				//statistic average for current teen:
				int ANUM = 0;
				int SMALL_NUM = 0;
				int BIG_NUM = 0;
				
				//SMALL
				double S_ACC1_s = 0, S_ACC2_s = 0, S_AVG1_s = 0, S_AVG2_s = 0, S_ACC_s = 0, S_AVG_s=0,
						   S_ACC1_u = 0, S_ACC2_u = 0, S_AVG1_u = 0, S_AVG2_u = 0,
						   S_RMS1_s = 0, S_RMS1_u = 0, S_RMS2_s = 0, S_RMS2_u = 0;
				double S_LEN1 = 0, S_LEN2 = 0, S_LEN = 0, S_PEAK  = 0, S_SLOPE1=0, S_SLOPE2=0;
				//BIG
				double B_ACC1_s = 0, B_ACC2_s = 0, B_AVG1_s = 0, B_AVG2_s = 0, B_ACC_s=0, B_AVG_s=0,
						   B_ACC1_u = 0, B_ACC2_u = 0, B_AVG1_u = 0, B_AVG2_u = 0,
						   B_RMS1_s = 0, B_RMS1_u = 0, B_RMS2_s = 0, B_RMS2_u = 0;
				double B_LEN1 = 0, B_LEN2 = 0, B_LEN = 0, B_PEAK  = 0, B_SLOPE1=0, B_SLOPE2=0;
				//ALL
				double A_ACC1_s = 0, A_ACC2_s = 0, A_AVG1_s = 0, A_AVG2_s = 0, A_AVG_s=0, A_ACC_s=0,
						   A_ACC1_u = 0, A_ACC2_u = 0, A_AVG1_u = 0, A_AVG2_u = 0,
						   A_RMS1_s = 0, A_RMS1_u = 0, A_RMS2_s = 0, A_RMS2_u = 0;
				double A_LEN1 = 0, A_LEN2 = 0, A_LEN = 0, A_PEAK  = 0, A_SLOPE1=0, A_SLOPE2=0;
					
				if(tID>10 && maxUp>0 && maxStr>0){//this teen posted more than 10 days..
										
					//1. regular
					avgUp = totalUp/tID;
					avgStr = totalStr/tID;				
					
					for(int i=0; i<upAry.size(); i++){

						double tmpUp = (-1)*(upAry.get(i)*(-1)-minUp)/(maxUp - minUp);//minUp>0, maxUp>0
						double tmpStr = (strAry.get(i)-minStr)/(maxStr - minStr);

						upAry.set(i, tmpUp);
						strAry.set(i, tmpStr);
					}
					
					//2. find pairs					
					for(int i =0; i<strAry.size(); i++){
						
						//2-1-find the big strWave
						while(i<strAry.size() && strAry.get(i)==0){//cut down empty
							i++;
						}
						
						double pre = 0;
						int a_pos = i, b_pos = i, c_pos = i;//a-find
						while(i<strAry.size() && strAry.get(i)>=pre && strAry.get(i)>0){//highest
							pre = strAry.get(i);
							i++;
						}
						
						if(i<strAry.size()){
							i--;
							if(strAry.get(i)>avgStr*1.5){//judge as valid high
								b_pos = i;//b-find
								i++;
								while(i<strAry.size() && strAry.get(i)<=pre){
									pre = strAry.get(i);									
									i++;
									if(pre == 0) break;
								}							
								if(i<strAry.size()){
									i--;
									c_pos = i;//c
									
									double preMax = strAry.get(b_pos), preMin = strAry.get(c_pos);									
									i++;
									//2-2-find the tailed small strWaves, identify a-b-c
									while(i<strAry.size()){
										if(strAry.get(i)==0) break;
										
										double tmpH = 0, tmpL = 0;
										while(i<strAry.size() && strAry.get(i)>=pre){
											pre = strAry.get(i);
											i++;
											if(pre == 0) break;//
										}
										if(i<strAry.size()){
											i--;
											tmpH = strAry.get(i);
											if(strAry.get(i)< preMax){
												i++;
												while(i<strAry.size() && strAry.get(i)<=pre){
													pre = strAry.get(i);													
													i++;
													if(pre == 0) break;
												}
												i--;
												tmpL = strAry.get(i);
												if(tmpL<=preMin && tmpH<preMax){
													preMin = tmpL;
													preMax = tmpH;
													c_pos = i;
													i++;
												}else
													{
														i = c_pos+1;
														break;
													}
											}else
												{
													i = c_pos+1;//
													break;
												}
										}else
											break;
									}//end small tails
																											
									//2-3-find corresponding positive values, and calculate
									if(!(a_pos>=0 && a_pos<strAry.size() && b_pos>=a_pos && b_pos < strAry.size()))
									{
										System.out.println("a-b-c error");
										break;
									}
									
									//add: part D....
									double ACC1_s = 0, ACC2_s = 0, AVG1_s = 0, AVG2_s = 0,
										   ACC1_u = 0, ACC2_u = 0, AVG1_u = 0, AVG2_u = 0,
										   RMS1_s = 0, RMS1_u = 0, RMS2_s = 0, RMS2_u = 0;
									ArrayList<Double> cur_upAry1 = new ArrayList<Double>();
									ArrayList<Double> cur_strAry1 = new ArrayList<Double>();
									ArrayList<Double> cur_upAry2 = new ArrayList<Double>();
									ArrayList<Double> cur_strAry2 = new ArrayList<Double>();	
									double num_up1=0, num_up2=0, num_str1=0, num_str2=0;
									
									for(int k=0;k<6;k++){
										cur_upAry1.add(0.0);//accumulated up during a-b
										cur_upAry2.add(0.0);//accumulated up during b-c
									}
									for(int k=0; k<5; k++){
										cur_strAry1.add(0.0);//accumulated stress during a-b
										cur_strAry2.add(0.0);//accumulated stress during b-c
									}
									
									int LEN1 = b_pos-a_pos+1, LEN2 = c_pos-b_pos, LEN = c_pos-a_pos+1;
									double PEAK  = strAry.get(b_pos);
									double SLOPE1=0, SLOPE2=0;
									
									//a-b
									for(int k=a_pos; k<=b_pos; k++){
										ACC1_s += strAry.get(k);
										ACC1_u += upAry.get(k);
										
										//category statistic for stress and up, respectively.. 
										for(int m=0; m<5; m++){
											double tmp_s = cur_strAry1.get(m);
											tmp_s += strCateAry.get(k).get(m);
											num_str1 += strCateAry.get(k).get(m);
											cur_strAry1.set(m, tmp_s);
										}
										for(int m=0; m<6; m++){
											double tmp_u = cur_upAry1.get(m);
											tmp_u += upCateAry.get(k).get(m);
											num_up1 += upCateAry.get(k).get(m);
											cur_upAry1.set(m, tmp_u);										
										}
									}								
									if(LEN1>0){
										AVG1_s = ACC1_s*1.0/LEN1;
										AVG1_u = ACC1_u*1.0/LEN1;
										for(int m=a_pos;m<=b_pos;m++)
										{
											RMS1_s += Math.pow((strAry.get(m)-AVG1_s),2);
											RMS1_u += Math.pow((upAry.get(m)-AVG1_u),2);
										}
										RMS1_s=Math.sqrt(RMS1_s*1.0/LEN1);
										RMS1_u=Math.sqrt(RMS1_u*1.0/LEN1);
										SLOPE1 = (PEAK - strAry.get(a_pos))*1.0/LEN1;										
									}
									
									//b-c																		
									for(int k=b_pos; k<=c_pos; k++){
										ACC2_s += strAry.get(k);
										ACC2_u += upAry.get(k);
										
										//category statistic for stress and up, respectively.. 
										for(int m=0; m<5; m++){
											double tmp_s = cur_strAry2.get(m);
											tmp_s += strCateAry.get(k).get(m);
											num_str2 += strCateAry.get(k).get(m);
											cur_strAry2.set(m, tmp_s);
										}
										for(int m=0; m<6; m++){
											double tmp_u = cur_upAry2.get(m);
											tmp_u += upCateAry.get(k).get(m);
											num_up2 += upCateAry.get(k).get(m);
											cur_upAry2.set(m, tmp_u);										
										}
									}
									if(LEN2>0){
										AVG2_s = ACC2_s*1.0/LEN2;
										AVG2_u = ACC2_u*1.0/LEN2;
										for(int m=b_pos;m<=c_pos;m++)
										{
											RMS2_s += Math.pow((strAry.get(m)-AVG2_s),2);
											RMS2_u += Math.pow((upAry.get(m)-AVG2_u),2);
										}
										RMS2_s=Math.sqrt(RMS2_s*1.0/LEN2);
										RMS2_u=Math.sqrt(RMS2_u*1.0/LEN2);
										SLOPE2 = (strAry.get(c_pos)-PEAK)*1.0/LEN2;
									}
									
									//any slides (satisfy peak require) all out for current teen
									bw_pair.write(a_pos+" "+b_pos+" "+c_pos+
											" "+LEN1+" "+LEN2+" "+LEN+"\r\n");
									bw_pair_value.write(AVG1_s+" "+AVG2_s+" "+ACC1_s+" "+ACC2_s+
											" "+RMS1_s+" "+RMS2_s+
											" "+SLOPE1+" "+SLOPE2+" "+PEAK+
											" "+AVG1_u+" "+AVG2_u+" "+ACC1_u+" "+ACC2_u+
											" "+RMS1_u+" "+RMS2_u+"\r\n");
									
									if(LEN>0){//for sort (add current slide stress/up values(accumulated/average) into big array)
										up_avgAllAry.add((ACC1_u+ACC2_u)*(-1.0)/LEN);
										up_accAllAry.add((ACC1_u+ACC2_u)*(-1.0));
										str_avgAllAry.add((ACC1_s+ACC2_s)*1.0/LEN);
										str_accAllAry.add(ACC1_s+ACC2_s);
									}
									
									
									//Now compare a-b,b-c,a-c Linguistic
									//1) up:distribution; rate; main type; distance
									//2) stress: distribution; rate; main type; distance
									ArrayList<Double> rateAry = new ArrayList<Double>();
																																					
									//cout-stress distribution
									for(int k=0; k<5; k++){//frequency of each stress type- LEN1
										bw_type.write(cur_strAry1.get(k)+" ");
										
										if(num_str1>0)//total frequency
											rateAry.add(cur_strAry1.get(k)/num_str1);//ratio len1
										else
											rateAry.add(0.0);
									}									
									for(int k=0; k<5; k++){//frequency of each stress type- LEN2
										bw_type.write(cur_strAry2.get(k)+" ");
										
										if(num_str2>0)//total frequency
											rateAry.add(cur_strAry2.get(k)/num_str2);//ratio len2
										else
											rateAry.add(0.0);
									}
									for(int k=0; k<5; k++){//frequency of each stress type- LEN1+LEN2
										double tmp = cur_strAry1.get(k)+cur_strAry2.get(k);
										bw_type.write(tmp+" ");
										
										double tmp2 = 0.0;
										//bug2...
										if(num_str1+num_str2>0)
										{
											tmp2 = tmp /(num_str1+num_str2);
										}
										rateAry.add(tmp2);//ratio total
									}
									
									//ADD: if the (LEN total rate) current type in top 3/2/1
									ArrayList<Double> nowType = new ArrayList<Double>();
									int givenType = Integer.parseInt(typeID);
									int cur_k = givenType+10;
									int count = 0;
									for(int k=10; k<=14 && k<rateAry.size();k++){
										if(k!=cur_k && rateAry.get(k)>rateAry.get(cur_k))
											count++;
									}
									
									//count-up distribution
									for(int k=0; k<6; k++){
										bw_type.write(cur_upAry1.get(k)+" ");
										
										if(num_up1>0)
											rateAry.add(cur_upAry1.get(k)/num_up1);
										else
											rateAry.add(0.0);
									}
									for(int k=0; k<6; k++){//num of each up type- LEN2
										bw_type.write(cur_upAry2.get(k)+" ");
										
										if(num_up2>0)
											rateAry.add(cur_upAry2.get(k)/num_up2);
										else
											rateAry.add(0.0);
									}
									for(int k=0; k<6; k++){//num of each up type- LEN1+LEN2
										double tmp = cur_upAry1.get(k)+cur_upAry2.get(k);
										bw_type.write(tmp+" ");
										
										if(num_up1+num_up2>0){
											rateAry.add(tmp/(num_up1+num_up2));
										}else
											rateAry.add(0.0);										
									}
									bw_type.write("\r\n");
									
									for(int k=0; k<rateAry.size(); k++){
										bw_rate.write(df.format(rateAry.get(k))+" ");
									}
									bw_rate.write("\r\n");
									
									//Type Constraint == type									
									
									//total file
									//flag: if we try to get the threshold (related with average up level) flag == 0; or calculate based on flag (flag == 1)
									//count: if the input type is the main type of current slide
									if(flag == 1 && count <=1){ // ADD type constraint (DONE!)
										double low_avg_u = threAry.get(0);//input threshold upSmallAvg
										double high_avg_u = threAry.get(1);//input threshold upBigAvg
										double low_acc_u = threAry.get(2);//input threshold
										double high_acc_u = threAry.get(3);//input threshold
										
										if(LEN>0){
											double curAvg = (ACC1_u+ACC2_u)*1.0/LEN;
											double curAcc = ACC1_u+ACC2_u;
											
											if(curAvg*(-1)<=low_avg_u || curAcc*(-1)<=low_acc_u){
												//!!!!!!!!!!!!!!!!!!!
												bw_small_pair.write(AVG1_s+" "+AVG2_s+" "+ACC1_s+" "+ACC2_s+
														" "+RMS1_s+" "+RMS2_s+
														" "+SLOPE1+" "+SLOPE2+" "+PEAK+
														" "+AVG1_u+" "+AVG2_u+" "+ACC1_u+" "+ACC2_u+
														" "+RMS1_u+" "+RMS2_u+
														" "+LEN1 + " " + LEN2 + " " + LEN + "\r\n");												
												
												double AVG_s = 0;
												if(LEN>0)
													AVG_s = (ACC1_s+ACC2_s)*1.0/LEN;
												
												SMALL_NUM++;
												S_LEN1+=LEN1;
												S_LEN2+=LEN2;
												S_LEN+=LEN;
												S_AVG1_s+=AVG1_s;
												S_AVG2_s+=AVG2_s;
												S_AVG_s += AVG_s;//add
												S_ACC1_s+=ACC1_s;
												S_ACC2_s+=ACC2_s;
												S_ACC_s += ACC1_s;//add
												S_ACC_s += ACC2_s;//add
												S_RMS1_s+=RMS1_s;
												S_RMS2_s+=RMS2_s;
												S_SLOPE1+=SLOPE1;
												S_SLOPE2+=SLOPE2;
												S_PEAK+=PEAK;
												
												S_AVG1_u+=AVG1_u;
												S_AVG2_u+=AVG2_u;
												S_ACC1_u+=ACC1_u;
												S_ACC2_u+=ACC2_u;
												S_RMS1_u+=RMS1_u;
												S_RMS2_u+=RMS2_u;
											}
											else
												if(curAvg*(-1)>=high_avg_u || curAcc*(-1)>=high_acc_u){
													//!!!!!!!!!!!!!!
													bw_big_pair.write(AVG1_s+" "+AVG2_s+" "+ACC1_s+" "+ACC2_s+
															" "+RMS1_s+" "+RMS2_s+
															" "+SLOPE1+" "+SLOPE2+" "+PEAK+
															" "+AVG1_u+" "+AVG2_u+" "+ACC1_u+" "+ACC2_u+
															" "+RMS1_u+" "+RMS2_u+
															" "+LEN1 + " " + LEN2 + " " + LEN + "\r\n");
													

													double AVG_s = 0;
													if(LEN>0)
														AVG_s = (ACC1_s+ACC2_s)*1.0/LEN;
													
													BIG_NUM++;
													B_LEN1+=LEN1;
													B_LEN2+=LEN2;
													B_LEN+=LEN;
													B_AVG1_s+=AVG1_s;
													B_AVG2_s+=AVG2_s;
													B_AVG_s += AVG_s;//add
													B_ACC1_s+=ACC1_s;
													B_ACC2_s+=ACC2_s;
													B_ACC_s += ACC1_s;//add
													B_ACC_s += ACC2_s;//add
													B_RMS1_s+=RMS1_s;
													B_RMS2_s+=RMS2_s;
													B_SLOPE1+=SLOPE1;
													B_SLOPE2+=SLOPE2;
													B_PEAK+=PEAK;
													
													B_AVG1_u+=AVG1_u;
													B_AVG2_u+=AVG2_u;
													B_ACC1_u+=ACC1_u;
													B_ACC2_u+=ACC2_u;
													B_RMS1_u+=RMS1_u;
													B_RMS2_u+=RMS2_u;
												}																																	
										}										
									}
									
									//all teens all pairs out
									all_pair_bw.write(AVG1_s+" "+AVG2_s+" "+ACC1_s+" "+ACC2_s+
											" "+RMS1_s+" "+RMS2_s+
											" "+SLOPE1+" "+SLOPE2+" "+PEAK+
											" "+AVG1_u+" "+AVG2_u+" "+ACC1_u+" "+ACC2_u+
											" "+RMS1_u+" "+RMS2_u+
											" "+LEN1 + " " + LEN2 + " " + LEN + "\r\n");
									
									double AVG_s = 0;
									if(LEN>0)
										AVG_s = (ACC1_s+ACC2_s)*1.0/LEN;
									
									
									ANUM++;
									A_LEN1+=LEN1;
									A_LEN2+=LEN2;
									A_LEN+=LEN;
									A_AVG1_s+=AVG1_s;
									A_AVG2_s+=AVG2_s;
									A_AVG_s += AVG_s;//add
									A_ACC1_s+=ACC1_s;
									A_ACC2_s+=ACC2_s;
									A_ACC_s += ACC1_s;//add
									A_ACC_s += ACC2_s;//add
									A_RMS1_s+=RMS1_s;
									A_RMS2_s+=RMS2_s;
									A_SLOPE1+=SLOPE1;
									A_SLOPE2+=SLOPE2;
									A_PEAK+=PEAK;
									
									A_AVG1_u+=AVG1_u;
									A_AVG2_u+=AVG2_u;
									A_ACC1_u+=ACC1_u;
									A_ACC2_u+=ACC2_u;
									A_RMS1_u+=RMS1_u;
									A_RMS2_u+=RMS2_u;																		
									
								}else
									break;
							}
						}else
							break;						
					}
					
				}else{
					System.out.println("invalid file too few tweets..");
					reader.close();
					s_reader.close();
					bw_pair.close();
					bw_pair_value.close();
					continue;
				}
				
				if(ANUM>0){
					//1-1 IMP-output: each teen per line: specific to current type(input), all slides (average level)
					bw_all_pair.write(fileList[pos_file]+
							" "+df.format(A_AVG1_s/ANUM)+" "+df.format(A_AVG2_s/ANUM)+" "+df.format(A_AVG_s/ANUM)+
							" "+df.format(A_ACC1_s/ANUM)+" "+df.format(A_ACC2_s/ANUM)+" "+df.format(A_ACC_s/ANUM)+
							" "+df.format(A_RMS1_s/ANUM)+" "+df.format(A_RMS2_s/ANUM)+
							" "+df.format(A_SLOPE1/ANUM)+" "+df.format(A_SLOPE2/ANUM)+" "+df.format(A_PEAK/ANUM)+
							" "+df.format(A_AVG1_u/ANUM)+" "+df.format(A_AVG2_u/ANUM)+
							" "+df.format(A_ACC1_u/ANUM)+" "+df.format(A_ACC2_u/ANUM)+
							" "+df.format(A_RMS1_u/ANUM)+" "+df.format(A_RMS2_u/ANUM)+
							" "+df.format(A_LEN1/ANUM)+" "+df.format(A_LEN2/ANUM)+" "+df.format(A_LEN/ANUM)+"\r\n");
				}
				
				//1-2 IMP-output: each teen per line: specific to current type(input), slides without uplifts (average up level)
				if(SMALL_NUM>0 && BIG_NUM>0){
					bw_teen_small.write(fileList[pos_file]+
							" "+df.format(S_AVG1_s/SMALL_NUM)+" "+df.format(S_AVG2_s/SMALL_NUM)+" "+df.format(S_AVG_s/SMALL_NUM)+
							" "+df.format(S_ACC1_s/SMALL_NUM)+" "+df.format(S_ACC2_s/SMALL_NUM)+" "+df.format(S_ACC_s/SMALL_NUM)+
							" "+df.format(S_RMS1_s/SMALL_NUM)+" "+df.format(S_RMS2_s/SMALL_NUM)+
							" "+df.format(S_SLOPE1/SMALL_NUM)+" "+df.format(S_SLOPE2/SMALL_NUM)+" "+df.format(S_PEAK/SMALL_NUM)+
							" "+df.format(S_AVG1_u/SMALL_NUM)+" "+df.format(S_AVG2_u/SMALL_NUM)+
							" "+df.format(S_ACC1_u/SMALL_NUM)+" "+df.format(S_ACC2_u/SMALL_NUM)+
							" "+df.format(S_RMS1_u/SMALL_NUM)+" "+df.format(S_RMS2_u/SMALL_NUM)+
							" "+df.format(S_LEN1/SMALL_NUM)+" "+df.format(S_LEN2/SMALL_NUM)+" "+df.format(S_LEN/SMALL_NUM)+"\r\n");
				}
				
				//1-3 IMP-output: each teen per line: specific to current type(input), slides with obvious uplifts (average up level)
				if(BIG_NUM>0 && SMALL_NUM>0){
					bw_teen_big.write(fileList[pos_file]+
							" "+df.format(B_AVG1_s/BIG_NUM)+" "+df.format(B_AVG2_s/BIG_NUM)+" "+df.format(B_AVG_s/BIG_NUM)+
							" "+df.format(B_ACC1_s/BIG_NUM)+" "+df.format(B_ACC2_s/BIG_NUM)+" "+df.format(B_ACC_s/BIG_NUM)+
							" "+df.format(B_RMS1_s/BIG_NUM)+" "+df.format(B_RMS2_s/BIG_NUM)+
							" "+df.format(B_SLOPE1/BIG_NUM)+" "+df.format(B_SLOPE2/BIG_NUM)+" "+df.format(B_PEAK/BIG_NUM)+
							" "+df.format(B_AVG1_u/BIG_NUM)+" "+df.format(B_AVG2_u/BIG_NUM)+
							" "+df.format(B_ACC1_u/BIG_NUM)+" "+df.format(B_ACC2_u/BIG_NUM)+
							" "+df.format(B_RMS1_u/BIG_NUM)+" "+df.format(B_RMS2_u/BIG_NUM)+
							" "+df.format(B_LEN1/BIG_NUM)+" "+df.format(B_LEN2/BIG_NUM)+" "+df.format(B_LEN/BIG_NUM)+"\r\n");
				}
				
				System.out.println(fileList[pos_file]);		
				
				reader.close();
				s_reader.close();
				
				up_cat_reader.close();//add
				str_cat_reader.close();//add
				
				bw_pair.close();
				bw_pair_value.close();
				
				//function: find threshold and back to result
				Collections.sort(up_avgAllAry);
				Collections.sort(up_accAllAry);
				Collections.sort(str_avgAllAry);
				Collections.sort(str_accAllAry);
				
				//current teen
				int len = up_avgAllAry.size();
				ArrayList <Double>  res_cur = new ArrayList<Double>();
				if(len>0){
					res_cur.add(up_avgAllAry.get((int) (len*0.2)));
					res_cur.add(up_avgAllAry.get((int) (len*0.7)));
					res_cur.add(up_accAllAry.get((int) (len*0.2)));
					res_cur.add(up_accAllAry.get((int) (len*0.7)));
					res_cur.add(str_avgAllAry.get((int) (len*0.2)));
					res_cur.add(str_avgAllAry.get((int) (len*0.7)));
					res_cur.add(str_accAllAry.get((int) (len*0.2)));
					res_cur.add(str_accAllAry.get((int) (len*0.7)));
				}else{
					for(int t=0; t<8; t++)
						res_cur.add(0.0);
				}				
				for(int t=0; t<res_cur.size(); t++){
					System.out.print(res_cur.get(t)+" ");
				}
				System.out.print("\r\n");
				
				res.add(res_cur);//add current teen  threshold into the whole threshold set 
				
			}//124 files done..
			
			//124 teens average value of big/small/all slides (each teen)
			bw_all_pair.close();
			bw_teen_big.close();
			bw_teen_small.close();
			
			//current teen
			all_pair_bw.close();//all pairs
			bw_small_pair.close();//all small pairs
			bw_big_pair.close();//all big pairs
			
			bw_type.close();//all type
			bw_rate.close();//all type rate
			
			System.out.println("All compare done....");
			
			//function end..
		}
		
		return res;
	}	
	
	static void correlationStress(int teenNum, int K) throws IOException{	
		//threshold for identify the stress intervals or other intervals is individual (each person a threshold)
		
		//initial threshold
		ArrayList<ArrayList<Double> > threAry = new ArrayList<ArrayList<Double> >();
		for(int k=0; k<teenNum; k++){
			ArrayList<Double> tmpAry = new ArrayList<Double>();
			for(int i=0; i<8; i++)
				tmpAry.add(0.0);
			threAry.add(tmpAry);
		}
				
		String typeID = "0";
		ArrayList<ArrayList<Double> > newAry = findCorrelation(threAry,0,typeID, K);//true threshold
		
		for(int i=0; i<5; i++){
			typeID = i+"";
			findCorrelation(newAry,1,typeID, K);
		}	
	}
	
	//FUNCTION: Correlation 1) find stress with/without uplifts 2) KNN 3) distribution formula
	static ArrayList<ArrayList<Double> > findCorrelation ( ArrayList<ArrayList<Double> > threshAry, int flag, String typeID, int K) throws IOException{		
		
		ArrayList<ArrayList<Double> > res = new ArrayList<ArrayList<Double>>();	
			
		//---------------------OUT2: 124 all pair slides-----------------------------------------------------
		//5-2-0 124 all pairs		
		String allPair = "E:\\TEST\\POSITIVE\\Pair\\correlation\\T"+typeID+"\\allPair.txt";	
		File allPairFile = new File(allPair);
		if(!allPairFile.exists()){
			allPairFile.createNewFile();
		}	
		FileWriter all_pair_fw = new FileWriter(allPairFile.getAbsoluteFile());
		BufferedWriter bw_all_pair = new BufferedWriter(all_pair_fw);			
			
		//5-2-1 124 all pairs big  ---------------！！！！！！！！！！！！！！！！！！！！！！！！
		String allPairBig = "E:\\TEST\\POSITIVE\\Pair\\correlation\\T"+typeID+"\\allPairBig.txt";	
		File allPairFileBig = new File(allPairBig);
		if(!allPairFileBig.exists()){
			allPairFileBig.createNewFile();
		}	
		FileWriter all_big_fw_pair = new FileWriter(allPairFileBig.getAbsoluteFile());
		BufferedWriter bw_big_pair = new BufferedWriter(all_big_fw_pair);
		
		//5-2-2 all pairs small ---------------！！！！！！！！！！！！！！！！！！！！！！！！
		String allPairSmall = "E:\\TEST\\POSITIVE\\Pair\\correlation\\T"+typeID+"\\allPairSmall.txt";	
		File allPairFileSmall = new File(allPairSmall);
		if(!allPairFileSmall.exists()){
			allPairFileSmall.createNewFile();
		}	
		FileWriter all_small_fw_pair = new FileWriter(allPairFileSmall.getAbsoluteFile());
		BufferedWriter bw_small_pair = new BufferedWriter(all_small_fw_pair);
		
		//Add: [1] record correlation (stress) for 124 teens !!!!!!FINAL RESULTS
		String allcor = "E:\\TEST\\POSITIVE\\Pair\\correlation\\corStress"+typeID+".txt";	
		File allcorFile = new File(allcor);
		if(!allcorFile.exists()){
			allcorFile.createNewFile();
		}	
		FileWriter allcorW = new FileWriter(allcorFile.getAbsoluteFile());
		BufferedWriter bw_cor_stress = new BufferedWriter(allcorW);
		
		//Add: [2] record correlation (stressor) for 124 teens !!!!!FINAL RESULTS
		String allcor2 = "E:\\TEST\\POSITIVE\\Pair\\correlation\\corStressor"+typeID+".txt";	
		File allcorFile2 = new File(allcor2);
		if(!allcorFile2.exists()){
			allcorFile2.createNewFile();
		}	
		FileWriter allcorW2 = new FileWriter(allcorFile2.getAbsoluteFile());
		BufferedWriter bw_cor_stressor = new BufferedWriter(allcorW2);
		
		//Add:!!! [3] record correlation (post) for 124 teens !!!! ADD 
		String allcor3 = "E:\\TEST\\POSITIVE\\Pair\\correlation\\corPost"+typeID+".txt";	
		File allcorFile3 = new File(allcor3);
		if(!allcorFile3.exists()){
			allcorFile3.createNewFile();
		}	
		FileWriter allcorW3 = new FileWriter(allcorFile3.getAbsoluteFile());
		BufferedWriter bw_cor_post = new BufferedWriter(allcorW3);
		
					
		//Add: record (average length) and (average stress) of stress intervals for 124 teens
		String allavg = "E:\\TEST\\POSITIVE\\Pair\\correlation\\avgUSI"+typeID+".txt";	
		File allavgFile = new File(allavg);
		if(!allavgFile.exists()){
			allavgFile.createNewFile();
		}	
		FileWriter allavgW = new FileWriter(allavgFile.getAbsoluteFile());
		BufferedWriter bw_avg = new BufferedWriter(allavgW);
				
		DecimalFormat df = new DecimalFormat("#####0.0000");  
		
		String dirParseIn = "E:\\TEST\\POSITIVE\\smoothUp\\";//accumulated level per Day after regression
		File files2parse = new File(dirParseIn);
		if(files2parse.isDirectory()){
			
			String [] fileList = files2parse.list();			
			for(int pos_file=0; pos_file<fileList.length; pos_file++){
				
				//find standard for current teen
				ArrayList<Double> up_avgAllAry = new ArrayList<Double>();//up
				ArrayList<Double> up_accAllAry = new ArrayList<Double>();//up			
				ArrayList<Double> str_avgAllAry = new ArrayList<Double>();//str
				ArrayList<Double> str_accAllAry = new ArrayList<Double>();//str
				
				ArrayList<ArrayList<Double> > wordSmallAry = new ArrayList<ArrayList<Double> >();
				ArrayList<ArrayList<Double> > wordBigAry = new ArrayList<ArrayList<Double> >();
				ArrayList<ArrayList<Double> > stressSmallAry = new ArrayList<ArrayList<Double> >();
				ArrayList<ArrayList<Double> > stressBigAry = new ArrayList<ArrayList<Double> >();
				//add-post number
				ArrayList<ArrayList<Double> > postSmallAry = new ArrayList<ArrayList<Double> >();
				ArrayList<ArrayList<Double> > postBigAry = new ArrayList<ArrayList<Double> >();
				
				
				ArrayList<Double> threAry = threshAry.get(pos_file);
				
				String PPath = dirParseIn+fileList[pos_file];
				
				//1-input positive	- day		
				InputStreamReader isr = new InputStreamReader(new FileInputStream(PPath),getCharset(PPath));//smoothUp
				BufferedReader reader = new BufferedReader(isr);
				
				//1-2 input positive category - day
				String posiCatPath = PPath.replace("smoothUp", "upCateSta");
				InputStreamReader isrCateUp = new InputStreamReader(new FileInputStream(posiCatPath),getCharset(posiCatPath));
				BufferedReader up_cat_reader = new BufferedReader(isrCateUp);
				
				//2-input stress - day
				String SPath = PPath.replace("smoothUp", "smoothStr");
				InputStreamReader s_isr = new InputStreamReader(new FileInputStream(SPath),getCharset(SPath));
				BufferedReader s_reader = new BufferedReader(s_isr);
				
				//2-2 input stress category - day
				String strCatPath = PPath.replace("smoothUp", "CateSta");
				InputStreamReader isrCateStr = new InputStreamReader(new FileInputStream(strCatPath),getCharset(strCatPath));
				BufferedReader str_cat_reader = new BufferedReader(isrCateStr);
				
				
				//3-1 add:UpDaySta: [accLevel, posiTweetNum, TotalTweetNum]
				//3-2 add:DaySta: [accLevel, stressTweetNum, TotalTweetNum]
				String addPath1 = PPath.replace("smoothUp", "upDaySta");
				InputStreamReader addStream1 = new InputStreamReader(new FileInputStream(addPath1),getCharset(addPath1));
				BufferedReader addReader1 = new BufferedReader(addStream1);
				
				String addPath2 = PPath.replace("smoothUp", "DaySta");
				InputStreamReader addStream2 = new InputStreamReader(new FileInputStream(addPath2),getCharset(addPath2));
				BufferedReader addReader2 = new BufferedReader(addStream2);
				
				
				//--------------------------------OUT 3: each teen a file: all pairs/values--------------------------------------
				//3-out put file for pair interval
				String PCombinePath = PPath.replace("smoothUp", "Pair\\correlation\\T"+typeID+"\\valueBig");	
				File PFile = new File(PCombinePath);
				if(!PFile.exists()){
					PFile.createNewFile();
				}	
				FileWriter fw = new FileWriter(PFile.getAbsoluteFile());
				BufferedWriter bw_big = new BufferedWriter(fw);
				
				//4-output file for values in pair interval
				String SCombinePath = PPath.replace("smoothUp", "Pair\\correlation\\T"+typeID+"\\valueSmall");	
				File SFile = new File(SCombinePath);
				if(!SFile.exists()){
					SFile.createNewFile();
				}	
				FileWriter s_fw = new FileWriter(SFile.getAbsoluteFile());
				BufferedWriter bw_small = new BufferedWriter(s_fw);
				
				//----Stressor (5 type distribution in small/big intervals)
				String LCombinePath = PPath.replace("smoothUp", "Pair\\correlation\\T"+typeID+"\\stressorValueBig");	
				File LFile = new File(LCombinePath);
				if(!LFile.exists()){
					LFile.createNewFile();
				}	
				FileWriter l_fw = new FileWriter(LFile.getAbsoluteFile());
				BufferedWriter stressor_bw_big = new BufferedWriter(l_fw);
				
				//4-output file for values in pair interval
				String LSCombinePath = PPath.replace("smoothUp", "Pair\\correlation\\T"+typeID+"\\stressorValueSmall");	
				File LSFile = new File(LSCombinePath);
				if(!LSFile.exists()){
					LSFile.createNewFile();
				}	
				FileWriter l_s_fw = new FileWriter(LSFile.getAbsoluteFile());
				BufferedWriter stressor_bw_small = new BufferedWriter(l_s_fw);
				//---------------------------------------------------------------------------------------------------------------
				
				//Function: read in stress and category...
				String line = "", s_line="", up_cat_line="", str_cat_line="";
				//add 
				String addDaySta = "", addUpDaySta = "";
				
				int tID = 0, upID=0, strID=0;
				double maxUp = 0, maxStr = 0, avgUp = 0, avgStr = 0, totalUp=0, totalStr=0, minUp = 0, minStr = 0;
				ArrayList<Double> upAry = new ArrayList<Double>();
				ArrayList<Double> strAry = new ArrayList<Double>();
				ArrayList<ArrayList<Integer>> upCateAry = new ArrayList<ArrayList<Integer>>();
				ArrayList<ArrayList<Integer>> strCateAry = new ArrayList<ArrayList<Integer>>();
				
				//add: the teen's post[all, strPost, posiPost, oriPost] each day in time line.
				ArrayList<ArrayList<Integer>> postNumAry = new ArrayList<ArrayList<Integer>>();
				
				while((line = reader.readLine()) != null && (s_line = s_reader.readLine()) != null
						&& (up_cat_line = up_cat_reader.readLine())!= null 
						&&(str_cat_line = str_cat_reader.readLine()) != null
						&&(addUpDaySta = addReader1.readLine()) != null 
						&&(addDaySta = addReader2.readLine()) != null ){
					
					if(line.length()>0 && s_line.length()>0 && up_cat_line.length()>9 && str_cat_line.length()>0
					   && addUpDaySta.length() > 0 && addDaySta.length() > 0 ){
																		
						double p = Double.valueOf(line.toString()); //smoothed acc stress level
						double s = Double.valueOf(s_line.toString()); // smoothed acc up level
						
						if(p>0) p=0;
						if(s<0) s=0;
						
						if(tID == 0){
							maxUp = p*(-1);
							minUp = p*(-1);
							maxStr = s;
							minStr = s;
						}						
						if(p*(-1)>maxUp) maxUp = p*(-1);
						if(p*(-1)<minUp) minUp = p*(-1);						
						if(s>maxStr) maxStr = s;
						if(s<minStr) minStr = s;
						
						
						String[] up_elem = up_cat_line.split(" "); //!!! 
						//0 0 3 0 0 1  1 2 1  1 0 0  2,014 8 16 3 [topic, rol, http, time]
						//0 0 0 0 0 0  0 0 0  0 0 0  0 0 0 5,343 //6 + 3 + 3 + 4
						String[] str_elem = str_cat_line.split(" "); //!!! 
						//0 0 1 0 0  0 1 0  0 0 0  2,014 11 23 16 //5 + 3 + 3 + 4
						//0 0 0 0 0  0 0 0  0 0 0  0 0 5,442 //5 + 3 + 3 + 3
						ArrayList<Integer> upTmpAry = new ArrayList<Integer>();
						ArrayList<Integer> strTmpAry = new ArrayList<Integer>();
						for(int k=0; k<up_elem.length && k<6; k++){
							upTmpAry.add(Integer.parseInt(up_elem[k].toString()));
						}					
						
						for(int k=0; k<str_elem.length && k<5; k++){
							strTmpAry.add(Integer.parseInt(str_elem[k].toString()));
						}		
						
						//add [accUp, upPost, allPost]
						//add [accStr, strPost, allPost]
						String[] up_post_elem = addUpDaySta.split(" ");
						String[] str_post_elem = addDaySta.split(" ");
						if(up_post_elem.length!=3 || str_post_elem.length!=3){
							System.out.println("UpDaySta or DaySta format is not 3...please check");
							System.exit(0);
						}
						
						ArrayList<Integer> oriPostAry = new ArrayList<Integer>();
						oriPostAry.add(Integer.parseInt(up_post_elem[2].toString()));//all post num  \1
						oriPostAry.add(Integer.parseInt(str_post_elem[1].toString()));//str post num \2
						oriPostAry.add(Integer.parseInt(up_post_elem[1].toString()));//posi post num \3
						
						//add-origin
						//for(int k=9; k<up_elem.length && k<12; k++){
						int httpPost = Integer.parseInt(up_elem[9].toString());
						int replyPost = Integer.parseInt(up_elem[10].toString());
						int comPost = Integer.parseInt(up_elem[11].toString());
						int allPostNum = Integer.parseInt(up_post_elem[2].toString());
						if(allPostNum >= httpPost){
							allPostNum = allPostNum - httpPost;
						}
						oriPostAry.add(allPostNum);//original post num \4
						//} add origin end						
						//add end 20180515
						
						upCateAry.add(upTmpAry);   //day
						strCateAry.add(strTmpAry); //day
						postNumAry.add(oriPostAry); //day - new add
						upAry.add(p); //day
						strAry.add(s); //day
						totalUp += p;
						totalStr += s;
						tID++;						
						if(p!=0) upID++;
						if(s!=0) strID++;
					}
				}
				//read in end...
				
				//statistic average for current teen:
				int ANUM = 0;
				int SMALL_NUM = 0;
				int BIG_NUM = 0;
					
				if(tID>10 && maxUp>=0 && maxStr>0){//this teen posted more than 10 days..
										
					//1. regular
					avgUp = totalUp/tID; //<0
					avgStr = totalStr/tID;	
				//	if(upID>0) avgUp = totalUp*1.0/upID;
				//	if(strID>0) avgStr = totalStr*1.0/strID;
					
					//2. find pairs					
					for(int i =0; i<strAry.size(); i++){
										
						//2-1-find the big strWave
						while(i<strAry.size() && strAry.get(i)==0){//cut down empty
							i++;
						}						
						if(i==strAry.size()) break;//!!!!!!
							
						double pre = 0;
						int a_pos = i, b_pos = i, c_pos = i;//a-find
						while(i<strAry.size() && strAry.get(i)>=pre && strAry.get(i)>0){//highest
							pre = strAry.get(i);
							i++;
						}						
						if(i==strAry.size()) break;//！！！！！
						
						i--;
						if(i<strAry.size() && strAry.get(i)>=avgStr){//judge as valid high
							b_pos = i;//b-find
							i++;
							while(i<strAry.size() && strAry.get(i)<=pre){
								pre = strAry.get(i);									
								i++;
								if(pre == 0) break;
							}

							if(i<strAry.size()){
								c_pos = i-1;//c									
								double preMax = strAry.get(b_pos), preMin = strAry.get(c_pos);	
								
								//2-2-find the tailed small strWaves, identify a-b-c
								while(i<strAry.size()){
									if(strAry.get(i)==0) break;
									
									double tmpH = 0, tmpL = 0;
									while(i<strAry.size() && strAry.get(i)>=pre){
										pre = strAry.get(i);
										i++;
										if(pre == 0) break;//
									}
									if(i<strAry.size()){
										i--;
										tmpH = strAry.get(i);
										if(strAry.get(i)< preMax){
											i++;
											while(i<strAry.size() && strAry.get(i)<=pre){
												pre = strAry.get(i);													
												i++;
												if(pre == 0) break;
											}
											i--;
											tmpL = strAry.get(i);
											if(tmpL<=preMin && tmpH<preMax){
												preMin = tmpL;
												preMax = tmpH;
												c_pos = i;
												i++;
											}else
												{
													i = c_pos+1;
													break;
												}
										}else
											{
												i = c_pos+1;//
												break;
											}
									}else
										break;
								}//end small tails
																										
								//2-3-find corresponding positive values, and calculate
								if(!(a_pos>=0 && a_pos<strAry.size() && b_pos>=a_pos && b_pos < strAry.size()))
								{
									System.out.println("a-b-c error");
									break;
								}								
								//add: part D....
								double ACC_s = 0, ACC_u = 0;
								ArrayList<Integer> cur_upAry = new ArrayList<Integer>();
								ArrayList<Integer> cur_strAry = new ArrayList<Integer>();
								//add
								ArrayList<Integer> cur_postAry = new ArrayList<Integer>();
								double num_up=0, num_str=0;
								
								for(int k=0;k<6;k++){
									cur_upAry.add(0);//accumulated uplift topics (6) during b-c
								}
								for(int k=0; k<5; k++){
									cur_strAry.add(0);//accumulated stressor topics (5) during b-c
								}
								//add
								for(int k=0; k<4; k++){
									cur_postAry.add(0);//accumulated stressor topics (5) during b-c
								}
								
								int LEN = c_pos-a_pos+1;								
								//a-c
								for(int k=a_pos; k<=c_pos; k++){
									ACC_s += strAry.get(k);
									ACC_u += upAry.get(k);
									
									//[1] up word num
									for(int p=0; p<6; p++){
										if(upCateAry.get(k).get(p)>0){
											Integer tmp = cur_upAry.get(p);
											tmp += upCateAry.get(k).get(p);
											cur_upAry.set(p,tmp);												
											num_up+=upCateAry.get(k).get(p);
										}
									}
									//[2] stress word num
									for(int p=0; p<5; p++){
										if(strCateAry.get(k).get(p)>0){ //..
											Integer tmp = cur_strAry.get(p);
											tmp += strCateAry.get(k).get(p);
											cur_strAry.set(p,tmp);
											num_str+=strCateAry.get(k).get(p);
										}
									}
									
									//[3] post
									for(int p=0; p<4; p++){
										if(postNumAry.get(k).get(p)>0){
											Integer tmp = cur_postAry.get(p);//previous
											tmp += postNumAry.get(k).get(p);//current
											cur_postAry.set(p, tmp);//refresh
										}
									}									
								}//a-c done															

								if(LEN>0){//for sort (add current slide stress/up values(accumulated/average) into big array)
									up_avgAllAry.add(ACC_u*(-1.0)/LEN);
									up_accAllAry.add(ACC_u*(-1.0));
									str_avgAllAry.add((ACC_s)*1.0/LEN);
									str_accAllAry.add(ACC_s);
								}								
								
								//Now compare a-b,b-c,a-c Linguistic
								//1) up:distribution; rate; main type; distance
								//2) stress: distribution; rate; main type; distance
								ArrayList<Double> rateAry = new ArrayList<Double>();
																																				
								//COUNT-stress distribution
								for(int k=0; k<5; k++){//frequency of each stress type- LEN1
									if(num_str>0)//total frequency
										rateAry.add(cur_strAry.get(k)*1.0/num_str);//ratio len1											
									else
										rateAry.add(0.0);
								}									
								
								//ADD: if the (LEN total rate) current type in top 3/2/1
								//ArrayList<Double> nowType = new ArrayList<Double>();
								int givenType = Integer.parseInt(typeID);
								int cur_k = givenType;
								int count = 0;
								for(int k=0; k<=4 && k<rateAry.size();k++){
									if(rateAry.get(k)>rateAry.get(cur_k))
										count++;
								}
								
								//COUNT-up distribution -- actually never used 5-10
								for(int k=0; k<6; k++){										
									if(num_up>0)
										rateAry.add(cur_upAry.get(k)*1.0/num_up);
									else
										rateAry.add(0.0);
								}
								
								//Type Constraint == type									
								
								//total file
								//flag: if we try to get the threshold (related with average up level) flag == 0; or calculate based on flag (flag == 1)
								//count: if the input type is the main type of current slide
								if(flag == 1 && count <=2){ // ADD type constraint (DONE!)
									double low_avg_u = threAry.get(0);//input threshold upSmallAvg
									double high_avg_u = threAry.get(1);//input threshold upBigAvg
									double low_acc_u = threAry.get(2);//input threshold
									double high_acc_u = threAry.get(3);//input threshold
									
									if(LEN>0){
										
										double curAvg = ACC_u*1.0/LEN;
										double curAcc = ACC_u;
										
										if(curAvg*(-1)<=low_avg_u || curAcc*(-1)<=low_acc_u){
											//if(LEN>1) System.out.println(fileList[pos_file]+"|yes|"+LEN);
											
											//!!!!!!!!!!!!!!!!!!!		
											//[1] stress series
											String s = "";
											ArrayList<Double> s_tmp_ary = new ArrayList<Double>();
											ArrayList<Double> w_tmp_ary = new ArrayList<Double>();
											//add
											ArrayList<Double> p_tmp_ary = new ArrayList<Double>();
											
											for(int p=a_pos;p<=c_pos;p++){
												s = s+ " "+strAry.get(p);  //the time line position 
												s_tmp_ary.add(strAry.get(p));
											}
											stressSmallAry.add(s_tmp_ary);//for knn calculate //for the teen !!!!!
											bw_small.write(SMALL_NUM+s+"\r\n");
											
											bw_small_pair.write(s.trim() + "\r\n");
											bw_all_pair.write(s.trim() + "\r\n");
											
											//[2] stress word distribution
											String word = "";
											for(int p=0;p<5;p++){
												word = word + " " + cur_strAry.get(p);
												w_tmp_ary.add(cur_strAry.get(p)*1.0); //num
											}
											for(int p=0;p<5;p++){
												word = word + " " + rateAry.get(p); //rate
												w_tmp_ary.add(rateAry.get(p));
											}
											wordSmallAry.add(w_tmp_ary); //
											stressor_bw_small.write(SMALL_NUM+word+"\r\n");
											
											//add!!!
											//[3] post behavior
											for(int p=0; p<4; p++){
												p_tmp_ary.add(cur_postAry.get(p)*1.0);//4 kinds of post
											}
											postSmallAry.add(p_tmp_ary);
											//test ... 
											//postSmallAry
											//cur_postAry
											
											SMALL_NUM++;
										}else
											if(curAvg*(-1)>=high_avg_u || curAcc*(-1)>=high_acc_u){
												//!!!!!!!!!!!!!!
												//stress series
												String s = "";
												String s2 = "";//change for prediction 1)
												ArrayList<Double> s_tmp_ary = new ArrayList<Double>();
												ArrayList<Double> w_tmp_ary = new ArrayList<Double>();
												//add
												ArrayList<Double> p_tmp_ary = new ArrayList<Double>();												
												
												for(int p=a_pos;p<=c_pos;p++){
													s = s+ " "+strAry.get(p);
													s2 = s2 + strAry.get(p) + "\r\n";
													s_tmp_ary.add(strAry.get(p));//!!!just the series
												}
												stressBigAry.add(s_tmp_ary);//for knn calculate// for the teen!!!!!
												//bw_big.write(BIG_NUM+s+"\r\n"); //why change it ... because for predict!!!
												bw_big.write(s2);
												
												bw_big_pair.write(s.trim()+"\r\n");
												bw_all_pair.write(s.trim()+"\r\n");
												
												//stress word distribution
												String word = "";
												for(int p=0;p<5;p++){
													word = word + " " + cur_strAry.get(p); //num
													w_tmp_ary.add(cur_strAry.get(p)*1.0);
												}
												for(int p=0;p<5;p++){
													word = word + " " + rateAry.get(p); //rate
													w_tmp_ary.add(rateAry.get(p));
												}
												wordBigAry.add(w_tmp_ary); //
												stressor_bw_big.write(BIG_NUM+word+"\r\n");
												
												//[3]add !!! post
												//postBigAry

												for(int p=0; p<4; p++){
													p_tmp_ary.add(cur_postAry.get(p)*1.0);//4 kinds of post
												}
												postBigAry.add(p_tmp_ary);												
												
												BIG_NUM++;
											}
										ANUM++;
									}										
								}																																			
							}else
								break;
						}					
					}
					
				}else{
					System.out.println("invalid file too few tweets..");
					reader.close();
					s_reader.close();
					
					up_cat_reader.close();
					str_cat_reader.close();
					addReader1.close();
					addReader2.close();
					
					bw_big.close();
					bw_small.close();
					continue;
				}
							
				//System.out.println(fileList[pos_file]+" "+ANUM+" "+BIG_NUM+" "+SMALL_NUM);		
				
				reader.close();
				s_reader.close();
				
				up_cat_reader.close();
				str_cat_reader.close();
				addReader1.close();
				addReader2.close();
				
				bw_big.close();
				bw_small.close();
				stressor_bw_big.close();
				stressor_bw_small.close();
				
				//function: find threshold and back to result
				Collections.sort(up_avgAllAry);
				Collections.sort(up_accAllAry);
				Collections.sort(str_avgAllAry);
				Collections.sort(str_accAllAry);
				
				//current teen
				int len = up_avgAllAry.size();
				ArrayList <Double>  res_cur = new ArrayList<Double>();
				if(len>0){
					res_cur.add(up_avgAllAry.get((int) (len*0.2)));
					res_cur.add(up_avgAllAry.get((int) (len*0.8)));
					res_cur.add(up_accAllAry.get((int) (len*0.2)));
					res_cur.add(up_accAllAry.get((int) (len*0.8)));
					res_cur.add(str_avgAllAry.get((int) (len*0.2)));
					res_cur.add(str_avgAllAry.get((int) (len*0.8)));
					res_cur.add(str_accAllAry.get((int) (len*0.2)));
					res_cur.add(str_accAllAry.get((int) (len*0.8)));
				}else{
					for(int t=0; t<8; t++)
						res_cur.add(0.0);
				}
				
				res.add(res_cur);//add current teen  threshold into the whole threshold set 
				
				//Function: calculate stress, word, word-rate KNN and ratio
				//Function: formula
				
				//stressSmallAry/stressBigAry: small/big stress series
				//wordSmallAry/wordBigAry: small/big word+word rate series
								
				System.out.println(fileList[pos_file]);
				if(flag == 1)//not for thresh, for real ...
				{
					double res1 = knnMethod(stressBigAry, stressSmallAry, K);   //stress intensity  -- ALERT: better change to 7 measures...
					double res2 = knnMethod(wordBigAry, wordSmallAry, K); 		//linguistic -- topic distribution and topic ratio 
					//ADD !!!: to be add here:knnMethod (post....)
					double res3 = knnMethod(postBigAry, postSmallAry, K); 		//post behavior 
					
					bw_cor_stress.write(df.format(res1)+"\r\n");//need to output...
					bw_cor_stressor.write(df.format(res2)+"\r\n");
					//to be add: write out the result of post correlation
					bw_cor_post.write(df.format(res3)+"\r\n");
									
					//change for predict  
					//calculate average length for seasonal prediction
					double L = 0; //length
					double S = 0; //
					for(int k=0; k<stressBigAry.size(); k++){ //number of intervals
						int n = stressBigAry.get(k).size(); // length of each interval
						L += n;
						for(int p=0; p<n; p++){  //Intensity of each interval
							S+=stressBigAry.get(k).get(p);
						}
					}
					
					if(stressBigAry.size()>0 && L>0)
					{
						S = S/L; //average intensity (day) in big intervals
						L = L/stressBigAry.size(); //average length of big intervals
					}
					
					//output fileList[pos_file] + L...
					int LtoI = (int) (L)+1;
					bw_avg.write(LtoI+" "+df.format(S)+"\r\n");													
				}			
			}//current file (teen)
						
			//all teen
			bw_all_pair.close();//all pairs
			bw_small_pair.close();//all small pairs
			bw_big_pair.close();//all big pairs
			
			bw_cor_stressor.close();
			bw_cor_stress.close();
			//add!!! post correlation record file close
			bw_cor_post.close();
			
			bw_avg.close();		
			
			System.out.println("All compare done....");			
			//function end..
		}
		return res;
	}	
	
	//KNN method
	static Double knnMethod(ArrayList<ArrayList<Double> >strBigAry, ArrayList<ArrayList<Double> >strSmallAry, int K){
		Double r = 0.0;
		
		int N1 = strBigAry.size(), N2 = strSmallAry.size();
		Map<Integer, Double> res = new HashMap<Integer, Double>();		 
		
		ArrayList<ArrayList<Double> > allAry = new ArrayList<ArrayList<Double> >();
		for(int i=0; i<N1; i++){
			allAry.add(strBigAry.get(i));
		}
		for(int i=0; i<N2; i++){
			allAry.add(strSmallAry.get(i));
		}
		
		int N0= allAry.size();
		int X = 0, Y = 0;
		
		for(int i=0; i<N0; i++){//
			
			ArrayList<Double> curAry = allAry.get(i);
			int L1 = curAry.size();
			
			//find the nearest, record position
			//allAry = (SET A:small)+(SET B:big)
			for(int j=0; j<N0; j++){

				//calculate distance
				ArrayList<Double> tmpAry = allAry.get(j);
				int L2 = tmpAry.size();
				
				//add 0 to the same length
				int sub = L1 - L2;
				if(sub>=0){						
					ArrayList<Double> newAry = new ArrayList<Double>();
					for(int p=0; p<sub*1.0/2; p++){
						newAry.add(0.0);
					}
					for(int q=0; q<L2; q++){
						newAry.add(tmpAry.get(q));//new test
					}
					for(int p=0; p<sub*1.0/2; p++)
						newAry.add(0.0);
					
					//calculate
					double dis = 0;
					for(int p=0; p<L1 && p<curAry.size() && p<newAry.size(); p++){
						dis = dis + Math.pow((curAry.get(p)-newAry.get(p)), 2);//curAry is larger
					}
					res.put(j, dis);
				}else
					if(sub<0){
						//add 0 to the same length
						ArrayList<Double> newAry = new ArrayList<Double>();
						for(int p=0; p<sub*1.0/2; p++){
							newAry.add(0.0);
						}
						for(int q=0; q<L1; q++){
							newAry.add(curAry.get(q));//new test
						}
						for(int p=0; p<sub*1.0/2; p++)
							newAry.add(0.0);
						
						//calculate
						double dis = 0;
						for(int p=0; p<L1 && p<tmpAry.size() && p<newAry.size(); p++){
							dis = dis + Math.pow((tmpAry.get(p)-newAry.get(p)), 2);//tmpAry is larger
						}
						res.put(j, dis);
					}
			}
			//rank result map
	        
	        List<Map.Entry<Integer,Double>> list = new ArrayList<Map.Entry<Integer,Double>>(res.entrySet());
	        Collections.sort(list,new Comparator<Map.Entry<Integer,Double>>() {
				@Override
				public int compare(java.util.Map.Entry<Integer,Double> o1,
						java.util.Map.Entry<Integer,Double> o2) {
					return o1.getValue().compareTo(o2.getValue());
				}	            
	        });
	        
	        int pos = 0;	        
	        for(Map.Entry<Integer,Double> mapping:list){ 	              
	        	if(pos<K){
	        		if(i>=0 && i<N1){ //Set A
	        			if(mapping.getKey()>=0 && mapping.getKey()<N1)
	        				X++;
	        			else
	        				Y++;
		        	}else
		        		if(i>=N1 && i<(N1+N2)){
		        			if(mapping.getKey()>=N1 && mapping.getKey()<(N1+N2)){//Set B
			        			X++;
			        		}else
			        			Y++;
		        		}else{
		        			System.out.println(i+" error...");
		        		}
	        		pos++;
	        	}else
	        		break;
	        } 		
		}
		//System.out.println(X+"|"+Y);
		//formula
		if(N1>0 && N2>0){
			//r = X*1.0/(X+Y);
			double b = X*1.0/(N1*N2);
			double lam1 = N1*1.0/N0;
			double lam2 = N2*1.0/N0;
			double u = Math.pow(lam1,2)+Math.pow(lam2,2);
			double div = lam1*lam2 + 4*lam1*lam1*lam2*lam2;
			if(div > 0){
				r = Math.sqrt(N1*N2)*(b-u)/div;
			}else
				r = 0.0;
		}else
		{
			System.out.println(N1+"|"+N2);
		}		
		return r;
	}

	//addition - date function -1
	//addition function
	static java.sql.Date string2Date(String dateString) throws ParseException{
		DateFormat dateFormat;
		dateFormat = new SimpleDateFormat("yyyy/MM/dd",Locale.ENGLISH);
		dateFormat.setLenient(false);
		java.util.Date timeDate = dateFormat.parse(dateString);
		java.sql.Date dateTime = new java.sql.Date(timeDate.getTime());
		return dateTime;
	}

	public static int daysBetween(String s1, String s2) throws ParseException    
	 {    
	   SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");  
	  // smdate = (Date)sdf.parse(sdf.format(smdate));  
	  // bdate=(Date)sdf.parse(sdf.format(bdate));  
       Date smdate = string2Date(s1);//small
       Date bdate = string2Date(s2);//big
	   
	   Calendar cal = Calendar.getInstance();    
	   
	   cal.setTime(smdate);//first    
	   long time1 = cal.getTimeInMillis();                 
	   cal.setTime(bdate);    
	   long time2 = cal.getTimeInMillis();         
	   long between_days=(time2-time1)/(1000*3600*24);  
	            
       return Integer.parseInt(String.valueOf(between_days));           
	}    
	 	//sub-function collect users--done
	
	public static void main(String[] args) throws Exception{
		correlationStress(124,2);//function 3
		//compareStress(124);//function 2
		//collectUsers();//function 1
	}
}
