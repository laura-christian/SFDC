@isTest
public class QueueableRunTerritoryAssignmentRulesTest {
    

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
        '               <userFullName>Room to Read</userFullName>' +
        '               <userId>0058b00000EtCtLAAV</userId>' +
        '               <userLanguage>en_US</userLanguage>' +
        '               <userLocale>en_US</userLocale>' +
        '               <userName>finance.npsp@roomtoread.org</userName>' +
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
    public static void testChangeOfCurrencyIsoCodeOrGeolocation() {

		SingleRequestMock soapAPIResponse = generateMock();
        Test.setMock(HTTPCalloutMock.class, soapAPIResponse);         
        
        Account a = new Account(
        Name = 'Test Foundation',
        Type = 'Foundation',
        BillingCountry = 'United Kingdom',
        CurrencyIsoCode = 'GBP',
        IsExcludedFromRealign = false);
        insert a;

		a.BillingCountry = 'Hong Kong';
        a.CurrencyIsoCode = 'HKD';
		update a;

        System.enqueueJob(new QueueableRunTerritoryAssignmentRules(new Set<Id>{a.Id}, new Set<Id>{a.Id}));        
    } 
    
}