//ALDORA HAJRO 21.08.2020

public class AmmontareInLettere {
    
    public static integer intNum;     // for integer part
    public static integer decNum;     // for decimal part
    public static String numInWords; // For currency in Words
    
    public static String bigCurrencySingular    = '';
    public static String bigCurrencyplural      = '';
    public static String smlCurrencySingular    = '';
    public static String smlCurrencyplural      = '';
    
    public static String[]  ones = new string[] {  'un',  'uno',  'due',  'tre', 'quattro', 'cinque', 'sei', 'sette',  'otto',  'nove',  'dieci',  'undici', 'dodici','tredici', 'quattordici','quindici', 'sedici','diciassette', 'diciotto',  'diciannove'};
        public static String[]  tens = new string[] { '',  'dieci',  'venti',  'trenta', 'quaranta', 'cinquanta','sessanta',  'settanta', 'ottanta', 'novanta' };
            public static integer[] base = new integer[]{0,1,10,100,1000,1000,1000,1000000,1000000,1000000,1000000000};
                public static String[]  unit = new String[] { '', '', '', 'cento', ' mille ', 'mila ', 'mila ',' milione ', ' milioni ', ' milioni ', ' miliardo ', ' miliardi ', ' miliardi ', ' billione ', ' billioni ', ' billioni ', 'biliardo '};
                    
                    public static String CurrencyToWordsFormat(Integer num){
           
                        
                        intNum = num;
                        if( intNum == 0 )
                            numInWords = 'Zero ';
                        if( intNum > 0 ){
                            if( intNum == 1 )
                                numInWords = NumberToWords(intNum) + bigCurrencySingular;
                            else
                                numInWords = NumberToWords(intNum) + bigCurrencyplural;
                        }
                        System.debug(num+' : '+numInWords);
                        return numInWords;
                    }
    
    public static String CurrencyToWordsFormat(Decimal num){
        String numToString = String.valueOf(num);
        List<String> parts = numToString.split('\\.');
        if( parts != null && parts.size()>0 ){
            intNum = Integer.valueOf(parts[0]);
            decNum = Integer.valueOf(parts[1]);
        }
        if( intNum == 0 )
            numInWords = 'Zero ';
        if( intNum > 0 ){
            if( intNum == 1 )
                numInWords = NumberToWords(intNum-1) + bigCurrencySingular;
            else
                numInWords = NumberToWords(intNum) + bigCurrencyplural;
        }
        if( decNum > 0 ){
            if( decNum == 1 )
                numInWords +='\\ ' + NumberToWords(decNum-1) + smlCurrencySingular;
            else
                numInWords += '\\ ' + NumberToWords(decNum) + smlCurrencyplural;
        }
        System.debug(num+' : '+numInWords);
        return numInWords;
    }
    
    public static String CurrencyToWordsFormat(Double num){
        String numToString = String.valueOf(num);
        List<String> parts = numToString.split('\\.');
        if( parts != null && parts.size()>0 ){
            intNum = Integer.valueOf(parts[0]);
            decNum = Integer.valueOf(parts[1]);
        }
        if( intNum == 0 )
            numInWords = 'Zero';
        if( intNum > 0 ){
            if( intNum == 1 )
                numInWords = ' e ' + NumberToWords(intNum) + bigCurrencySingular;
            else
                numInWords = NumberToWords(intNum) + bigCurrencyplural;
        }
        if( decNum > 0 ){
            if( decNum == 1 )
                numInWords += 'e ' + NumberToWords(decNum) + smlCurrencySingular;
            else
                numInWords += 'e ' + NumberToWords(decNum) + smlCurrencyplural;
        }    
        System.debug(num+' : '+numInWords);
        return numInWords;
    }
    
    public static String NumberToWords(Integer num){
        String words = '';
        integer digit, den, rem;
        digit = String.valueOf(num).length(); //gjatesia e numrit
        //  System.debug('digit '+digit);
        
        den = num / base[digit];
        //    system.debug('den ' + den);
        
        rem = Math.mod(num,base[digit]);
        //   System.debug('rem ' + rem);
        
        if( digit == 1 ){
            words = ones[num];
        }
        
        else if( digit == 2 ){
            if( den == 1 && rem >0 )
            {
                words = ones[num];
                
            }
            else{
                //    system.debug('den ' + den);
                words = tens[den];
                /*    system.debug('words ' + words);
					  system.debug('rem ' + rem);*/
                if( rem > 0 ){
                    if(rem==1 || rem==8){
                        words = words.Substring(0,words.length()-1); //heq shkronjen e fundit kur kane 1 ose 8 pas
                        words += NumberToWords(rem); }
                    
                  else if(rem==3){
                        //  words += NumberToWords(rem);
                        words += 'tré'; //e ben tré
                        
                        
                    }
                    else
                        words += NumberToWords(rem);
                    
                }
            }
        }
        else if( digit > 2 ){
            /*    system.debug('den ' + den);
				  system.debug('digit ' + digit);
                  system.debug('rem ' + rem);*/
            
            {  
                
                if (den==1 && (digit==3 || digit==4) )//heq une para cento dhe milla
                    words += unit[digit]; 
                
                else if (den==1 && (digit==1 || digit==7 || digit==10 || digit==13 || digit==16))//kur eshte vetem 1 e ben un
                    words += NumberToWords(den-1)+unit[digit];
                
                else   if (den!=1 && (digit==4 || digit==7 || digit==10 || digit==13 || digit==16) ) //nqs nuk eshte 1 numri e ben milla. milioni e me rradhe
                    words += NumberToWords(den)+unit[digit+1]; 
                
                
                else
                    words += NumberToWords(den)+unit[digit]; 	
            }
            if( rem > 0 )
                  if(rem==1 || rem==8 || (rem>79 && rem<90)){
                        words = words.Substring(0,words.length()-1); //heq shkronjen e fundit kur kane 1 ose 8 pas ose 80
                        words += NumberToWords(rem); }
            else
                words += NumberToWords(rem);
        }
        return words;
    }
}