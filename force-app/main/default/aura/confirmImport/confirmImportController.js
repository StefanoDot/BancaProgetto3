({
    //get duplicate import membri List from apex controller
    handleRecordUpdate : function(component, event, helper) {
        
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") 
        {
            	var campRecId = component.get("v.recordId");
                var action = component.get("c.getImpCampDuplicates");
                action.setParams({
                    campaignRecId:campRecId
                });
                action.setCallback(this, function(result){
                    var state = result.getState();
                    if (component.isValid() && state === "SUCCESS"){
                        var returnList = result.getReturnValue();
                        console.log('the length is returnList.length >'+returnList.length);
                        if(parseInt(returnList.length) > 0)
                        {
                            component.set("v.dupImpMemList",returnList);   
                        }
                        else
                        {
                            component.set("v.isNoDuplicate",true);
                        }
                        
                    }
                });
                $A.enqueueAction(action);
            }
        
    },
    
    //Select all contacts
    selectAllCheckbox: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        console.log('selectedHeaderCheck	'+selectedHeaderCheck);
        var updatedAllRecords = [];
        var listOfAllCampaignMem = component.get("v.dupImpMemList");
        
        for (var i = 0; i < listOfAllCampaignMem.length; i++) {
            // check if header checkbox is 'true' then update all checkbox with true 
            // else update all records with false  
            if (selectedHeaderCheck == true) {
                listOfAllCampaignMem[i].isChecked = true;
            } else {
                listOfAllCampaignMem[i].isChecked = false;
            }
            updatedAllRecords.push(listOfAllCampaignMem[i]);
        }
        component.set("v.dupImpMemList", updatedAllRecords);  
    },
    
    //Process the selected campaigns
    addToCampaign: function(component, event, helper) {
        
        component.set("v.showSpinner",true);
        var campRecId = component.get("v.recordId");
        var allRecords = component.get("v.dupImpMemList");
        console.log('listOfAllCampaignMem.length---->'+allRecords.length);
        var selectedRecords = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                selectedRecords.push(allRecords[i].impMemObj);
            }
        }
        var isNoDup = component.get("v.isNoDuplicate");
        var action = component.get("c.addCampignMembers");
        action.setParams({
            campaignRecId:campRecId,
            importMembrList:selectedRecords,
            isNoDuplicate:isNoDup
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                component.set("v.showSpinner",false);
                if(result.getReturnValue())
                {
                    let resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "title": "Success",
                        "type" : "success",
                        "message": "Import Membri Job Initiated Successfully"
                    });
                    resultsToast.fire();
                }
                else
                {
                    let resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "title": "Error",
                        "type" : "error",
                        "message": "Something went wrong. Please contact system administrator"
                    });
                    resultsToast.fire();
                }
            }
        });
        $A.enqueueAction(action);
        
        var a = component.get('c.closeModel');
        $A.enqueueAction(a);
        
        window.location.reload();
    },
    
    openModel : function(component, event, helper) {
        
        var campaign = component.get("v.campaign");
        if(campaign.No_of_Import_Membri__c == 0 )
        {
            let resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "Error",
                "type" : "error",
                "message": "No Import Membri records to import !"
            });
            resultsToast.fire();
        }
        else{
            component.set("v.isOpen", true);
        }
        
    },
    openImportWiz : function(component, event, helper) {
        window.open($A.get("$Label.c.Import_Wizard_Link"));
    },
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "False"  
        
        if(component.get("v.isNoDuplicate"))
        {
            component.set("v.isOpen", false);
        }
        else{
            component.find("selectAllId").set("v.value", false);
            var allRecords = component.get("v.dupImpMemList");
            for (var i = 0; i < allRecords.length; i++) {
                if (allRecords[i].isChecked) {
                    allRecords[i].isChecked = false;
                }
            }
            component.set("v.dupImpMemList", allRecords);
            component.set("v.isOpen", false);
        }
        
        
    },
})