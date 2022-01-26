public with sharing class CertificaContattiController {
    
    @AuraEnabled(cacheable = true)
    public static List<Contact> getDatiContact(Id record){
        System.debug('CertificaContattiController getDatiContact --Start record: '+record);
            
            List<Contact> listaDatiContatto= new  List<contact>();
            listaDatiContatto=[SELECT Name,Email,Phone,MobilePhone,Documento_di_Identita__c,FinServ__EmailVerified__c ,FinServ__MobileVerified__c,Prefisso_Internazionale__c, RecordTypeId  FROM Contact WHERE Id=:record ];
        System.debug('CertificaContattiController getDatiContact --End listaDatiContatto: '+listaDatiContatto);  
        return listaDatiContatto;
    }

    @AuraEnabled
    public static void saveNumDoc(Id record,String numDoc){
        System.debug('CertificaContattiController saveNumDoc --Start record: '+record+' numDoc: '+numDoc);
        List<Contact> con =new List<Contact>();
        con =[SELECT Documento_di_Identita__c FROM Contact WHERE id=:record ];
        Contact cont= new Contact();
            if(con.size()>0){
                cont= con.get(0);
                cont.Documento_di_Identita__c= numDoc;
                System.debug('CertificaContattiController saveNumDoc --End cont: '+cont);  
                update cont;
            }

    }

    @AuraEnabled
    public static String getResponseSendCode(String record,String data,String type){
        System.debug('CertificaContattiController getResponseSendCode --Start record: '+record+' data: '+data+' type: '+type);
        String result=ElevaRestApiController.verifyContact(record,data,type);
        System.debug('CertificaContattiController getResponseSendCode --End result: '+result);  
        return result;
    }

    @AuraEnabled
    public static String getResponseCheckCode(String record,String code,String type){
        System.debug('CertificaContattiController getResponseCheckCode --Start record: '+record+' code: '+code+' type: '+type);
        String result=ElevaRestApiController.checkContact(record,code,type);
        System.debug('CertificaContattiController getResponseCheckCode --End result: '+result);  
        return result;
    }

  @AuraEnabled
    public static void savePhone(Id record,String phone,String prefix){
        System.debug('CertificaContattiController savePhone --Start record: '+record+' phone: '+phone+' prefix: '+prefix);
        List<Contact> con =new List<Contact>();
        con =[SELECT Id, Phone, MobilePhone, FinServ__MobileVerified__c, Prefisso_Internazionale__c FROM Contact WHERE id=:record ];
        Contact cont= new Contact();
            if(con.size()>0){
                cont= con.get(0);
                cont.FinServ__MobileVerified__c = false;
                update cont;
                cont.MobilePhone= phone;
                cont.Prefisso_Internazionale__c = prefix;
                System.debug('CertificaContattiController savePhone --End cont: '+cont);  
                update cont;
            }

    }

  @AuraEnabled
    public static void saveEmail(Id record,String email){
        System.debug('CertificaContattiController saveEmail --Start record: '+record+' email: '+email);
        List<Contact> con =new List<Contact>();
        con =[SELECT Id, Email, FinServ__EmailVerified__c FROM Contact WHERE id=:record ];
        Contact cont= new Contact();
            if(con.size()>0){
                cont= con.get(0);
                cont.FinServ__EmailVerified__c = false;
                update cont;
                cont.Email= email;
                System.debug('CertificaContattiController saveEmail --End cont: '+cont);  
                update cont;
            }

    }

    @AuraEnabled
    public static String getVerifiedFlagsFromContact(Id contId){
        System.debug('CertificaContattiController getVerifiedFlagsFromContact --Start contId: '+contId);
        List<Contact> contList = [SELECT Id,FinServ__EmailVerified__c,FinServ__MobileVerified__c FROM Contact WHERE ID =: contId];
        Contact contact= new Contact();
        if(contList.size()>0){
            contact= contList.get(0);
            system.debug('** ** FinServ__EmailVerified__c '+contact.FinServ__EmailVerified__c);
            system.debug('** ** FinServ__PhoneVerified__c '+contact.FinServ__MobileVerified__c);
            if(contact.FinServ__MobileVerified__c == true){
                System.debug('CertificaContattiController getVerifiedFlagsFromContact --End return: true');  
                return 'true';
            } else {
                System.debug('CertificaContattiController getVerifiedFlagsFromContact --End return: false');  
                return 'false';
            }
        }
        return 'null';
    }


}