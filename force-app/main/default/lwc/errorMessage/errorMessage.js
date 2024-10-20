import { LightningElement,api } from 'lwc';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled }  from 'lightning/empApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class ErrorMessage extends LightningElement {

    subscription = {};
    @api channelName = '/event/Autolaunched_Flow_Error_Handling__c';


    // connected callback : initialise 
    connectedCallback() {       
        // Register error listener     
        this.registerErrorListener();
        this.handlePESubscribe();
    }

    handlePESubscribe() {
        // Callback invoked whenever a new platfrom event message is created.
        const thisReference = this;
        const messageCallback = function(response) {

            var obj = JSON.parse(JSON.stringify(response));
            
            //simplify the flow failure error message
            let error_message = obj.data.payload.Error_Message_Text__c.substring(0, obj.data.payload.Error_Message_Text__c.indexOf("You can look up ExceptionCode values"));
            console.log('Simplified error: '+ error_message);
            //show toast message
            const evt = new ShowToastEvent({
                title: 'Error',
                message: error_message,
                variant: 'error',
                mode:'sticky'
            });
            
            thisReference.dispatchEvent(evt);
            
        };
        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then(response => {
            // Response contains the subscription information on subscribe call
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
        });
    }

    // Error listner method
    registerErrorListener() {
        onError(error => {
             // Error contains the server-side error
            console.log('Error received: ', JSON.stringify(error));
        });
    }
}