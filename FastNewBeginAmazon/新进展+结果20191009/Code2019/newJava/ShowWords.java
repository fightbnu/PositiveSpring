package uplifts;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.sql.Date;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DateFormat;
import java.text.DecimalFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.ansj.domain.Term;
import org.ansj.splitWord.analysis.BaseAnalysis;
import org.ansj.splitWord.analysis.NlpAnalysis;
import org.ansj.splitWord.analysis.ToAnalysis;
import org.ansj.util.MyStaticValue;


public class  ShowWords {
	public ArrayList<Hashtable<String, String>> Topic_List = new ArrayList<Hashtable<String, String>>();//store the four kinds of stress topic words, each stress topic corresponds to a hashtable
	public Hashtable<String, String> Positive_Words = new Hashtable<String, String>();//store stressful words
	public Hashtable<String, Integer> Adv_Words = new Hashtable<String, Integer>();//store stressful words
	public Hashtable<String, String> Retweet = new Hashtable<String, String>();
	public Hashtable<String, String> Reply = new Hashtable<String, String>();
	public Hashtable<String, String> collectLexHash = new Hashtable<String, String>(); 
	
	//LIWC
	public ArrayList<Hashtable<String, String>> Emotion_List  = new ArrayList<Hashtable<String, String>>();//8种emotion	
		
	//public static enum STRESS_TYPE {ACA, AFF, INTER, SELF, PRO, HEAL, FIN, FAMI, UNKNOWN;}  //****stress type 9：study\emotion\relationship\self\job\health\finance\family\society
	
