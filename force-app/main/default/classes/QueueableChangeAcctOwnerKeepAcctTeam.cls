public class QueueableChangeAcctOwnerKeepAcctTeam implements Queueable, Database.AllowsCallouts {
    
    Set<Id> acctIds;
    
    public QueueableChangeAcctOwnerKeepAcctTeam(Set<Id> acctIds) {
        this.acctIds = acctIds;
    }
    
    public void execute(QueueableContext context) {
        
        List<User> rtrUser = [SELECT Id FROM User WHERE Name = 'Room to Read' LIMIT 1];        

        List<Account> accts = [SELECT Id, Current_Relationship_Manager__c, OwnerId, Owner.Name
                               FROM Account
                               WHERE Id IN :acctIds];     
        
        String loginSOAPEndpoint = 'https://login.salesforce.com/services/Soap/c/55.0/';
        String username = 'npsp.finance@roomtoread.org';
        String password = 'Literacy123!';
        String securityToken = '8TUHloQNy6UIlaJTcA8GufQu';
        
        String loginSOAPBody = 
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:enterprise.soap.sforce.com">' +
            '   <soapenv:Header>' +
            '   </soapenv:Header>' +
            '   <soapenv:Body>' +
            '      <urn:login>' +
            '         <urn:username>' + username +'</urn:username>' +
            '         <urn:password>' + password + securityToken + '</urn:password>' +
            '      </urn:login>' +
            '   </soapenv:Body>' +
            '</soapenv:Envelope>';
           
        
        // Get session Id
        HttpRequest loginReq = new HttpRequest();
        loginReq.setTimeout(60000); 
        loginReq.setMethod('POST');
        loginReq.setEndpoint(loginSOAPEndpoint);
        loginReq.setHeader('Content-Type', 'text/xml;charset=UTF-8'); //Critical to construction of request
        loginReq.setHeader('SOAPAction', 'Login'); //Also critical to construction of request
        loginReq.setBody(loginSOAPBody);
        Http loginHttp = new Http();
        HttpResponse res = loginHttp.send(loginReq);
        System.debug(res.getBody());
        System.debug(res.getStatusCode());
        
        if (res.getStatusCode() == 200) {
            // If login successful, parse XML return to get target URL and session Id
            DOM.Document doc = res.getBodyDocument();
            Dom.XmlNode root = doc.getRootElement();
            DOM.XmlNode bodyNode = root.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
            DOM.XmlNode loginResponseNode = bodyNode.getChildElement('loginResponse', 'urn:enterprise.soap.sforce.com');
            DOM.XmlNode resultNode = loginResponseNode.getChildElement('result', 'urn:enterprise.soap.sforce.com');
            DOM.XmlNode serverURLNode = resultNode.getChildElement('serverUrl', 'urn:enterprise.soap.sforce.com');
            DOM.XmlNode sessionIdNode = resultNode.getChildElement('sessionId', 'urn:enterprise.soap.sforce.com');
            String serverURL = serverURLNode.getText();
            Integer endPos = serverURL.lastIndexOf('/');
            // Trim package version from end of URL
            serverURL = serverURL.substring(0, endPos+1);
            System.debug(serverURL);
            String sessionId = sessionIdNode.getText();
            System.debug(sessionId);
            
            // Make separate SOAP request for each owner Id update; per Salesforce SOAP API documentation:
            // "When changing the owners of multiple accounts, all accounts must have the same old owner 
            // and the same new owner."
            for (Account a : accts) {
                String acctId = a.Id;
                String ownerId = '';                
                if (String.isBlank(a.Current_Relationship_Manager__c) && !rtrUser.isEmpty() && a.Owner.Name != 'Room to Read') {
                    ownerId = rtrUser[0].Id;
                }
                else if (!String.isBlank(a.Current_Relationship_Manager__c) && a.Current_Relationship_Manager__c != a.OwnerId) {
                    ownerId = a.Current_Relationship_Manager__c;                    
                }
                if (!String.isBlank(ownerId)) {
                    String updateSOAPEndpoint = serverURL;
                    String updateSOAPBody =                
                    '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:enterprise.soap.sforce.com" xmlns:urn1="urn:sobject.enterprise.soap.sforce.com">' +
                    '   <soapenv:Header>' +
                    '      <urn:OwnerChangeOptions>' +
                    '         <urn:options>' +
                    '         <urn:type>KeepAccountTeam</urn:type>' +
                    '         <urn:execute>true</urn:execute>' +
                    '         </urn:options>' +
                    '         <urn:options>' +
                    '         <urn:type>TransferOwnedOpenOpportunities</urn:type>' +
                    '         <urn:execute>true</urn:execute>' +
                    '         </urn:options>' +                        
                    '      </urn:OwnerChangeOptions>' +
                    '      <urn:SessionHeader>' +
                    '        <urn:sessionId>' + sessionId + '</urn:sessionId>' +
                    '      </urn:SessionHeader>' +
                    '   </soapenv:Header>' +
                    '   <soapenv:Body>' +
                    '      <urn:update>' +
                    '         <urn:sObjects xsi:type="urn1:Account" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
                    '            <urn1:Id>' + acctId + '</urn1:Id>' +
                    '            <OwnerId>' + ownerId + '</OwnerId>' +
                    '			 <Updated_Via_Apex_Trigger__c>true</Updated_Via_Apex_Trigger__c>' +
                    '         </urn:sObjects>' +
                    '      </urn:update>' +
                    '   </soapenv:Body>' +
                    '</soapenv:Envelope>';                    
                    HttpRequest updateReq = new HttpRequest();
                    updateReq.setTimeout(60000);
                    updateReq.setMethod('POST');
                    updateReq.setEndpoint(updateSOAPEndpoint);
                    updateReq.setHeader('Content-Type', 'text/xml;charset=UTF-8'); //Critical to construction of request
                    updateReq.setHeader('SOAPAction', 'Update'); //Also critical to construction of request
                    updateReq.setBody(updateSOAPBody);
                    Http updateHttp = new Http();
                    if (!Test.isRunningTest()) {HttpResponse response = updateHttp.send(updateReq);
                        System.debug(response.getBody());
                        System.debug(response.getStatusCode());
                    }
                }
            }
        }   
    }
}