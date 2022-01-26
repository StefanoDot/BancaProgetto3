({   
    
    
    doInit: function (component, event, helper) {
        var QuoteId =  component.get("v.recordId");
        console.log('QuoteId: '+ QuoteId);
        
        var verifica = component.get("v.simpleRecord.Verifica_fondo__c");
        console.log('V ' + verifica);
        
        var simulazione = component.get("v.simpleRecord.Esito_simulazione__c");
        console.log('s ' + simulazione);
        
        var congelamento = component.get("v.simpleRecord.Esito_congelamento__c");
        console.log('c ' + congelamento);
        
        var tipo = component.get("v.simpleRecord.Tipo_di_Garanzia__c");
        console.log('t ' + tipo);
        
        if(simulazione !='In simulazione') {
            if(verifica=='Da Verificare' || verifica=='In Verifica'  || verifica=='Esito Negativo'  ){
                    component.set("v.flagSimulazione",true);
                              
               }
            else { 
                component.set("v.flagSimulazione",false);

            }
        }
        else {
             component.set("v.flagSimulazione",true);

        }
        if(congelamento !='In congelamento') {
            if(verifica=='Da Verificare' || verifica=='In Verifica'  || verifica=='Esito Negativo'  ){
                    component.set("v.flagCongelamento",true);
                              
               }
            else { 
                component.set("v.flagCongelamento",false);

            }
        }
        else {
             component.set("v.flagCongelamento",true);

        }
        
                            component.set("v.fake",true);

      
        
    },
    
    
	update : function(component, event, helper) {
        
        var buttonName = event.getSource().get("v.name");
        console.log('Button Name ' + buttonName);
        
		helper.update_helper(component, event, helper, buttonName);
	}
})