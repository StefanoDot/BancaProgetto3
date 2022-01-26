@isTest
public class BP_DownloadMassivoTest {
    

      @isTest static void DownloadmassivoTest(){
        
        Account acc = ObjectFactory.insertNewAccount();
        Opportunity o = ObjectFactory.generateOpportunity(acc);
        insert o;
          
     	Test.startTest();
         Utils.FidejussoreResponse resp = BP_OUT_DownloadMassivo.Downloadmassivo(o.Id);
         System.assert(true, resp != null);
      Test.stopTest();
          
      }


}