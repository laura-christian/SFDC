public class ScheduleUpdateFirstAndLastCreditAmts implements Schedulable {

    public void execute(SchedulableContext sc) {
        
        Set<Id> acctIds = new Set<Id>();
        
        Datetime oneDayAgo = System.now().addDays(-1);
        
        List<OpportunityFieldHistory> oppFieldHistories = [SELECT Id, OpportunityId, Opportunity.AccountId, Field, OldValue, NewValue, CreatedDate
                                                           FROM OpportunityFieldHistory
                                                           WHERE CreatedDate >= :oneDayAgo AND Opportunity.ForecastCategory = 'Closed'
                                                           AND Opportunity.Amount > 0 AND Opportunity.RecordType.Name != 'In-kind Gift' AND
                                                           FIELD IN ('CloseDate', 'Amount_in_Acct_Currency__c',
                                                                     'ForecastCategoryName')];
        for (OpportunityFieldHistory ofh : oppFieldHistories) {
            acctIds.add(ofh.Opportunity.AccountId);
        }
        
        List<Opportunity> newOpps = [SELECT Id, AccountId FROM Opportunity
                                     WHERE CreatedDate >= :oneDayAgo AND ForecastCategory = 'Closed'
                                     AND Amount > 0 AND RecordType.Name != 'In-kind Gift'];
        
        for (Opportunity o : newOpps) {
            acctIds.add(o.AccountId);
        }
        
        List<npsp__Account_Soft_Credit__c> acctSoftCredits = [SELECT Id, npsp__Account__c
                                                              FROM npsp__Account_Soft_Credit__c
                                                              WHERE LastModifiedDate >= :oneDayAgo AND 
                                                              Amount_in_Acct_Currency__c > 0];
        
        for (npsp__Account_Soft_Credit__c acctSoftCred : acctSoftCredits) {
            acctIds.add(acctSoftCred.npsp__Account__c);
        }
        
        List<npsp__Partial_Soft_Credit__c> partialSoftCredits = [SELECT Id, npsp__Contact__r.AccountId
                                                                 FROM npsp__Partial_Soft_Credit__c
                                                                 WHERE LastModifiedDate >= :oneDayAgo AND
                                                                 Amount_in_Acct_Currency__c > 0];
        
        for (npsp__Partial_Soft_Credit__c partialSoftCred : partialSoftCredits) {
            acctIds.add(partialSoftCred.npsp__Contact__r.AccountId);
        }
        
        List<Id> acctIdsListified = new List<Id>();
        acctIdsListified.addAll(acctIds);
        
        if (!acctIdsListified.isEmpty()) {Database.executeBatch(new BatchUpdateFirstAndLastGiftAmts(acctIdsListified), 20);}
        
    }
    
    
    
}