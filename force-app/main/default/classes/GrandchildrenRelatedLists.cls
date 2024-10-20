public class GrandchildrenRelatedLists {

    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getChildAndGrandchildOpps(String parentId) {
        
        return [SELECT Id, Name, AccountId, Account.Name, Amount, CloseDate, StageName, OwnerId, Owner.Alias
                FROM Opportunity 
                WHERE Account.ParentId = :parentId OR AccountId = :parentId];
        
        
    }    

}