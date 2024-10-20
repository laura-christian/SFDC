public class QueueableRunTerritoryAssignmentRules implements Queueable, Database.AllowsCallouts  {

    Set<Id> acctsWCurrencyISOCodeChangesOrNewMembers;
    Set<Id> acctsWCurrencyISOCodeChanges;
    
    public QueueableRunTerritoryAssignmentRules(Set<Id> acctsWCurrencyISOCodeChangesOrNewMembers, Set<Id> acctsWCurrencyISOCodeChanges) {
        this.acctsWCurrencyISOCodeChangesOrNewMembers = acctsWCurrencyISOCodeChangesOrNewMembers;
        this.acctsWCurrencyISOCodeChanges = acctsWCurrencyISOCodeChanges;
    }
       
    public void execute(QueueableContext context) {
        
        String loginSOAPEndpoint = 'https://login.salesforce.com/services/Soap/c/55.0/';
        String username = '******************************';
        String password = '*********************';
        String securityToken = '**********************;
        
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
        loginReq.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        loginReq.setHeader('SOAPAction', 'Login');
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
            DOM.XmlNode sessionIdNode = resultNode.getChildElement('sessionId', 'urn:enterprise.soap.sforce.com');
            String sessionId = sessionIdNode.getText();
            System.debug(sessionId);
            
            String accountTag = '<urn:sObjects xsi:type="urn1:Account" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> ' +
                                	'<urn1:Id>{acctId}</urn1:Id> ' +
                                '</urn:sObjects>' ;    
            String soapBody = 
                '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" ' +
				'xmlns:urn="urn:partner.soap.sforce.com" '+
				'xmlns:urn1="urn:sobject.partner.soap.sforce.com"> '+
                	'<soapenv:Header> ' +
                		'<urn:AssignmentRuleHeader> ' + 
                			'<urn:useDefaultRule>true</urn:useDefaultRule> ' +
                			'<urn:assignmentRuleId></urn:assignmentRuleId> ' +
                		'</urn:AssignmentRuleHeader> ' +
                		'<urn:SessionHeader> ' +
                			'<urn:sessionId>' + sessionId + '</urn:sessionId> ' +
                		'</urn:SessionHeader> ' +
                	'</soapenv:Header> ' +
                	'<soapenv:Body> ' +
                		'<urn:update> ' +
                			'{acctList} ' + 
                		'</urn:update> ' +
                	'</soapenv:Body> ' +
				'</soapenv:Envelope>';             
            
            List<String> accts = new List<String>();
            for (Id acctId : acctsWCurrencyISOCodeChangesOrNewMembers){
                accts.add(accountTag.replace('{acctId}', acctId)); 
            }
            soapBody = soapBody.replace('{acctList}', String.join(accts, ' ')) ;             
        	
            HttpRequest request = new HttpRequest();
			request.setTimeout(60000);            
            request.setMethod('POST');
            request.setEndpoint(System.URL.getSalesforceBaseUrl().toExternalForm()+'/services/Soap/u/41.0/'+UserInfo.getOrganizationId());
            request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
            request.setHeader('SOAPAction', '""'); 
            request.setBody(soapBody);
            Http updateHttp = new Http();
            if (!Test.isRunningTest()) {HttpResponse response = updateHttp.send(request);
				System.debug(response.getStatusCode());                                        
				System.debug(response.getBody());
			}
            
            if (!acctsWCurrencyISOCodeChanges.isEmpty()) {
                Database.executeBatch(new BatchRecalcAcctHardSoftCreditAmts(acctsWCurrencyISOCodeChanges, ''), 5);
            }
        }        
    }

}
