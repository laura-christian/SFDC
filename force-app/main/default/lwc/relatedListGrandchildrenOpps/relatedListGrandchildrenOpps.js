import { LightningElement, api, wire, track} from 'lwc';
import getChildAndGrandchildOpps from '@salesforce/apex/GrandchildrenRelatedLists.getChildAndGrandchildOpps';

export default class RelatedListGrandchildrenOpps extends LightningElement {

    @api recordId;
    @track columns = [
        {
            label: 'Opportunity Name',
            fieldName: 'HyperlinkedOpp',
            type: 'url',
            typeAttributes: {label: { fieldName: 'Name' }, 
            target: '_blank'},
            sortable: true
        },
        {
            label: 'Account Name',
            fieldName: 'HyperlinkedAcct',
            type: 'url',
            typeAttributes: {label: { fieldName: 'AccountName' }, 
            target: '_blank'},
            sortable: true
        },
        {
            label: 'Amount',
            fieldName: 'Amount',
            type: 'currency',
            typeAttributes:{
                currencyDisplayAs: "code"
            },
            sortable: true
        },
        {
            label: 'Close Date',
            fieldName: 'CloseDate',
            typeAttributes: {
                day: "numeric",
                month: "numeric",
                year: "numeric"
            },            
            type: 'date',
            cellAttributes: {alignment: 'right'},            
            sortable: true
        },                        
        {
            label: 'Stage',
            fieldName: 'StageName',
            type: 'text',
            sortable: true
        },
        {
            label: 'Owner',
            fieldName: 'Owner',
            type: 'url',
            typeAttributes: {label: { fieldName: 'OwnerAlias' }, 
            target: '_blank'},
            sortable: true
        }      

    ];

    @track error;
    @track data = [];
    recordCount;


    @wire(getChildAndGrandchildOpps, {parentId: '$recordId'})
    wiredOpps({ data, error }) {
        if (data) {
            console.log(data);
            this.data = data.map((record) => ({
                Id: record.Id,
                HyperlinkedOpp: '/' + record.Id,
                HyperlinkedAcct: '/' + record.AccountId,
                Amount: record.Amount,
                CloseDate: record.CloseDate,
                StageName: record.StageName,
                Owner: '/' + record.OwnerId,
                Name: record.Name,
                AccountName: record.Account.Name,
                OwnerAlias: record.Owner.Alias
            }));
            this.recordCount = data.length;
            console.log('recordCount: ' + this.recordCount);
            this.error = null;
        }
        if (error) {
            this.error = error;
        }
    }    


}