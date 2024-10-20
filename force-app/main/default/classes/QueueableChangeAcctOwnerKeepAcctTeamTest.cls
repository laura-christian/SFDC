@isTest
public class QueueableChangeAcctOwnerKeepAcctTeamTest {
    
    @testSetup
    public static void createUsers()  {

        Profile prof = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		
		User rtrUser = new User(
			Alias = 'rtrUser', 
            Email='generic.rtr.user@roomtoread.org', 
            EmailEncodingKey='UTF-8', 
            FirstName = 'Room to', 
            LastName='Read', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = prof.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='generic.rtr.user@roomtoread.org'       
        );

		Blob b = Crypto.GenerateAESKey(128);
		String h = EncodingUtil.ConvertToHex(b);
		String uid = h.SubString(0,8);        
		User runningUser = new User(
            Alias = uid,
            Email = uid + '@roomtoread.org', 
            EmailEncodingKey='UTF-8', 
            FirstName = 'Running', 
            LastName='User', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = prof.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName = uid + '@roomtoread.org'            
        );

        List<User> users = new List<User>{rtrUser, runningUser};
        insert users;
    }

    public static SingleRequestMock generateMock() {  
        SingleRequestMock soapAPIResponse = new SingleRequestMock(200, 'OK',
        '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns="urn:enterprise.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
        '   <soapenv:Body>' +
        '      <loginResponse>' +
        '         <result>' +
        '            <metadataServerUrl>https://roomtoread3.my.salesforce.com/services/Soap/m/55.0/00D7j000000Gyvz</metadataServerUrl>' +
        '            <passwordExpired>false</passwordExpired>' +
        '            <sandbox>true</sandbox>' +
        '            <serverUrl>https://roomtoread3--partialsbx.my.salesforce.com/services/Soap/c/55.0/00D7j000000Gyvz</serverUrl>' +
        '            <sessionId>00D7j000000Gyvz!ARQAQIGd41mZlYmY8Q35Gg0_p5BGFIGALdgBzMfSA6yt48NUnAmRp6wZa9Ig1_nMR3HfVku5WoW0iqd3MhgervcISJZSXIfe</sessionId>' +
        '            <userId>0058b00000EtCtLAAV</userId>' +
        '            <userInfo>' +
        '               <accessibilityMode>false</accessibilityMode>' +
        '               <chatterExternal>false</chatterExternal>' +
        '               <currencySymbol xsi:nil="true"/>' +
        '               <orgAttachmentFileSizeLimit>5242880</orgAttachmentFileSizeLimit>' +
        '               <orgDefaultCurrencyIsoCode xsi:nil="true"/>' +
        '               <orgDefaultCurrencyLocale xsi:nil="true"/>' +
        '               <orgDisallowHtmlAttachments>false</orgDisallowHtmlAttachments>' +
        '               <orgHasPersonAccounts>false</orgHasPersonAccounts>' +
        '               <organizationId>00D7j000000GyvzEAC</organizationId>' +
        '               <organizationMultiCurrency>true</organizationMultiCurrency>' +
        '               <organizationName>Room to Read</organizationName>' +
        '               <profileId>00e8b000002AqpVAAS</profileId>' +
        '               <roleId>00E7j000000VtwfEAC</roleId>' +
        '               <sessionSecondsValid>7200</sessionSecondsValid>' +
        '               <userDefaultCurrencyIsoCode>USD</userDefaultCurrencyIsoCode>' +
        '               <userEmail>laura.christian@roomtoread.org</userEmail>' +
        '               <userFullName>Laura Christian</userFullName>' +
        '               <userId>0058b00000EtCtLAAV</userId>' +
        '               <userLanguage>en_US</userLanguage>' +
        '               <userLocale>en_US</userLocale>' +
        '               <userName>laura.christian@roomtoread3.org.partialsbx</userName>' +
        '               <userTimeZone>America/Los_Angeles</userTimeZone>' +
        '               <userType>Standard</userType>' +
        '               <userUiSkin>Theme3</userUiSkin>' +
        '            </userInfo>' +
        '         </result>' +
        '      </loginResponse>' +
        '   </soapenv:Body>' +
        '</soapenv:Envelope>', null);
 		return soapAPIResponse;       
    }
    
    @isTest
    public static void testAccountTeamMemberTrigger() {
        
        User rtrUser = [SELECT Id FROM User WHERE Name = 'Room to Read' LIMIT 1];
        User runningUser = [SELECT Id FROM User WHERE Name = 'Running User' LIMIT 1];
        
        Account a = new Account(
        Name = 'Test Foundation',
		RecordTypeId = '0128b000000XLonAAG',            
        Type = 'Foundation',
        BillingCountry = 'United Kingdom',
        Count_of_Acct_Team_Members__c = 0);
        insert a;
        
        AccountTeamMember teamMember = new AccountTeamMember(
        	AccountId = a.Id,
            UserId = rtrUser.Id,
            TeamMemberRole = 'Team Member',
            Start_Date__c = System.today()-7,
            End_Date__c = null
        );        
        
        AccountTeamMember rm = new AccountTeamMember(
        	AccountId = a.Id,
            UserId = runningUser.Id,
            TeamMemberRole = 'Relationship Manager',
            Start_Date__c = System.today()-90,
            End_Date__c = null
        );
                
        List<AccountTeamMember> ATMs = new List<AccountTeamMember>{teamMember, rm};
        insert ATMs;

		SingleRequestMock soapAPIResponse = generateMock();
        Test.setMock(HTTPCalloutMock.class, soapAPIResponse);
		a.Count_of_Acct_Team_Members__c = 2;
		update a;        
        rm.End_Date__c = System.today();
        update rm;
    }
    
