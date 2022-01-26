({
    optionalShowToast: function(component, event, helper){
        var fieldForecast = component.get("v.record.Forecast_Category_Custom__c");
        var stageName = component.get("v.record.StageName");
        var tipoLineaCrediti = component.get("v.record.Tipo_di_opportunit__c");
        var profile = component.get("v.record.Owner.Profile.Name");
        console.log('fieldForecast' + fieldForecast );
        console.log('stageName' + stageName );
        console.log('tipoLineaCrediti ' + tipoLineaCrediti );
        console.log('profile' + profile );
        if(tipoLineaCrediti == 'Crediti Fiscali' && fieldForecast == null){         
        component.find('notifLib').showToast({
            title: "Alert",
            message: "Il campo Forecast Category Custom è vuoto!",
            variant: "warning",
            mode: 'sticky'
        });
    }
    }
})