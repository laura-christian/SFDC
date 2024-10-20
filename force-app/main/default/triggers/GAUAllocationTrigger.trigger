trigger GAUAllocationTrigger on npsp__Allocation__c (before insert, before update) {

    if (Trigger.isBefore) {
        // Ensure that allocation percentage is always filled in
        Set<Id> relatedOppIds = new Set<Id>();
        Set<Id> relatedPmtIds = new Set<Id>();
        for (npsp__Allocation__c alloc : Trigger.new) {
            if (!String.isBlank(alloc.npsp__Opportunity__c)) {
                relatedOppIds.add(alloc.npsp__Opportunity__c);
            }
            else if (!String.isBlank(alloc.npsp__Payment__c)) {relatedPmtIds.add(alloc.npsp__Payment__c);}
        }
        Map<Id, Opportunity> allocatedOppMap = new Map<Id, Opportunity>([SELECT Id, Amount FROM Opportunity WHERE Id IN :relatedOppIds]);
        Map<Id, npe01__OppPayment__c > allocatedPmtMap = new Map<Id, npe01__OppPayment__c >([SELECT Id, npe01__Payment_Amount__c FROM npe01__OppPayment__c  WHERE Id IN :relatedPmtIds]);
        for (npsp__Allocation__c alloc : Trigger.new) {
            if (!String.isBlank(alloc.npsp__Opportunity__c) && allocatedOppMap.containsKey(alloc.npsp__Opportunity__c) && alloc.npsp__Amount__c != null && alloc.npsp__Percent__c == null && allocatedOppMap.get(alloc.npsp__Opportunity__c).Amount != 0) {
                alloc.npsp__Percent__c = alloc.npsp__Amount__c/allocatedOppMap.get(alloc.npsp__Opportunity__c).Amount*100;
            }
            else if (!String.isBlank(alloc.npsp__Payment__c) && allocatedPmtMap.containsKey(alloc.npsp__Payment__c) && allocatedPmtMap.get(alloc.npsp__Payment__c).npe01__Payment_Amount__c != null && allocatedPmtMap.get(alloc.npsp__Payment__c).npe01__Payment_Amount__c != 0 && alloc.npsp__Percent__c == null) {alloc.npsp__Percent__c = alloc.npsp__Amount__c/allocatedPmtMap.get(alloc.npsp__Payment__c).npe01__Payment_Amount__c*100;}
        }
    }
    
}