    @isTest
    public static void testAfterATMDelete() {
        
        User rtrUser = [SELECT Id FROM User WHERE Name = 'Room to Read' LIMIT 1];
        User runningUser = [SELECT Id FROM User WHERE Name = 'Running User' LIMIT 1];
        
		SingleRequestMock soapAPIResponse = generateMock();
        Test.setMock(HTTPCalloutMock.class, soapAPIResponse);         
        
        Account a = new Account(
        Name = 'Test Foundation',
		RecordTypeId = '0128b000000XLonAAG',            
        Type = 'Foundation',
        BillingCountry = 'Hong Kong',
        Count_of_RMs__c = 0,
        Count_of_Acct_Team_Members__c = 0);
        insert a;
        
        AccountTeamMember primaryPlayer = new AccountTeamMember(
        	AccountId = a.Id,
            UserId = runningUser.Id,
            TeamMemberRole = 'Primary Player',
            Start_Date__c = System.today()-90,
            End_Date__c = null
        );
        insert primaryPlayer;
        
        a.Count_of_Acct_Team_Members__c = 1;
        update a;
        
        AccountTeamMember rm = new AccountTeamMember(
        	AccountId = a.Id,
            UserId = rtrUser.Id,
            TeamMemberRole = 'Relationship Manager',
            Start_Date__c = System.today()-7,
            End_Date__c = null
        );
        insert rm;
        
		delete rm;
        
    }
    
    @isTest
    public static void testAccountTriggerRemoveRelationshipManager() {
        
        User rtrUser = [SELECT Id FROM User WHERE Name = 'Room to Read' LIMIT 1];
        User runningUser = [SELECT Id FROM User WHERE Name = 'Running User' LIMIT 1];
        
		SingleRequestMock soapAPIResponse = generateMock();
        Test.setMock(HTTPCalloutMock.class, soapAPIResponse);         
        
        Account a = new Account(
        Name = 'Test Foundation',
		RecordTypeId = '0128b000000XLonAAG',            
        Type = 'Foundation',
        BillingCountry = 'Australia',
        Count_of_RMs__c = 0,
        Count_of_Acct_Team_Members__c = 0);
        insert a;
        
        AccountTeamMember rm = new AccountTeamMember(
        	AccountId = a.Id,
            UserId = runningUser.Id,
            TeamMemberRole = 'Relationship Manager',
            Start_Date__c = System.today()-90,
            End_Date__c = null
        );
        insert rm;
        
        a.Count_of_Acct_Team_Members__c = 1;
        a.Count_of_RMs__c = 1;
		update a;        
       
		rm.End_Date__c = System.today();
        update rm;
       
    }    

    @isTest
    public static void testThrowErrorDirectUpdateToCurrentRM() {
        
		User runningUser = [SELECT Id FROM User WHERE Name = 'Running User' LIMIT 1];

        Account a = new Account(
        Name = 'Managed Household',
		RecordTypeId = '0128b000000XLomAAG',             
        Type = 'Household',
        CurrencyIsoCode = 'GBP');
        insert a;

		a.Current_Relationship_Manager__c = runningUser.Id;
        try {
            update a;
        }
        catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    @isTest
    public static void testThrowErrorDirectUpdateToOwner() {
        
		User runningUser = [SELECT Id FROM User WHERE Name = 'Running User' LIMIT 1];

        Account a = new Account(
        Name = 'Managed Household',
		RecordTypeId = '0128b000000XLomAAG',             
        Type = 'Household',
        CurrencyIsoCode = 'GBP');
        insert a;

		a.OwnerId = runningUser.Id;
        try {
            update a;
        }
        catch (Exception e) {
            System.debug(e.getMessage());
        }
    } 

	@isTest
    public static void testAdminUpdateToOwner() {
        
		User runningUser = [SELECT Id FROM User WHERE Name = 'Running User' LIMIT 1];

		SingleRequestMock soapAPIResponse = generateMock();
        Test.setMock(HTTPCalloutMock.class, soapAPIResponse);        
        
        Account a = new Account(
        Name = 'Managed Household',
		RecordTypeId = '0128b000000XLomAAG',             
        Type = 'Household',
        CurrencyIsoCode = 'GBP',
        Count_of_Acct_Team_Members__c = 1);
        insert a;

		a.OwnerId = runningUser.Id;
		a.Updated_Via_Apex_Trigger__c = true;
		update a;        
        
    }    
    
}