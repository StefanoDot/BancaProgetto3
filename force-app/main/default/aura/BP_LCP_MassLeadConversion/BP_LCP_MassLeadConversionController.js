({
	doInit :function(component, event, helper){
        component.set("v.showSpinner", true);
        component.set("v.columns", [
            {label: 'Ragione Sociale Lead', fieldName: 'Ragione_Sociale_Lead__c', type: 'text'},
            {label: 'Codice Fiscale', fieldName: 'Codice_Fiscale__c', type: 'text'},
            {label: 'Partita Iva', fieldName: 'Partita_IVA__c', type: 'text'},
            {label: 'Cognome Referente', fieldName: 'Cognome_Referente__c', type: 'text'},
            {label: 'Nome Referente', fieldName: 'Nome_Referente__c', type: 'text'},
            {label: 'Telefono Referente', fieldName: 'Telefono_Referente__c', type: 'phone'},
            {label: 'E-mail Referente', fieldName: 'Email_Referente__c', type: 'email'},
            {label: 'Comune', fieldName: 'Comune__c', type: 'text'},
            {label: 'Provincia', fieldName: 'Provincia__c', type: 'text'},
            {label: 'CAP', fieldName: 'Cap__c', type: 'text'},
            {label: 'Provenienca Lead', fieldName: 'Provenienca_Lead__c', type: 'text'},
        ]);
		helper.fetchLeads(component, event, helper);
	},
   handleSelect :function(component, event, helper){
        var selectedRows = event.getParam('selectedRows');
        var selectedLeads = [];  
        component.set( "v.selectedRows", selectedRows.length);
        var flag = selectedRows.length > 0 ? component.set("v.convertLeadFlag", true) : component.set("v.convertLeadFlag", false);
        
        for(var i = 0; i < selectedRows.length; i++){  
            selectedLeads.push(selectedRows[i]);  
        }
        component.set( "v.selectedLeads", selectedLeads);  
   },
   convertLeads :function(component, event, helper){
       component.set("v.isModalOpen", true);
   },
   closePopup :function(component, event, helper){
       component.set("v.isModalOpen", false);
   },
   submitDetails :function(component, event, helper){
       component.set("v.showSpinner", true);
       component.set("v.isModalOpen", false);
       helper.convertSelectedLeads(component, event, helper);
   },
   onChange: function(component, event, helper){
       var selectedField = component.find('select').get('v.value');
   },
   searchLeads: function(component, event, helper){
       var keyword = component.get("v.searchKeyword");
       var selectedLeads = component.get("v.selectedLeads");
       component.set("v.showSpinner", true);
       component.set("v.data", "[]");
       var selectedField = component.get("v.selectedField");
       if(selectedField != ''){
           helper.getFilteredLeads(component, event, helper);
       }
       else{
           helper.fetchLeads(component, event, helper); 
       }
   }
})