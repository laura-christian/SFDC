public without sharing class AccountTeamController {
        
    
    @AuraEnabled(cacheable=true)
    public static List<AccountTeamMember> getAccountTeam(String acctId) {
        return
            [SELECT Id, AccountId, UserId, User.Name, TeamMemberRole, Start_Date__c, End_Date__c 
             FROM AccountTeamMember
             WHERE AccountId =:acctId ORDER BY Start_Date__c DESC];    
    }
    
	@AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getRolePicklistValues() {
        List<Schema.PicklistEntry> entries = AccountTeamMember.TeamMemberRole.getDescribe().getPicklistValues();
        List<Map<String, String>> values = new List<Map<String, String>>();
        for (Schema.PicklistEntry entry : entries) {
            if (entry.getLabel()!='Opportunity Owner') {
                Map<String, String> valueMap = new Map<String, String>();
                valueMap.put('label', entry.getLabel());
                valueMap.put('value', entry.getValue());
                values.add(valueMap);
            }
        }
        return values;
    }    


    @AuraEnabled
    public static void upsertAccountTeamMembers(List<AccountTeamMember> newATMs, List<AccountTeamMember> ATMsToUpdate) {
        if (!newATMs.isEmpty()) {
        	Database.insert(newATMs);
        }
        if (!ATMsToUpdate.isEmpty()) {
        	Database.update(ATMsToUpdate);
        }
    }   
}