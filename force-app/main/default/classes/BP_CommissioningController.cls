public class BP_CommissioningController {

public static Map <Id, List<String>> generateString(List<Opportunity> oppInErogazione){
System.debug('commisioningController.generateString --- Start oppInErogazione: ' + oppInErogazione);


Map<Id, List<String>> mapOpportunityString = new Map<Id, List<String>> ();

for(Opportunity o : oppInErogazione){
    List<String> finaleListString = new List<String>();
                    
                System.debug('o.Quotes: ' + o.Quotes);
                
                for(Quote q : o.Quotes){

                String finale = '';   
                    
                    finale += 'BPR'+'MUT'+'I';
                    System.debug('finale1-7: ' + finale);
                    
                    if(o.Owner.Profile.Name=='Mediatore Creditizio'){
                        finale += 'CHIROMED'+'  ';
                     
                    }
                    else if(o.Owner.Profile.Name=='Agente'){
                        finale += 'CHIROAGE'+'  ';
                    }
                 System.debug('o.Owner.Profile.Name 1 ' + o.Owner.Profile.Name);
                    System.debug('finale8-17: ' + finale);
                    if(o.Owner.Profile.Name=='Mediatore Creditizio'){
                    finale += 'CHIROMED'+'  ';
                    }
                    else if(o.Owner.Profile.Name=='Agente'){
                    finale += 'CHIROAGE'+'  ';
                    }
                System.debug('o.Owner.Profile.Name 2' + o.Owner.Profile.Name);
                    System.debug('finale18-27: ' + finale);
                        
                        System.debug('q.Numero_Rapporto__c: ' + q.Numero_Rapporto__c);
                        String numRap= q.Numero_Rapporto__c;
                        if(numRap != null){
                            finale += q.Numero_Rapporto__c.rightPad(15); 
                        } else {
                            finale += '000000000000000';
                        }
                        System.debug('finale28-42: ' + finale);
                        
                        System.debug('mapAccounts.get(o.AccountId).AccountNumber: ' + o.Account.AccountNumber);
                        String accNumber = o.Account.AccountNumber;
                        if(accNumber != null){
                            finale += accNumber.rightPad(16);
                        } else {
                            finale += '0000000000000000';
                        }
                        System.debug('finale43-58: ' + finale);
                        
                        System.debug('o.Owner.CF_P_IVA__c: ' + o.Owner.CF_P_IVA__c);
                        String pIva= o.Owner.CF_P_IVA__c;
                        if(pIva != null){
                        finale += pIva.leftPad(16,' ');
                        } else {
                            finale += '0000000000000000';
                        }
                        System.debug('finale59-74: ' + finale);
                        
                        finale+='U';
                        System.debug('finale75-75: ' + finale);
                        
                        Decimal rate=0;
                        String Periodiciteti = q.Periodicita__c;
                        if (Periodiciteti == 'mensile'){
                            rate=q.Durata_in_mesi__c/1;
                        }
                        else if (Periodiciteti == 'bimestrale'){
                            rate=q.Durata_in_mesi__c/2;
                        }
                        else if (Periodiciteti == 'trimestrale'){
                            rate=q.Durata_in_mesi__c/3;
                        }
                        else if (Periodiciteti == 'quadrimestrale'){
                            rate=q.Durata_in_mesi__c/4;
                        }
                        else if (Periodiciteti == 'semestrale'){
                            rate=q.Durata_in_mesi__c/6;
                        }
                        
                        System.debug('rate: ' + rate);
                        Integer rateInt=(Integer)rate.round(System.RoundingMode.UP);
                        Integer rateLength = (Integer)(Math.log10(rateInt)+1);
                        Integer i=0;
                        while(i<(3-rateLength)){
                            finale += '0';
                            i++;
                        }
                        finale += rateInt;
                        System.debug('finale76-78: ' + finale); 

                        finale += '000000000000000';
                        System.debug('finale79-93: ' + finale);
                                                        
                        System.debug('q.Periodicita__c: ' + q.Periodicita__c);
                        
                        String periodicita = q.Periodicita__c;
                        if(periodicita != null){
                            String shkronja = periodicita.substring(0,1).capitalize();
                            finale += shkronja;
                        } else {
                            finale += ' ';
                        }
                        System.debug('finale94-94: ' + finale);

                        finale += 'EROGAZIONE';
                        System.debug('finale95-104: ' + finale);

                        System.debug('Data_Firma__c: ' + q.Data_Firma__c);
                        DateTime dataFirma = q.Data_Firma__c;
                        if(dataFirma != null){
                            String dataFirmaStr = dataFirma.format('yyyyMMdd');
                            finale += dataFirmaStr;
                        } else {
                            finale += '00000000';
                        }
                        System.debug('finale105-112: ' + finale);

                        System.debug('q.Ammontare_Deliberato__c: ' + q.Ammontare_Deliberato__c);
                        if(q.Ammontare_Deliberato__c != null){
                            Decimal ammontareDeliberato = q.Ammontare_Deliberato__c;
                            String s = String.valueOf(ammontareDeliberato);
                            String beforeDecimal = s.substringBefore('.');
                            String afterDecimal = s.substringAfter('.');
                            finale += beforeDecimal.leftPad(12,'0') + afterDecimal.rightPad(3,'0');
                        } else {
                            finale += '000000000000000';
                        }
                        System.debug('finale113-127: ' + finale);

                        finale += '000000000000000';
                        System.debug('finale128-142: ' + finale);

                        finale += '000000000000000';
                        System.debug('finale143-157: ' + finale);
                        
                        System.debug('o.Data_Erogazione__c: ' + o.Data_Erogazione__c);
                        DateTime dataErogazione = o.Data_Erogazione__c;
                        if(dataErogazione != null){
                            String dataErogazioneStr = dataErogazione.format('yyyyMMdd');
                            finale += dataErogazioneStr;
                        } else {
                            finale += '00000000';
                        }
                        System.debug('finale158-165: ' + finale);
                        finale += '00000000';
                        System.debug('finale166-173: ' + finale);
                        
                        System.debug('q.Percentuale_Commissioni_da_Istruttoria__c: ' + q.Percentuale_Commissioni_da_Istruttoria__c);
                        Decimal commissioniDaIstruttoria= q.Percentuale_Commissioni_da_Istruttoria__c;
                        if(commissioniDaIstruttoria != null){
                            String st = String.valueOf(commissioniDaIstruttoria);
                            String befDecimal = st.substringBefore('.');
                            String afDecimal = st.substringAfter('.');
                            finale += befDecimal.leftPad(3,'0')+ afDecimal.rightPad(3,'0');
                        } else {
                            finale += '000000';
                        }
                        System.debug('finale174-179: ' + finale);   
                        
                        System.debug('q.Importo_Commissioni_di_Istruttoria__c: ' + q.Importo_Commissioni_di_Istruttoria__c);
                        Decimal importoCommissioni= q.Importo_Commissioni_di_Istruttoria__c;
                        if(importoCommissioni != null){
                            String str = String.valueOf(importoCommissioni);
                            String befDec = str.substringBefore('.');
                            String afDec = str.substringAfter('.'); 
                            finale += befDec.leftPad(12,'0')+ afDec.rightPad(3,'0');
                        } else { 
                            finale += '000000000000000';
                        }
                        System.debug('finale180-194: ' + finale);    
                        
                        System.debug('q.Percentuale_Spread__c: ' + q.Percentuale_Spread__c);
                    
                        Decimal percentualeSpread = q.Percentuale_Spread__c;
                        if(percentualeSpread != null){
                            String strg = String.valueOf(percentualeSpread);
                            String beforeDec = strg.substringBefore('.');
                            String afterDec = strg.substringAfter('.');
                            finale += beforeDec.leftPad(3,'0')+ afterDec.rightPad(3,'0');
                        } else {
                            finale += '000000';
                        }
                        System.debug('finale195-200: ' + finale);

                        finale += '  ';
                        System.debug('finale201-202: ' + finale);

                        System.debug('o.Finalita_Finanziamento__c: ' + o.Finalita_Finanziamento__c);
                        if(o.Finalita_Finanziamento__c== 'Liquidita'){
                            finale+= 'N';
                        }
                        else {
                            finale+= 'S';
                        }
                        System.debug('finale203-203: ' + finale);
                        
                        finaleListString.add(finale);
                }
                    
                    mapOpportunityString.put(o.id, finaleListString);  
}   

System.debug('commisioningController.generateString --- End');
return mapOpportunityString;
}

public class CommissioningFileWrapper {
@AuraEnabled public Id opportunityId  {get;set;}
@AuraEnabled public String fileName {get;set;}
@AuraEnabled public Id ownerId {get;set;}
@AuraEnabled public String fileBody {get;set;}
public CommissioningFileWrapper(Id opportunityId,  Id ownerId, String fileName, String fileBody){
this.opportunityId = opportunityId;
this.ownerId = ownerId;
this.fileName = fileName;
this.fileBody = fileBody;
}
}

}