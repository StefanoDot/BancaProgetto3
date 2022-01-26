public with sharing class Utils_Constants {

//Account RecType       
@AuraEnabled
public final String RECORD_TYPE_ANAGRAF = 'Inserimento_Anagrafica'; 
@AuraEnabled    
public final String RECORD_TYPE_BUSINESS = 'IndustriesBusiness';

public final String RECORD_TYPE_NoOpp = 'AccountNoOpp';

    
//Contact RecordType

//Opportunity RecordType
@AuraEnabled
public final String RECORD_TYPE_NEW_OPPORTUNITY = 'New_Opportunity'; 
@AuraEnabled
public final String RECORD_TYPE_LENDING = 'Lending';
@AuraEnabled    
public final String RECORD_TYPE_LENDING_RO = 'Lending_RO'; 
    
public final String RECORD_TYPE_EASY = 'Lending_Easy_Plus'; 
public final String RECORD_TYPE_EASY_RO= 'Lending_Easy_Plus_RO';
@AuraEnabled
public final String RECORD_TYPE_NEW_OPPORTUNITY_CREDITI = 'Inserimento_Crediti_Fiscali'; 
@AuraEnabled
public final String RECORD_TYPE_LENDING_CREDITI = 'Crediti_Fiscale_Lending';  
 @AuraEnabled
public final String RECORD_TYPE_LENDING_Entrambi = 'Entrambi';   
@AuraEnabled    
public final String RECORD_TYPE_LENDING_RO_CREDITI = 'Crediti_Fiscale_Lending_RO'; 
// Opportunity Fields
public final String OPPORTUNITY_TIPO_FISCALE = 'Crediti Fiscali'; 

  //Garanzia RecordType  
public final String RECORD_TYPE_Altre_Garanzie = 'Altre_Garanzie';
public final String RECORD_TYPE_Altre_RO = 'Altre_Garanzie_Read_Only';
public final String RECORD_TYPE_Confidi = 'Confidi';
public final String RECORD_TYPE_Confidi_RO = 'Confidi_Read_Only';
public final String RECORD_TYPE_Fidejussione = 'Fidejussione';
public final String RECORD_TYPE_Fidejussione_RO = 'Fidejussione_Read_Only';
public final String RECORD_TYPE_ISMEA = 'ISMEA';
public final String RECORD_TYPE_ISMEA_RO = 'ISMEA_Read_Only';
public final String RECORD_TYPE_MCC = 'MCC';
public final String RECORD_TYPE_MCC_RO = 'MCC_Read_Only'; 
public final String RECORD_TYPE_SACE = 'SACE';
public final String RECORD_TYPE_SACE_RO = 'SACE_Read_Only';

//Quote RecordType
public final String RECORD_TYPE_LINEA_RO = 'Linee_Di_Credito_RO';
public final String RECORD_TYPE_LINEA = 'Linee_Di_credito';
public final String RECORD_TYPE_CREDITI_FISCALI = 'Crediti_Fiscali';
public final String RECORD_TYPE_CREDITI_FISCALI_RO = 'Crediti_Fiscali_RO';
public final String RECORD_TYPE_CREDITI_FISCALI_LENDING = 'Crediti_Fiscale_Lending';
public final String RECORD_TYPE_CREDITI_FISCALI_LENDING_RO = 'Crediti_Fiscale_Lending_RO';
    

    
//Contact
@AuraEnabled
public final String CONTACT_TITOLARE_EFFETTIVO = 'Titolare Effettivo';  
@AuraEnabled 
public final String CONTACT_LEGALE_RAPPRESENTANTE = 'Legale Rappresentante';  
@AuraEnabled 
public final String GENDER_MALE = 'Male';  
@AuraEnabled 
public final String GENDER_FEMALE = 'Female'; 
@AuraEnabled 
public final String TIT_NO_ACC_M = 'SIGNORE';  
@AuraEnabled 
public final String TIT_NO_ACC_F = 'SIGNORA';   


//Account Type
@AuraEnabled
public final String TYPE_ELEGGIBILE= 'Eleggibile'; 
@AuraEnabled
public final String TYPE_NON_ELEGGIBILE = 'Non Eleggibile';
    
//Account Stati Oplon
@AuraEnabled
public final String OPLON_KO_FULL = 'Ko Full'; 
@AuraEnabled
public final String OPLON_OK_FULL = 'Ok Full'; 
@AuraEnabled
public final String OPLON_OK_LIGHT = 'Ok Light'; 
@AuraEnabled
public final String OPLON_KO_LIGHT = 'Ko Light'; 

    
    
    
    
//Quote
@AuraEnabled
public final String LINEE_DI_CREDITO = 'Linee_Di_credito';
public final String LINEE_DI_CREDITO_ANNULLATA = 'Annullata';
public final String LINEE_DI_CREDITO_Oplon_ESITO_DELIBERA_NEGATIVO='97';
public final String LINEE_DI_CREDITO_Oplon_ESITO_DELIBERATA_POS='10';

    
    
    //Garanzie
@AuraEnabled
public final String GARANZIA_RECORDTYPE = 'Garanzia';
@AuraEnabled    
public final String GARANZIA_STATOGARANZIA_APERTA = 'Aperta';
@AuraEnabled    
public final String GARANZIA_STATOGARANZIA_CHIUSA = 'Chiusa';
@AuraEnabled
public final String GARANZIA_TIPO_MCC = 'Fondo MCC';

    

//Document 
@AuraEnabled
public final String OPPORTUNITY_VERIFICA_OK = 'Verifica OK';
@AuraEnabled
public final String OPPORTUNITY_VERIFICA_KO = 'Da Ricaricare';   
@AuraEnabled
public final String OPPORTUNITY_DA_VERIFICARE = 'Da Verificare';  
    
//Opportunity Stage


@AuraEnabled
public final String OPPORTUNITY_PEF_PRE_ISTRUTTORIA = 'PEF Pre-Istruttoria'; 
@AuraEnabled
public final String OPPORTUNITY_COMPLETAMENTO_DOCUMENTI = 'Completamento Documenti';     
@AuraEnabled
public final String OPPORTUNITY_APPROVAZIONE_PRE_ISTRUTTORIA = 'Approvazione Pre-istruttoria';   
@AuraEnabled
public final String OPPORTUNITY_PEF_ISTRUTTORIA = 'PEF Istruttoria';   
@AuraEnabled
public final String OPPORTUNITY_PRIMA_VISITA ='Prima visita';
@AuraEnabled
public final String OPPORTUNITY_PRIMO_CONTATTO='Primo contatto';
@AuraEnabled
public final String OPPORTUNITY_EROGATA= 'Erogata';
@AuraEnabled
public final String OPPORTUNITY_DELIBERATA ='Deliberata';
@AuraEnabled
public final String OPPORTUNITY_CHIUSA_PERSA = 'Chiusa/Persa';
@AuraEnabled
public final String OPPORTUNITY_CHIUSE_PERSE = 'Chiuse/Perse';
@AuraEnabled
public final String OPPORTUNITY_ANALISI_DI_FATTIBILITA= 'Analisi di Fattibilità';
@AuraEnabled
public final String OPPORTUNITY_IN_STIPULA = 'In Stipula';
@AuraEnabled
public final String OPPORTUNITY_FIRMA= 'Firma';
@AuraEnabled
public final String OPPORTUNITY_FIRMA_E_CESSIONE= '	Firma e Cessione';
@AuraEnabled
public final String OPPORTUNITY_IN_EROGAZIONE= 'In Erogazione';
   @AuraEnabled
public final String OPPORTUNITY_IN_PRE_DUE_DILIGENCE= 'Pre-Due Diligence';

@AuraEnabled
public final String OPPORTUNITY_IN_DUE_DILIGENCE = 'Due Diligence';
@AuraEnabled
public final String OPPORTUNITY_IN_PRE_ANALISI_E_PRICING = 'Pre-Analisi e Pricing';

//Errors
public final String OPPORTUNITY_ERROR_UPLOAD_MANDATORY_DOCS_WHEN_CHANGING_STAGE = 'Per procedere alla fase successiva occorre caricare tutti i documenti obbligatori.';
@AuraEnabled
public final String OPPORTUNITY_ERROR_MANDATORY_DOCS_WHEN_CHANGING_STAGE = 'Per procedere alla fase successiva occorre verificare tutti i documenti caricati.';
@AuraEnabled
public final String OPPORTUNITY_ERROR_UPLOAD_DOCS_WHEN_CHANGING_STAGE = 'Per procedere alla fase successiva occorre caricare tutti i documenti obbligatori.';
@AuraEnabled
public final String ERROR_PREVENT_STAGE_QUOTE = 'Non puoi creare CreditLine in questi Stage';
@AuraEnabled
public final String ERROR_PREVENT_STAGE_GARANZIA = 'Non puoi creare Garanzia in questi Stage';


    //Opportunity Stage
@AuraEnabled
public final String OPPORTUNITY_NOT_SEND_APPROVAL= 'Non Necessaria';

    
    //Cointestazione
@AuraEnabled
public final String COINTESTAZIONE_INSERIMENTO = 'Cointestazione';
    //Users
@AuraEnabled
public final String USER_PORTESANI = 'Lorenzo Portesani';
@AuraEnabled
public final String USER_Pintavalle = 'Chiara Pintavalle';
@AuraEnabled
public final string USER_Commerciale1 = 'Stefano Nolè';
@AuraEnabled
public final string USER_Commerciale2 = 'Giuseppe Busacca';
@AuraEnabled
public final String PARTNER_LEASING = 'Roberto Carluci';
@AuraEnabled
public final String PARTNER_ARITMA = 'Marco Guglielmotto';
@AuraEnabled
public final String PARTNER_AZIONI_LEASE = 'Andrea Cecchin';
@AuraEnabled
public final String PARTNER_CREDIPASS = 'Fabio Graziotto';
@AuraEnabled
public final String PARTNER_DOMINICI = 'Erika Lipani';
@AuraEnabled
public final String PARTNER_SOFFRITTI = 'Donatella Soffritti';
@AuraEnabled
public final String PARTNER_MARCANDELLI = 'Fulvio Marcandelli';
@AuraEnabled
public final String PARTNER_VALORIMPRESA = 'Vanessa Paolini';

     
}