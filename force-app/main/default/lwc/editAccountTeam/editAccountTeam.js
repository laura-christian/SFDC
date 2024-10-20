import { LightningElement, api, wire, track } from 'lwc';
import getAccountTeam from '@salesforce/apex/AccountTeamController.getAccountTeam';
import getRolePicklistValues from '@salesforce/apex/AccountTeamController.getRolePicklistValues';
import upsertAccountTeamMembers from '@salesforce/apex/AccountTeamController.upsertAccountTeamMembers';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import{ refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import LightningModal from 'lightning/modal';

export default class EditAccountTeam extends LightningElement {

	@api recordId;
	rolePicklistValues;
	returnedAccountTeam;
	@track accountTeamMembers;
	recordCount;
	userRecordPageUrl;
	newRecords;
	recordsToUpdate;
	@track isLoading = false;

	@wire(getRolePicklistValues, {})
	wiredRolePicklistValues({ error, data }) {
		if (data) {
			this.rolePicklistOptions = data.map(option => {
				return {
						label: option.label,
						value: option.value
				};
			});
		}
		else if (error) {
			console.error(error);
		}
	}

	userFilter = {
    criteria: [
		{
			fieldPath: 'IsActive',
			operator: 'eq',
			value: true
		}
    ]
	};

	userDisplayInfo = {
		primaryField: 'Name',
    additionalFields: ['Title'],
	};


  @wire(getAccountTeam, { acctId: '$recordId' })
	wiredAccountTeam(result) {
		this.returnedAccountTeam = result;
		const { data, error } = result;
		if (data) {
			this.accountTeamMembers = JSON.parse(JSON.stringify(data));
			this.recordCount = data.length;
			if (this.recordCount == 0) {
				this.accountTeamMembers.push({
					'Id': Math.random().toString(),
					'AccountId': this.recordId,
					'UserId': '',
					'TeamMemberRole': '',
					'Start_Date__c': null,
					'End_Date__c': null,
					'isNew': true,
					'isLast': true,
					'isChanged': false,
				});
			}
			else {
				for (let idx=0; idx<this.recordCount; idx++) {
					let atm = this.accountTeamMembers[idx];
					atm.userName = atm.User.Name;
					atm.isNew = false;
					atm.isChanged = false;
					atm.isLast = (idx == this.recordCount - 1);
					this.userFilter.criteria.push({
						fieldPath: 'Id',
						operator: 'ne',
						value: atm.UserId
					});
				}
			}
		} 
		else if (error) {
			console.log(error);
		}					
	}

	async openModal() {
		const result = await this.open({
				size: 'large'
		});
		console.log(result);
	}	

  handleCancel(){
    this.close();
  }

	viewUserRecord(event) {
		let idx = event.target.name;
		let userId = this.accountTeamMembers[idx].UserId;
		let baseURL = window.location.origin;
		if (userId) {
			this[NavigationMixin.GenerateUrl]({
				type: "standard__recordPage",
				attributes: {
					recordId: userId,
					objectApiName: 'User',
					actionName: 'view'
				}
			}).then(url => {
				window.open(url, "_blank");
			});
		}
	}

	addRow() {
		let newTeamMember = {
			'atmId': Math.random().toString(),
			'acctId': this.recordId,
			'userId': '',
			'role': '',
			'startDate': null,
			'endDate': null,
			'isLast': false,
			'isNew': true,
			'isChanged': false
		};
		this.accountTeamMembers.push(newTeamMember);
	}		

	removeRow(event) {
		let idx = event.target.name;
		this.accountTeamMembers.splice(idx, 1);
	}
	
	handleRecordSelect(event) {
		let selectedUserId = event.detail.recordId;
		let idx = event.target.name;
		this.accountTeamMembers[idx].UserId = selectedUserId;
	}

	handleRoleSelect(event) {
		let selectedRole = event.target.value;
		let idx = event.target.name;
		let roleComboboxCmps = this.template.querySelectorAll('.roleCombobox');		
		roleComboboxCmps[idx].setCustomValidity('');
		roleComboboxCmps[idx].reportValidity();		
		this.accountTeamMembers[idx].TeamMemberRole = selectedRole;
		this.accountTeamMembers[idx].isChanged = true;
	}

	handleStartDateChange(event) {
		let selectedStartDate = event.target.value;
		let idx = event.target.name;
		let startDateCmps = this.template.querySelectorAll('.startDateSelector');		
		startDateCmps[idx].setCustomValidity('');
		startDateCmps[idx].reportValidity();		
		this.accountTeamMembers[idx].Start_Date__c = selectedStartDate;
		this.accountTeamMembers[idx].isChanged = true;
	}

	handleEndDateChange(event) {
		let selectedEndDate = event.target.value;
		console.log(selectedEndDate);
		let idx = event.target.name;
		let endDateCmps = this.template.querySelectorAll('.endDateSelector');	
		endDateCmps[idx].setCustomValidity('');
		endDateCmps[idx].reportValidity();			
		this.accountTeamMembers[idx].End_Date__c = selectedEndDate;
		this.accountTeamMembers[idx].isChanged = true;
	}

	async handleAccountTeamChanges(event) {
		this.isLoading = true;
		try {
			await upsertAccountTeamMembers({newATMs: this.newRecords, ATMsToUpdate: this.recordsToUpdate});
			this.isLoading = false;
			this.dispatchEvent(
					new ShowToastEvent({
							title: 'Success',
							message: 'Account team changes saved',
							variant: 'success'
					})
			);
			this.close();
			this.refreshApex(this.returnedAccountTeam);
		} catch (error) {
			this.dispatchEvent(
				new ShowToastEvent({
						title: 'An error occurred while account team changes were being processed:',
						message: reduceErrors(error).join(', '),
						variant: 'error'
				})
			);
		}
	}	

	handleSave() {
		let valid = true;
		for (let idx=0; idx<this.accountTeamMembers.length; idx++) {
			let atm = this.accountTeamMembers[idx];
			if (atm.isNew && atm.UserId=='') {
				this.accountTeamMembers.splice(idx, 1);
			}
			else if (atm.UserId && (!atm.TeamMemberRole || !atm.Start_Date__c)) {
				if (!atm.TeamMemberRole) {
					let roleComboboxCmps = this.template.querySelectorAll('.roleCombobox');
					roleComboboxCmps[idx].setCustomValidity('You must select a role');
					roleComboboxCmps[idx].reportValidity();
					valid = false;
				}
				if (!atm.Start_Date__c) {
					let startDateCmps = this.template.querySelectorAll('.startDateSelector');
					startDateCmps[idx].setCustomValidity('You must enter a start date for the role');
					startDateCmps[idx].reportValidity();
					valid = false;
				}
			}
			if (atm.End_Date__c != null && atm.End_Date__c != '' && atm.End_Date__c < atm.Start_Date__c) {
				let endDateCmps = this.template.querySelectorAll('.endDateSelector');
				endDateCmps[idx].setCustomValidity('End date must be later than start date');
				endDateCmps[idx].reportValidity();
				valid = false;
			}
		}
		if (valid) {
			this.isLoading = true;
			this.newRecords = [];
			this.recordsToUpdate = [];
			this.accountTeamMembers.forEach(atm => {
				let record = {};
				if (atm.isNew) {
					record.AccountId = this.recordId;
					record.UserId = atm.UserId;
					record.TeamMemberRole = atm.TeamMemberRole;
					record.Start_Date__c = atm.Start_Date__c;
					record.End_Date__c = atm.End_Date__c;
					record.AccountAccessLevel = 'Edit';
					record.OpportunityAccessLevel = 'Edit';
					record.CaseAccessLevel = 'Edit';
					this.newRecords.push(record);
				}
				else if (atm.isChanged) {
					record.Id = atm.Id;
					record.AccountId = this.recordId;
					record.UserId = atm.UserId;
					record.TeamMemberRole = atm.TeamMemberRole;
					record.Start_Date__c = atm.Start_Date__c;
					record.End_Date__c = atm.End_Date__c;
					this.recordsToUpdate.push(record);						
				}
			});
			if (this.newRecords || this.recordsToUpdate) {
				this.handleAccountTeamChanges();
			}
			else {
				return;
			}
		}
		else {
			return;
		}
	}
}