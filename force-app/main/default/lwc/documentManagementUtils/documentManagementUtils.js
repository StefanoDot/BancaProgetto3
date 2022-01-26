import {LightningElement} from "lwc";

/**
 * Created by mocan on 07/09/2021.
 */

export function canProfileEditDocVerifica(profilesToEditVerificaSales, profileName) {
    let listOfProfiles = [];
    let isVerificaDisabled = false;

    if (profilesToEditVerificaSales !== undefined) {
        listOfProfiles = profilesToEditVerificaSales.split(';');
        isVerificaDisabled = !listOfProfiles.includes(profileName);
    }
    return isVerificaDisabled;
}

export function checkIfButtonsAreDisabled(opportunity, oppIsCreditiFiscali, oppIsMutuo, oppIsEasyPlus, creditiStageMap, mutuoStageMap, easyPlusStageMap) {
    let stageName = opportunity.StageName;
    let stageIndex = 0;
    let disableAllButtons = false;

    if (oppIsCreditiFiscali) {
        stageIndex = creditiStageMap[stageName];

        if ((!opportunity.Is_Suspended__c && [7, 8].includes(stageIndex)) ||
            [10, 11, 12, 14, 16].includes(stageIndex)) {
            disableAllButtons = true;
        }
    } else if (oppIsMutuo) {
        stageIndex = mutuoStageMap[stageName];

        if ((!opportunity.Is_Suspended__c && [4, 5].includes(stageIndex)) ||
            [7, 8, 9, 11, 12].includes(stageIndex)) {
            disableAllButtons = true;
        }
    } else if (oppIsEasyPlus) {
        stageIndex = easyPlusStageMap[stageName];

        if ((!opportunity.Is_Suspended__c && [4, 5].includes(stageIndex)) ||
            [7, 9, 10].includes(stageIndex)) {
            disableAllButtons = true;
        }
    }

    return disableAllButtons;
}

export function checkIfEnableMandatoryDocTypesInCessione(opportunity, oppIsCreditiFiscali, creditiStageMap) {
    let stageName = opportunity.StageName;
    let stageIndex = 0;
    let enableMandatoryDocTypes = false;

    if (oppIsCreditiFiscali) {
        stageIndex = creditiStageMap[stageName];

        if (stageIndex === 11) {
            enableMandatoryDocTypes = true;
        }
    }

    return enableMandatoryDocTypes;
}