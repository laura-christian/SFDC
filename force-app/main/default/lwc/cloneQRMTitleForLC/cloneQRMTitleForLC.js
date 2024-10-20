import { LightningElement, api, wire, track } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import PROJECT_OBJECT from "@salesforce/schema/Projects__c";
import NAME_FIELD from "@salesforce/schema/Projects__c.Name";
import TITLE_LOCAL_LANGUAGE_FIELD from "@salesforce/schema/Projects__c.Title_in_local_language__c";
import COUNTRY_FIELD from "@salesforce/schema/Projects__c.Country__c";
import PROJECT_ID_FIELD from "@salesforce/schema/Projects__c.Project_ID__c";
import DATE_ESTABLISHED_FIELD from "@salesforce/schema/Projects__c.Date_established__c";
import PROJECT_YEAR_FIELD from "@salesforce/schema/Projects__c.Project_Year__c";
import VARIANT_FIELD from "@salesforce/schema/Projects__c.Variant__c";
import LANGUAGE_FIELD from "@salesforce/schema/Projects__c.Language_name__c";
import SUMMARY_FIELD from "@salesforce/schema/Projects__c.Summary__c";
import SUMMARY_LOCAL_LANGUAGE_FIELD from "@salesforce/schema/Projects__c.Summary_Local_Language__c";
import ISBN_FIELD from "@salesforce/schema/Projects__c.ISBN__c";
import READING_LEVEL_FIELD from "@salesforce/schema/Projects__c.Reading_level__c";
import AGE_RANGE_FIELD from "@salesforce/schema/Projects__c.Age_Range__c";
import GENRE_FIELD from "@salesforce/schema/Projects__c.Genre__c";
import CURRICULUM_THEME_FIELD from "@salesforce/schema/Projects__c.Curriculum_Theme__c";
import ADAPTATION_TYPE_FIELD from "@salesforce/schema/Projects__c.Adaptation__c";
import ORIGINAL_TITLE_FIELD from "@salesforce/schema/Projects__c.Internal_Adaptation_Title__c";

export default class CloneQRMTitleForLC extends LightningElement {

    @api recordId;

    projectObject = PROJECT_OBJECT;

    @wire(getRecord, { recordId: "$recordId", fields: [NAME_FIELD, TITLE_LOCAL_LANGUAGE_FIELD, 
        COUNTRY_FIELD, PROJECT_ID_FIELD, DATE_ESTABLISHED_FIELD, PROJECT_YEAR_FIELD, VARIANT_FIELD, LANGUAGE_FIELD,
        SUMMARY_FIELD, SUMMARY_LOCAL_LANGUAGE_FIELD, ISBN_FIELD, AGE_RANGE_FIELD, READING_LEVEL_FIELD, GENRE_FIELD,
        CURRICULUM_THEME_FIELD, ADAPTATION_TYPE_FIELD, ORIGINAL_TITLE_FIELD
    ] })
    record;

    get nameValue() {
      return this.record.data ? getFieldValue(this.record.data, NAME_FIELD) : "";
    }  

    get titleLocalLanguageValue() {
      return this.record.data ? getFieldValue(this.record.data, TITLE_LOCAL_LANGUAGE_FIELD) : "";
    }

    get countryValue() {
      return this.record.data ? getFieldValue(this.record.data, COUNTRY_FIELD) : "";
    } 
    
    get projectIdValue() {
      return this.record.data ? getFieldValue(this.record.data, PROJECT_ID_FIELD) + '.LC' : "";
    }
    
    get dateEstablishedValue() {
      return this.record.data ? getFieldValue(this.record.data, DATE_ESTABLISHED_FIELD) : "";
    }
    
    get projectYearValue() {
      return this.record.data ? getFieldValue(this.record.data, PROJECT_YEAR_FIELD) : "";
    }
    
    get variantValue() {
      return this.record.data ? getFieldValue(this.record.data, VARIANT_FIELD) : "";
    }
    
    get languageValue() {
      return this.record.data ? getFieldValue(this.record.data, LANGUAGE_FIELD) : "";
    }
    
    get summaryValue() {
        return this.record.data ? getFieldValue(this.record.data, SUMMARY_FIELD) : "";
    }    

    get summaryLocalLanguageValue() {
      return this.record.data ? getFieldValue(this.record.data, SUMMARY_LOCAL_LANGUAGE_FIELD) : "";
    }

    get isbnValue() {
      return this.record.data ? getFieldValue(this.record.data, ISBN_FIELD) : "";
    }
    
    get readingLevelValue() {
      return this.record.data ? getFieldValue(this.record.data, READING_LEVEL_FIELD) : "";
    }
    
    get ageRangeValue() {
        return this.record.data ? getFieldValue(this.record.data, AGE_RANGE_FIELD) : "";
      }       

    get genreValue(){
      return this.record.data ? getFieldValue(this.record.data, GENRE_FIELD) : "";
    }

    get curriculumThemeValue(){
      return this.record.data ? getFieldValue(this.record.data, CURRICULUM_THEME_FIELD) : "";
    }
    
    get adaptationTypeValue(){
      return this.record.data ? getFieldValue(this.record.data, ADAPTATION_TYPE_FIELD) : "";
    }

    get originalTitleValue(){
      return this.record.data ? getFieldValue(this.record.data, ORIGINAL_TITLE_FIELD) : "";
    }

    handleCancel(){
      this.dispatchEvent(new CloseActionScreenEvent());
    }

    @track isLoading = false;
    showSpinner() {
        this.isLoading = true;
    }
    hideSpinner() {
        this.isLoading = false;
    }    

    handleSubmit(event) {
      event.preventDefault();
      this.showSpinner();
      const fields = event.detail.fields;
      fields.RecordTypeId = '01250000000DNIIAA4';
      fields.Title_in_local_language__c = this.titleLocalLanguageValue;
      fields.Date_established__c = this.dateEstablishedValue;
      fields.Project_Year__c = this.projectYearValue;
      fields.Variant__c = this.variantValue;
      fields.Format__c = 'Literacy Cloud';
      fields.Status__c = 'Published';
      fields.Reading_level__c = this.readingLevelValue;
      fields.Age_Range__c = this.ageRangeValuel
      fields.Genre__c = this.genreValue;
      fields.Curriculum_Theme__c = this.curriculumThemeValue;
      fields.Summary__c = this.summaryValue;
      fields.Summary_Local_Language__c = this.summaryLocalLanguageValue;
      fields.ISBN__c = this.isbnValue;
      fields.Adaptation__c = this.adaptationTypeValue;
      fields.Internal_Adaptation_Title__c = this.originalTitleValue;
      this.template
        .querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSuccess(event) {
      this.hideSpinner();
      this.dispatchEvent(new CloseActionScreenEvent());
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Success",
          message: "Literacy Cloud project record successfully created",
          variant: "success",
        }),
      );
      var baseURL = window.location.origin;
      window.open(baseURL + '/lightning/r/Projects__c/' + event.detail.id + '/view', '_self');            
    }
   
    handleError(event) {
      this.hideSpinner();
    }

}