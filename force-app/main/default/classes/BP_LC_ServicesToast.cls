public with sharing class BP_LC_ServicesToast{
    @AuraEnabled
    public static String getAllCampaignNames(String opportunityId){
        String campaignNames = ''; 
        String accountId = [SELECT Id, Name, AccountId FROM Opportunity WHERE Id =: opportunityId].AccountId;
        if(String.isNotEmpty(accountId)){
            List<CampaignMember> campaignMemberRecords = [SELECT Id, AccountId, Campaign.Name FROM CampaignMember WHERE AccountId =: accountId];
            for(CampaignMember campaignMemberRecord: campaignMemberRecords){
                if(String.isNotEmpty(campaignMemberRecord.Campaign.Name)){
                    campaignNames += campaignMemberRecord.Campaign.Name + ', ';
                }
            }
        }
        return campaignNames;
    }
    //Validation For Primary Campaign Source field - Starting
    public static Map<String, String> validatePrimaryCampaignSource(String accountRecordId){
        Map<String, String> campaignDetails = new Map<String, String>();
        List<CampaignMember> campaignMemberRecords = [SELECT Id, AccountId, Campaign.Name, Campaign.Id, CampaignMember.Name FROM CampaignMember WHERE AccountId =: accountRecordId];
        for(CampaignMember campaignMemberRecord: campaignMemberRecords){
            campaignDetails.put(campaignMemberRecord.Campaign.Id, campaignMemberRecord.Campaign.Name);
        }
        return campaignDetails;
    }
    //Validation For Primary Campaign Source field - End
}