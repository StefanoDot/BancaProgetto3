public with sharing class DocumentTypeController extends TriggerHandler{
    public static Boolean bypassTrigger{set;get;}
    
    public override void run(){
        if(bypassTrigger==null || bypassTrigger==false){
            super.run();
        }
    } 
    
     public override void afterInsert()
    {
        System.debug('DocumentTypeController.afterInsert trigger - Start');
        DocumentTypeController.AfterInsert(Trigger.new);
        System.debug('DocumentTypeController.afterInsert trigerr - End'); 
    }
    public static void AfterInsert(List<DocumentType__c> newDocty){
             System.debug('newDocty '+ newDocty);

       List<Id> doctytrue = new  List<Id>();
       List<Id> doctyfalse = new  List<Id>();
       List<Id> doctycontrue = new  List<Id>();
       List<Id> doctyconfalse = new  List<Id>();
       List<Id> doctyoppmutuo = new  List<Id>();
       List<Id> doctyoppeasy = new  List<Id>();
       List<Id> doctyqeasy = new  List<Id>();
       List<Id> doctyqmutuo = new  List<Id>();
         for (DocumentType__c dot : newDocty) {
             if( dot.ObjectName__c=='Account' && dot.Referente_Fidejussore__c==true){
               System.debug('ktu je fut per true ');
doctytrue.add(dot.id) ;           }
             
           else  if(dot.ObjectName__c=='Account' && dot.Referente_Fidejussore__c==false){
                  System.debug('ktu je fut per false ');
               doctyfalse.add(dot.id) ;  
             }
             else if (dot.ObjectName__c=='Contact' && dot.Referente_Fidejussore__c==true){
                  System.debug('ktu je fut te contact per true ');
               doctycontrue.add(dot.id) ; 
             }
             else if (dot.ObjectName__c=='Contact' && dot.Referente_Fidejussore__c==false){
                  System.debug('ktu je fut te contact per true ');
               doctyconfalse.add(dot.id) ; 
             }
             else if(dot.ObjectName__c=='Opportunity' && dot.Opportunita_Mutuo__c==true) {
                 doctyoppmutuo.add(dot.id) ;
             }
             else if(dot.ObjectName__c=='Opportunity' && dot.Opportunita_EasyPlus__c==true){
                 doctyoppeasy.add(dot.id) ;
             }
              else if(dot.ObjectName__c=='Quote' && dot.Opportunita_EasyPlus__c==true){
                 doctyqeasy.add(dot.id) ;
             }
              else if(dot.ObjectName__c=='Quote' && dot.Opportunita_Mutuo__c==true) {
                 doctyqmutuo.add(dot.id) ;
             }
           
        }
         System.debug('DocumentTypeController.doctytrue '+ doctytrue);
         System.debug('DocumentTypeController.doctyfalse '+ doctyfalse);
        
        if(!doctytrue.isempty() ){
         BatchDocTypeforAccountfalse k = new BatchDocTypeforAccountfalse(doctytrue);
            database.Executebatch(k,4);
        }
      else if(!doctyfalse.isempty() ){
         BatchDocTypeforAccountfalse k = new BatchDocTypeforAccountfalse(doctyfalse);
            database.Executebatch(k,5);
        }
        else if (!doctycontrue.isempty() ){
         BatchDocTypeforContact k = new BatchDocTypeforContact(doctycontrue);
            database.Executebatch(k,4);
        }
        else if (!doctyconfalse.isempty() ){
         BatchDocTypeforContact k = new BatchDocTypeforContact(doctyconfalse);
            database.Executebatch(k,4);
        }
         else if (!doctyoppmutuo.isempty() ){
         BatchDocTypeforOpp k = new BatchDocTypeforOpp(doctyoppmutuo);
            database.Executebatch(k,10);
        }
        else if (!doctyoppeasy.isempty() ){
         BatchDocTypeforOpp k = new BatchDocTypeforOpp(doctyoppeasy);
            database.Executebatch(k,10);
        }
        else if (!doctyqeasy.isempty() ){
         BatchDocTypeforQuote k = new BatchDocTypeforQuote(doctyqeasy);
            database.Executebatch(k,10);
        }
        else if (!doctyqmutuo.isempty() ){
         BatchDocTypeforQuote k = new BatchDocTypeforQuote(doctyqmutuo);
            database.Executebatch(k,10);
        }
      
    }
        
    
}