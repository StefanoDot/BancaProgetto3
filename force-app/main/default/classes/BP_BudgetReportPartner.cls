public with sharing class BP_BudgetReportPartner {
    @AuraEnabled
  public static Map<String, Decimal> BP_BudgetReportPartnerCalculateSum() {
   String loginUserTest = UserInfo.getUserId();
   String loginUser = Label.userBudgetId;
   List<AggregateResult> lstAccount = new List<AggregateResult>();

  // if(Test.isRunningTest()){
     lstAccount = [select Owner.Id, SUM(Gennaio_CF__c) sumGenCf, SUM(Gennaio_LL__c) sumGenLl, SUM(Budget_Gennaio__c) sumGenLi, SUM(Febbraio_CF__c) sumFebCf, SUM(Febbraio_LL__c) sumFebLl, SUM(Budget_Febbraio__c) sumFebLi, SUM(Marzo_CF__c) sumMarCf, SUM(Marzo_LL__c) sumMarLl, SUM(Budget_Marzo__c) sumMarLi,SUM(Aprile_CF__c) sumAprCf, SUM(Aprile_LL__c) sumAprLl, SUM(Budget_Aprile__c) sumAprLi, SUM(Maggio_CF__c) sumMagCf, SUM(Maggio_LL__c) sumMagLl, SUM(Budget_Maggio__c) sumMagLi, SUM(Giugno_CF__c) sumGiuCf, SUM(Giugno_LL__c) sumGiuLl, SUM(Budget_Giugno__c) sumGiuLi, SUM(Luglio_CF__c) sumLugCf, SUM(Luglio_LL__c) sumLugLl, SUM(Budget_Luglio__c) sumLugLi, SUM(Agosto_CF__c) sumAgoCf, SUM(Agosto_LL__c) sumAgoLl, SUM(Budget_Agosto__c) sumAgoLi, SUM(Settembre_CF__c) sumSetCf, SUM(Settembre_LL__c) sumSetLl, SUM(Budget_Settembre__c) sumSetLi, SUM(Ottobre_CF__c) sumOttCf, SUM(Ottobre_LL__c) sumOttLl, SUM(Budget_Ottobre__c) sumOttLi,SUM(Novembre_CF__c) sumNovCf, SUM(Novembre_LL__c) sumNovLl, SUM(Budget_Novembre__c) sumNovLi, SUM(Dicembre_CF__c) sumDicCf, SUM(Dicembre_LL__c) sumDicLl, SUM(Budget_Dicembre__c) sumDicLi from Account where Owner.Id =: loginUserTest group by Owner.Id];
  //  } else {
  //   lstAccount = [select Owner.Id, SUM(Gennaio_CF__c) sumGenCf, SUM(Gennaio_LL__c) sumGenLl, SUM(Budget_Gennaio__c) sumGenLi, SUM(Febbraio_CF__c) sumFebCf, SUM(Febbraio_LL__c) sumFebLl, SUM(Budget_Febbraio__c) sumFebLi, SUM(Marzo_CF__c) sumMarCf, SUM(Marzo_LL__c) sumMarLl, SUM(Budget_Marzo__c) sumMarLi,SUM(Aprile_CF__c) sumAprCf, SUM(Aprile_LL__c) sumAprLl, SUM(Budget_Aprile__c) sumAprLi, SUM(Maggio_CF__c) sumMagCf, SUM(Maggio_LL__c) sumMagLl, SUM(Budget_Maggio__c) sumMagLi, SUM(Giugno_CF__c) sumGiuCf, SUM(Giugno_LL__c) sumGiuLl, SUM(Budget_Giugno__c) sumGiuLi, SUM(Luglio_CF__c) sumLugCf, SUM(Luglio_LL__c) sumLugLl, SUM(Budget_Luglio__c) sumLugLi, SUM(Agosto_CF__c) sumAgoCf, SUM(Agosto_LL__c) sumAgoLl, SUM(Budget_Agosto__c) sumAgoLi, SUM(Settembre_CF__c) sumSetCf, SUM(Settembre_LL__c) sumSetLl, SUM(Budget_Settembre__c) sumSetLi, SUM(Ottobre_CF__c) sumOttCf, SUM(Ottobre_LL__c) sumOttLl, SUM(Budget_Ottobre__c) sumOttLi,SUM(Novembre_CF__c) sumNovCf, SUM(Novembre_LL__c) sumNovLl, SUM(Budget_Novembre__c) sumNovLi, SUM(Dicembre_CF__c) sumDicCf, SUM(Dicembre_LL__c) sumDicLl, SUM(Budget_Dicembre__c) sumDicLi from Account where Owner.Id =: loginUserTest group by Owner.Id];
//}

        Decimal sumGen = (Decimal)lstAccount[0].get('sumGenCf') + (Decimal)lstAccount[0].get('sumGenLl') + (Decimal)lstAccount[0].get('sumGenLi');
        Decimal sumFeb = (Decimal)lstAccount[0].get('sumFebCf') + (Decimal)lstAccount[0].get('sumFebLl') + (Decimal)lstAccount[0].get('sumFebLi');
        Decimal sumMar = (Decimal)lstAccount[0].get('sumMarCf') + (Decimal)lstAccount[0].get('sumMarLl') + (Decimal)lstAccount[0].get('sumMarLi');
        Decimal sumApr = (Decimal)lstAccount[0].get('sumAprCf') + (Decimal)lstAccount[0].get('sumAprLl') + (Decimal)lstAccount[0].get('sumAprLi');
        Decimal sumMag = (Decimal)lstAccount[0].get('sumMagCf') + (Decimal)lstAccount[0].get('sumMagLl') + (Decimal)lstAccount[0].get('sumMagLi');
        Decimal sumGiu = (Decimal)lstAccount[0].get('sumGiuCf') + (Decimal)lstAccount[0].get('sumGiuLl') + (Decimal)lstAccount[0].get('sumGiuLi');
        Decimal sumLug = (Decimal)lstAccount[0].get('sumLugCf') + (Decimal)lstAccount[0].get('sumLugLl') + (Decimal)lstAccount[0].get('sumLugLi');
        Decimal sumAgo = (Decimal)lstAccount[0].get('sumAgoCf') + (Decimal)lstAccount[0].get('sumAgoLl') + (Decimal)lstAccount[0].get('sumAgoLi');
        Decimal sumSet = (Decimal)lstAccount[0].get('sumSetCf') + (Decimal)lstAccount[0].get('sumSetLl') + (Decimal)lstAccount[0].get('sumSetLi');
        Decimal sumOtt = (Decimal)lstAccount[0].get('sumOttCf') + (Decimal)lstAccount[0].get('sumOttLl') + (Decimal)lstAccount[0].get('sumOttLi');
        Decimal sumNov = (Decimal)lstAccount[0].get('sumNovCf') + (Decimal)lstAccount[0].get('sumNovLl') + (Decimal)lstAccount[0].get('sumNovLi');
        Decimal sumDic = (Decimal)lstAccount[0].get('sumDicCf') + (Decimal)lstAccount[0].get('sumDicLl') + (Decimal)lstAccount[0].get('sumDicLi');

    List<AggregateResult> lstBudget = [Select Mese_di_Riferimento__c, SUM(Importo__c) sumBudget FROM BudgetMensile__c where CreatedById =: loginUser group by Mese_di_Riferimento__c];
    List<String> lstMesi = new List<String>{'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno', 'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'};
    Map<String, Decimal> returnMap = new Map<String, Decimal>{
        'Gennaio' => sumGen,
        'Febbraio' => sumFeb,
        'Marzo' => sumMar,
        'Aprile' => sumApr,
        'Maggio' => sumMag,
        'Giugno' => sumGiu,
        'Luglio' => sumLug,
        'Agosto' => sumAgo,
        'Settembre' => sumSet,
        'Ottobre' => sumOtt,
        'Novembre' => sumNov, 
        'Dicembre' => sumDic
    };
    for(AggregateResult aggr : lstBudget){
            Decimal finalSum = 0;
            String mese = (String)aggr.get('Mese_di_Riferimento__c');
            System.debug('mese ' + mese);
        switch on mese {
            when 'Gennaio' {
                finalSum = sumGen + (Decimal)aggr.get('sumBudget'); 
            } when 'Febbraio' {
                finalSum = sumFeb + (Decimal)aggr.get('sumBudget');
            } when 'Marzo' {
                finalSum = sumMar + (Decimal)aggr.get('sumBudget');
            } when 'Aprile' {
                finalSum = sumApr + (Decimal)aggr.get('sumBudget');
            } when 'Maggio' {
                finalSum = sumMag + (Decimal)aggr.get('sumBudget');
            } when 'Giugno' {
                finalSum = sumGiu + (Decimal)aggr.get('sumBudget');
            } when 'Luglio' {
                finalSum = sumLug + (Decimal)aggr.get('sumBudget');
            } when 'Agosto' {
                finalSum = sumAgo + (Decimal)aggr.get('sumBudget');
            } when 'Settembre' {
                finalSum = sumSet + (Decimal)aggr.get('sumBudget');
            } when 'Ottobre' {
                finalSum = sumOtt + (Decimal)aggr.get('sumBudget');
            } when 'Novembre' {
                finalSum = sumNov + (Decimal)aggr.get('sumBudget');
            } when 'Dicembre' {
                finalSum = sumDic + (Decimal)aggr.get('sumBudget');
            }
        }
        returnMap.put(mese, finalSum);
        }
        System.debug('returnMap budget '+ returnMap);
    return returnMap;
  }
  @AuraEnabled
  public static Map<String, Decimal> BP_BudgetReportPartnerExistingImport() {
    String loginUserTest = UserInfo.getUserId();
    String loginUser = Label.userBudgetId;
    List<AggregateResult> lstOpportunity = new List<AggregateResult>();
   // if(Test.isRunningTest()){
    //    lstOpportunity = [SELECT CALENDAR_MONTH(CloseDate) mese, SUM(Amount) sumImportOppty FROM Opportunity where Account.Owner.Id =: loginUserTest and StageName = 'Erogata' group by CALENDAR_MONTH(CloseDate)];
  //  } else {
        lstOpportunity = [SELECT CALENDAR_MONTH(CloseDate) mese, SUM(Amount) sumImportOppty FROM Opportunity where Account.Owner.Id =: loginUserTest and StageName = 'Erogata' group by CALENDAR_MONTH(CloseDate)];  
   // }
    Map<String, Decimal> sumMap = new Map<String, Decimal>();
    Map<String, Decimal> returnMap = new Map<String, Decimal>{
        'Gennaio' => 0,
        'Febbraio' => 0,
        'Marzo' => 0,
        'Aprile' => 0,
        'Maggio' => 0,
        'Giugno' => 0,
        'Luglio' => 0,
        'Agosto' => 0,
        'Settembre' => 0,
        'Ottobre' => 0,
        'Novembre' => 0, 
        'Dicembre' => 0
    };
      for(AggregateResult aggr : lstOpportunity){
        Decimal finalSum = 0;
        Integer meseInt = (Integer)aggr.get('mese');
        String meseStr;
        System.debug('mese + final sum ' + meseInt);
        System.debug('mese + final sum  ' + finalSum);
        switch on meseInt {
            when 01 {
                finalSum = (Decimal)aggr.get('sumImportOppty');
                meseStr = 'Gennaio';
                System.debug('mese + final sum gennaio ' + meseInt);
                System.debug('mese + final sum gennaio ' + finalSum);
            } when 02 {
                 finalSum = (Decimal)aggr.get('sumImportOppty');
                meseStr = 'Febbraio';
            } when 03 {
                 finalSum = (Decimal)aggr.get('sumImportOppty');
                meseStr = 'Marzo';
            } when 04 {
                 finalSum = (Decimal)aggr.get('sumImportOppty');
                meseStr = 'Aprile';
            } when 05 {
                 finalSum = (Decimal)aggr.get('sumImportOppty');
                meseStr = 'Maggio';
            } when 06 {
                 finalSum = (Decimal)aggr.get('sumImportOppty');
                meseStr = 'Giugno';
            } when 07 {
                 finalSum = (Decimal)aggr.get('sumImportOppty');
                meseStr = 'Luglio';
            } when 08 {
                 finalSum = (Decimal)aggr.get('sumImportOppty');
                meseStr = 'Agosto';
                System.debug('mese + final sum ago ' + meseInt);
                System.debug('mese + final sum ago ' + finalSum);
            } when 09 {
                 finalSum = (Decimal)aggr.get('sumImportOppty');
                meseStr = 'Settembre';
                System.debug('mese + final sum set ' + meseInt);
                System.debug('mese + final sum set ' + finalSum);
            } when 10 {
                 finalSum = (Decimal)aggr.get('sumImportOppty');
                meseStr = 'Ottobre';
            } when 11 {
                 finalSum = (Decimal)aggr.get('sumImportOppty');
                meseStr = 'Novembre';
            } when 12 {
                 finalSum = (Decimal)aggr.get('sumImportOppty');
                meseStr = 'Dicembre';
            }
        }
        // da cambiareeee qui 
        returnMap.put( meseStr, finalSum);
        }
        System.debug('sumMap budget '+ sumMap);
    return returnMap;
  }
}