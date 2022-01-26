public with sharing class ExcelGeneratorController {

public class wrapper{
    public string Id {get; set;}
    public string Agente {get; set;}
    public string Mese {get; set;}
    public Decimal Importo {get; set;}
    public string Provincia {get; set;}
    public string Tipo {get; set;}
}

    public string header{get;set;}
    public List<wrapper> lstwrapper {get; set;}


    public string Filetype{get;set;}
    public boolean isExcel {get;set;}
    public boolean isCsv {get;set;}   

    public ExcelGeneratorController(){
            Filetype = '';
            lstwrapper = new List<wrapper>();
            header = 'Id, Agente, Mese, Importo, Provincia, Tipo \r\n';                     
    }


    public void exportToExcel(){
            string queryString = 'select id, owner.CompanyName,  Sigla_Provincia__c,  IsPartner,Budget_Gennaio__c,Budget_Febbraio__c,Budget_Marzo__c,Budget_Aprile__c,Budget_Maggio__c,Budget_Giugno__c,Budget_Luglio__c,Budget_Agosto__c,Budget_Settembre__c,Budget_Ottobre__c,Budget_Novembre__c,Budget_Dicembre__c, Totale__c, Gennaio_LL__c, Febbraio_LL__c, Marzo_LL__c, Aprile_LL__c, Maggio_LL__c, Giugno_LL__c, Luglio_LL__c, Agosto_LL__c, Settembre_LL__c, Ottobre_LL__c, Novembre_LL__c, Dicembre_LL__c,Totale_LL__c, Gennaio_CF__c, Febbraio_CF__c, Marzo_CF__c, Aprile_CF__c, Maggio_CF__c, Giugno_CF__c, Luglio_CF__c, Agosto_CF__c, Settembre_CF__c, Ottobre_CF__c, Novembre_CF__c, Dicembre_CF__c, Totale_CF__c from account where IsPartner = false AND (Totale__c != null OR Totale_LL__c != null OR Totale_CF__c != null)'; 
        
            List<Account> lstAccount = DataBase.Query(queryString);
            system.debug('lstAccount :'+lstAccount.size());
            if(lstAccount.size()>0){
            for(Account acc :lstAccount){
            if(acc.Budget_Gennaio__c != 0 && acc.Budget_Gennaio__c != null){
                    wrapper w = new wrapper();
                    w.Id = acc.Id ;
                    w.Agente = acc.owner.CompanyName;
                    w.Provincia = acc.Sigla_Provincia__c;
                    w.Mese = 'Gennaio';
                    w.Importo = acc.Budget_Gennaio__c;
                    w.Tipo = 'Investimenti';
                    lstwrapper.add(w);               
            }   
            if(acc.Budget_Febbraio__c != 0 && acc.Budget_Febbraio__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Febbraio';
                w.Importo = acc.Budget_Febbraio__c;
                w.Tipo = 'Investimenti';
                lstwrapper.add(w);               
            } 
            if(acc.Budget_Marzo__c != 0 && acc.Budget_Marzo__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Marzo';
                w.Importo = acc.Budget_Marzo__c;
                w.Tipo = 'Investimenti';
                lstwrapper.add(w);               
            }
            if(acc.Budget_Aprile__c != 0 && acc.Budget_Aprile__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Aprile';
                w.Importo = acc.Budget_Aprile__c;
                w.Tipo = 'Investimenti';
                lstwrapper.add(w);               
            }
            if(acc.Budget_Maggio__c != 0 && acc.Budget_Maggio__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Maggio';
                w.Importo = acc.Budget_Maggio__c;
                w.Tipo = 'Investimenti';
                lstwrapper.add(w);               
            }
            if(acc.Budget_Giugno__c != 0 && acc.Budget_Giugno__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Giugno';
                w.Importo = acc.Budget_Giugno__c;
                w.Tipo = 'Investimenti';
                lstwrapper.add(w);               
            }
            if(acc.Budget_Luglio__c != 0 &&  acc.Budget_Luglio__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Luglio';
                w.Importo = acc.Budget_Luglio__c;
                w.Tipo = 'Investimenti';
                lstwrapper.add(w);               
            }
            if(acc.Budget_Agosto__c != 0 && acc.Budget_Agosto__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Agosto';
                w.Importo = acc.Budget_Agosto__c;
                w.Tipo = 'Investimenti';
                lstwrapper.add(w);               
            }
            if(acc.Budget_Settembre__c != 0 && acc.Budget_Settembre__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Settembre';
                w.Importo = acc.Budget_Settembre__c;
                w.Tipo = 'Investimenti';
                lstwrapper.add(w);               
            }
            if(acc.Budget_Ottobre__c != 0 && acc.Budget_Ottobre__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Ottobre';
                w.Importo = acc.Budget_Ottobre__c;
                w.Tipo = 'Investimenti';
                lstwrapper.add(w);               
            }
            if(acc.Budget_Novembre__c != 0 && acc.Budget_Novembre__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Novembre';
                w.Importo = acc.Budget_Novembre__c;
                w.Tipo = 'Investimenti';
                lstwrapper.add(w);               
            }
            if(acc.Budget_Dicembre__c != 0 && acc.Budget_Dicembre__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Dicembre';
                w.Importo = acc.Budget_Dicembre__c;
                w.Tipo = 'Investimenti';
                lstwrapper.add(w);               
            }  
            if(acc.Gennaio_LL__c != 0 && acc.Gennaio_LL__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Gennaio';
                w.Importo = acc.Gennaio_LL__c;
                w.Tipo = 'Liquidità';
                lstwrapper.add(w);               
            }   
            if(acc.Febbraio_LL__c != 0 && acc.Febbraio_LL__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Febbraio';
                w.Importo = acc.Febbraio_LL__c;
                w.Tipo = 'Liquidità';
                lstwrapper.add(w);               
            } 
            if(acc.Marzo_LL__c != 0 && acc.Marzo_LL__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Marzo';
                w.Importo = acc.Marzo_LL__c;
                w.Tipo = 'Liquidità';
                lstwrapper.add(w);               
            }
            if(acc.Aprile_LL__c != 0 && acc.Aprile_LL__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Aprile';
                w.Importo = acc.Aprile_LL__c;
                w.Tipo = 'Liquidità';
                lstwrapper.add(w);               
            }
            if(acc.Maggio_LL__c != 0 && acc.Maggio_LL__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Maggio';
                w.Importo = acc.Maggio_LL__c;
                w.Tipo = 'Liquidità';
                lstwrapper.add(w);               
            }
            if(acc.Giugno_LL__c != 0 && acc.Giugno_LL__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Giugno';
                w.Importo = acc.Giugno_LL__c;
                w.Tipo = 'Liquidità';
                lstwrapper.add(w);               
            }
            if(acc.Luglio_LL__c != 0 && acc.Luglio_LL__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Luglio';
                w.Importo = acc.Luglio_LL__c;
                w.Tipo = 'Liquidità';
                lstwrapper.add(w);               
            }
            if(acc.Agosto_LL__c != 0 && acc.Agosto_LL__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Agosto';
                w.Importo = acc.Agosto_LL__c;
                w.Tipo = 'Liquidità';
                lstwrapper.add(w);               
            }
            if(acc.Settembre_LL__c != 0 && acc.Settembre_LL__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Settembre';
                w.Importo = acc.Settembre_LL__c;
                w.Tipo = 'Liquidità';
                lstwrapper.add(w);               
            }
            if(acc.Ottobre_LL__c != 0 && acc.Ottobre_LL__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Ottobre';
                w.Importo = acc.Ottobre_LL__c;
                w.Tipo = 'Liquidità';
                lstwrapper.add(w);               
            }
            if(acc.Novembre_LL__c != 0 && acc.Novembre_LL__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Novembre';
                w.Importo = acc.Novembre_LL__c;
                w.Tipo = 'Liquidità';
                lstwrapper.add(w);               
            }
            if(acc.Dicembre_LL__c != 0 && acc.Dicembre_LL__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Dicembre';
                w.Importo = acc.Dicembre_LL__c;
                w.Tipo = 'Liquidità';
                lstwrapper.add(w);               
            }
            if(acc.Gennaio_CF__c != 0 && acc.Gennaio_CF__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Gennaio';
                w.Importo = acc.Gennaio_CF__c;
                w.Tipo = 'Crediti Fiscali';
                lstwrapper.add(w);               
            }   
            if(acc.Febbraio_CF__c != 0 && acc.Febbraio_CF__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Febbraio';
                w.Importo = acc.Febbraio_CF__c;
                w.Tipo = 'Crediti Fiscali';
                lstwrapper.add(w);               
            } 
            if(acc.Marzo_CF__c != 0 && acc.Marzo_CF__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Marzo';
                w.Importo = acc.Marzo_CF__c;
                w.Tipo = 'Crediti Fiscali';
                lstwrapper.add(w);               
            }
            if(acc.Aprile_CF__c != 0 && acc.Aprile_CF__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Aprile';
                w.Importo = acc.Aprile_CF__c;
                w.Tipo = 'Crediti Fiscali';
                lstwrapper.add(w);               
            }
            if(acc.Maggio_CF__c != 0 && acc.Maggio_CF__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Maggio';
                w.Importo = acc.Maggio_CF__c;
                w.Tipo = 'Crediti Fiscali';
                lstwrapper.add(w);               
            }
            if(acc.Giugno_CF__c != 0 && acc.Giugno_CF__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Giugno';
                w.Importo = acc.Giugno_CF__c;
                w.Tipo = 'Crediti Fiscali';
                lstwrapper.add(w);               
            }
            if(acc.Luglio_CF__c != 0 && acc.Luglio_CF__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Luglio';
                w.Importo = acc.Luglio_CF__c;
                w.Tipo = 'Crediti Fiscali';
                lstwrapper.add(w);               
            }
            if(acc.Agosto_CF__c != 0 && acc.Agosto_CF__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Agosto';
                w.Importo = acc.Agosto_CF__c;
                w.Tipo = 'Crediti Fiscali';
                lstwrapper.add(w);               
            }
            if(acc.Settembre_CF__c != 0 && acc.Settembre_CF__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Settembre';
                w.Importo = acc.Settembre_CF__c;
                w.Tipo = 'Crediti Fiscali';
                lstwrapper.add(w);               
            }
            if(acc.Ottobre_CF__c != 0 && acc.Ottobre_CF__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Ottobre';
                w.Importo = acc.Ottobre_CF__c;
                w.Tipo = 'Crediti Fiscali';
                lstwrapper.add(w);               
            }
            if(acc.Novembre_CF__c != 0 && acc.Novembre_CF__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Novembre';
                w.Importo = acc.Novembre_CF__c;
                w.Tipo = 'Crediti Fiscali';
                lstwrapper.add(w);               
            }
            if(acc.Dicembre_CF__c != 0 && acc.Dicembre_CF__c != null){
                wrapper w = new wrapper();
                w.Id = acc.Id ;
                w.Agente = acc.owner.CompanyName;
                w.Provincia = acc.Sigla_Provincia__c;
                w.Mese = 'Dicembre';
                w.Importo = acc.Dicembre_CF__c;
                w.Tipo = 'Crediti Fiscali';
                lstwrapper.add(w);               
            }
            }
            system.debug('lstwrapper :'+lstwrapper.size());
    }
}
}