	private String getCharset(String fileName) throws IOException{
         
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

	
	public void lexiconLoad()
	{		
		//***********************Load topic lexicon*******************************************************
		String[] Files = {
				  "lex_uplifts/lexp_study.txt", //0
				  "lex_uplifts/lexp_romantic.txt",//1
		          "lex_uplifts/lexp_friends.txt",//2
				  "lex_uplifts/lexp_self.txt",//3	         
		          "lex_uplifts/lexp_family.txt", //4
		          "lex_uplifts/lexp_enter.txt",//entertainment-new lexicon 5 !!!!
		          "lex_uplifts/dic_positive.txt",//positive emotion 6
		          "lex_uplifts/lex_degree_lq.txt",//degree adverb 7
		          "lex_uplifts/retweet.txt",//social 8
		          "lex_uplifts/reply.txt"//social 9
		         };   
		
		BufferedReader reader = null;
		Hashtable<String, String> temp = null;
		String line = null;
		
		InputStreamReader isr;		
		
		MyStaticValue.userLibrary = "library/userLibrary.dic";  

		for (int i = 0; i < Files.length; i++)
		{				
			try
			{
				isr = new InputStreamReader(new FileInputStream(Files[i]),getCharset(Files[i]));
				reader = new BufferedReader(isr);
				String tline = reader.readLine();

				byte[] b = tline.getBytes("UTF-8");
				line = new String(b, 3, b.length-3, "UTF-8");//去掉UTF-8文件编码的BOM
				int num=0;//total number of words in all lexicons
				
				if (i < 6)                                 //add positive type words
				{
					temp = new Hashtable<String, String>();
					temp.clear();
					while (line != null)
					{
						String[] elem = line.split(" ");	
						if(elem.length>1)
						{
							temp.put(elem[0], elem[1]);	//teacher rol
						}
						else
							temp.put(elem[0], elem[0]);
						
				    	num++;
						line = reader.readLine();			
					}
					Topic_List.add(temp);	
				//	System.out.println(num);
				}
				else if (i < 7)                         //positive emotion words
				{
					while (line != null)
					{
						String[] elem = line.split(" ");				    	
				    	Positive_Words.put(elem[0], elem[0]);
				    	num++;
						line = reader.readLine();
					}
				//	System.out.println(num);
				}
				else if (i == 7)						//adverb
				{
					while(line!=null){
						String[] elem = line.split(" ");
						String adv = elem[0];
						String level = elem[1];
						Adv_Words.put(adv, Integer.parseInt(level));
						num++;
						line = reader.readLine();
					}
				//	System.out.println(num);
				}else if(i==8){
					while(line!=null){
						Retweet.put(line,line);
						line = reader.readLine();
						num++;
					}			
				//	System.out.println(num);
				}else if(i==9){
					while(line!=null){
						Reply.put(line, line);
						line = reader.readLine();
						num++;
					}			
				//	System.out.println(num);
				}
												
				System.out.println(Files[i]+"	"+num+"words");
				System.out.println("Hashtable Loading completed!");					
			}
			catch(Exception e)
			{
				System.out.println("Error: " + line);
				
			}
			finally 
			{
            	if (reader != null)
            	{
                	try 
                	{
                		
                    	reader.close();
                    	reader = null;
                	} 
                	catch (IOException e1) 
                	{
                	}
            	}
			}					
		}
	}

	public ArrayList<ArrayList> parserOneTweet(String tweet){
		
		ArrayList<ArrayList> result = new ArrayList<ArrayList>();
		
		ArrayList<String> Category = new ArrayList<String>();// categories
				
		//ArrayList<Integer> specialWords = new ArrayList<Integer>();// press + adv
		ArrayList<String> specialWords = new ArrayList<String>();
		
		//ArrayList<Integer> labelWords = new ArrayList<Integer>();//rol, act, des
		ArrayList<String> labelWords = new ArrayList<String>();
		
		for(int i=0;i<6;i++){//0study,1romantic,2friends,3self,4family,5enter
			//ArrayList<String> C = new ArrayList<String>();
			Category.add("");
		}
		
		for(int i=0;i<3;i++){//rol, act, des
			labelWords.add("");
		}
		
	//	specialWords.add("");
	//	specialWords.add("");
				
		int Num_positive=0;//
		int Num_adv_level=0;
		
		String posiStr = "";
		String degreeStr = "";
			
	    //按照句号叹号等将整句分开
		ArrayList<String> sentences = new ArrayList<String>();
	    
		Pattern pattern = Pattern.compile("[^\\. ! 。！？?~…\\s]+[\\. ! 。！？?~…\\s]+");	    	    
	    Matcher matcher = pattern.matcher(tweet);	    
	    while (matcher.find())
	    {    		
	    	sentences.add(matcher.group(0));
	    }
	    
	    for (String sen: sentences)
	    {		
	    	List<Term> parse_temp = ToAnalysis.parse(sen);
	    	ArrayList<String> parse_result = new ArrayList<String>();//存储没有词性标注的分词结果（每个分句）
	    	
	    	for (Term term: parse_temp)
	    	{ 
	    		//去掉词性标注
	    		String item = term.getName().trim();  
	    		if (item.length() > 0)
	    		{  
	    			parse_result.add(item.trim());
	    		}
	    	}
	    		
	    	for(int i=0; i<parse_result.size();i++){
	    		String word = parse_result.get(i);
	    		if(word.length()>0){
	    			
	    			//number of each category; number of rol/act/des
	    			for(int j=0;j<Topic_List.size();j++){
	    				if(Topic_List.get(j).containsKey(word)){
	    					String pre = Category.get(j);
	    					String now = pre +" "+word;
	    					Category.set(j, now);
	    					
	    					String str = Topic_List.get(j).get(word);//rol/des/act
	    					if(str.equals("rol")){
	    						String preLabel = labelWords.get(0);
	    						String nowLabel = preLabel+" "+word;
		    					labelWords.set(0, nowLabel);
	    					}
	    					else
	    						if(str.equals("act")||str.equals("actn")){
	    							String preLabel = labelWords.get(1);
		    						String nowLabel = preLabel+" "+word;
			    					labelWords.set(1, nowLabel);
	    						}
	    						else
	    							if(str.equals("des")||str.equals("desn")){
	    								String preLabel = labelWords.get(2);
	    	    						String nowLabel = preLabel+" "+word;
	    		    					labelWords.set(2, nowLabel);
	    							}
	    				}
	    			}
	    			   			
	    			//press, self, suicide, last
	    			if(Positive_Words.contains(word)){
	    				posiStr = posiStr+" "+word;
	    			}
	    			
	    			if(Adv_Words.containsKey(word)){
	    				degreeStr = degreeStr+" "+word;
	    			}
	    				    			
	    		}
	    	}
	     }		
		
		//output
	    specialWords.add(posiStr);//0
	    specialWords.add(degreeStr);//1
	    
	    result.add(Category);//5
	    result.add(specialWords);// 2
	    result.add(labelWords);//3
	    
		return result;
	}

	static java.sql.Date string2Date(String dateString) throws ParseException{
		DateFormat dateFormat;
		dateFormat = new SimpleDateFormat("yyyy-MM-dd",Locale.ENGLISH);
		dateFormat.setLenient(false);
		java.util.Date timeDate = dateFormat.parse(dateString);
		java.sql.Date dateTime = new java.sql.Date(timeDate.getTime());
		return dateTime;
	}
	
	
	public ArrayList<String> parser(String filename) throws IOException, FileNotFoundException, IOException, ParseException{
		
		ArrayList<String> result = new ArrayList<String>();
				
		//output
		//String textPath = filename.replace("textID", "upLevelOrigin");	
		//String textPath = filename.replace("textID", "upTextFeature");
		String textPath = filename.replace("textID", "upContent");
		File textFile = new File(textPath);
		if(!textFile.exists()){
			textFile.createNewFile();
		}	
		FileWriter fw = new FileWriter(textFile.getAbsoluteFile());
		BufferedWriter bw = new BufferedWriter(fw);			
				
		//input
		InputStreamReader isr = new InputStreamReader(new FileInputStream(filename),getCharset(filename));
		BufferedReader reader = new BufferedReader(isr);
		
		String filename_time = filename.replace("textID", "timeID");
		InputStreamReader isr_time = new InputStreamReader(new FileInputStream(filename_time),getCharset(filename_time));
		BufferedReader reader_time = new BufferedReader(isr_time);
							
		DecimalFormat df = new DecimalFormat("######0.0000");
		String line = "";
		String line_time = "";
		int tID = 0;
		long endDay = 0;//the lastest day of current teen
		
		while((line = reader.readLine()) != null && (line_time = reader_time.readLine()) != null){
			if(line.length()>0 && line_time.length()>0){
				
				//time
				String time_ID = line_time;
				String[] elem = time_ID.split(" ");
				String time = elem[1]+" "+elem[2];
				
				//set the end day for this teen
				Date sDate = string2Date(time);
				long curTime = sDate.getTime()/86400000;
				if(tID == 0){
					endDay = curTime;
				}
																
				//text
				ArrayList<ArrayList> res = 	parserOneTweet(line);
				ArrayList<String> res_cate = res.get(0);//topics GOURP: 0,1,2,3,7
				ArrayList<String> res_words = res.get(1);//special words GROUP:0-positive,1-adv
				ArrayList<String> res_rols = res.get(2);//rol, act, des
											
				bw.write(tID+" ");
				for(int i=0;i<res_words.size();i++){
					if(res_words.get(i)!="")
						bw.write(i+":"+res_words.get(i)+" | ");				//2 posiNum, degree	
				}				
				bw.write("\r\n	");
				for(int i=0;i<res_cate.size();i++){
					if(res_cate.get(i)!="")
						bw.write(i+":"+res_cate.get(i)+" | ");	//6 categories
				}
				bw.write("\r\n	");
				for(int i=0; i<res_rols.size(); i++){//3 rol, act, des
					if(res_rols.get(i)!="")
						bw.write(i+":"+res_rols.get(i)+" | ");
				}
				bw.write("\r\n");
				
			}else{
				System.out.println("null tweet error..");
			}
			
			tID++;
		}		
			
		isr.close();
		isr_time.close();
		bw.close();
		
		result.add("test for group");
		return result;
	}	
	
	public static void parseAllTeen() throws IOException, ParseException{
		//step2: parse for: [press, topics, self, suicidal, last words]
				String dirParseIn = "E:\\TEST\\POSITIVE\\Depart\\textID\\";
								
				File files2parse = new File(dirParseIn);//所有人文件夹
				if(files2parse.isDirectory()){
					String [] fileList = files2parse.list();
					ShowWords curFile = new ShowWords();
					curFile.lexiconLoad();
					for(int pos_file=0; pos_file<fileList.length; pos_file++){
						
						String filePath = dirParseIn + fileList[pos_file];			
						//function 2: parse text
						
						ArrayList<String> result = curFile.parser(filePath);					
						System.out.println(fileList[pos_file]+"	parser done");
					}
					
					System.out.println("All parser done....");
				}
	}
	
	public static void main(String[] args) throws IOException, ParseException{
		parseAllTeen();
	}
}

		