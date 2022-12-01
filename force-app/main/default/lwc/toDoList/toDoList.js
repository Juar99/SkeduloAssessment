import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getToDoList from '@salesforce/apex/ToDoLwcHelper.getToDoList'

import NAME_FIELD from '@salesforce/schema/To_Do__c.Name';
import CONTACT_FIELD from '@salesforce/schema/To_Do__c.Contact__c';
import ACTIONS_FIELD from '@salesforce/schema/To_Do__c.Actions__c';
import STATUS_FIELD from '@salesforce/schema/To_Do__c.Status__c';

//Actions available for each row in the data table
const actions = [
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' }
];

//Columns for the data table
const COLUMNS = [
        { 
            label: 'Name',
            fieldName: 'nameUrl',
            type: 'url',
            typeAttributes: {label: { fieldName: 'Name' }, 
            target: '_blank'},
            sortable: true 
        },
        { 
            label: 'Contact',
            fieldName: 'contactUrl',
            type: 'url',
            typeAttributes: {label: { fieldName: 'contactName' }, 
            target: '_blank'},
            sortable: true 
        },
        { label: 'Actions', fieldName: 'Actions__c' },
        { label: 'Status', fieldName: 'Status__c'},
        {
            type: 'action',
            typeAttributes: {
                rowActions: actions,
                menuAlignment: 'auto'
            }
        }
    ];

export default class ToDoList extends NavigationMixin(LightningElement) {
    toDoColumns = COLUMNS;
    fields = [NAME_FIELD, CONTACT_FIELD, ACTIONS_FIELD, STATUS_FIELD];

    @track toDoList = [];
    rawData;
    error;
    showModal = false;

    //Wire the records when the user enters the page and process them to add links for name and contact columns
    @wire(getToDoList)
    wiredToDos(result) {
        this.rawData = result;
        if(result.data) {
            let nameUrl;
            let contactUrl;
            let contactName;
            this.toDoList = result.data.map(row => { 
                nameUrl = "/" + row.Id;
                contactUrl = "/" + row.Contact__r.Id;
                contactName = row.Contact__r.Name;
                return {...row , nameUrl, contactUrl, contactName} 
            })
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.toDoList = undefined;
            console.error(this.error);
        }
    }

    //Method triggered when the refresh button is clicked to refresh the page data
    handleRefresh(event){
        refreshApex(this.rawData);
    }

    //Handles edit or delete actions for a particular row in the data table
    handleRowAction(event){
        let actionName = event.detail.action.name;
        let row = event.detail.row;
        switch ( actionName ) {
            //Navigate the user to the standard edit page if edit was clicked
            case 'edit':
                this[NavigationMixin.Navigate]({
                    type:'standard__recordPage',
                    attributes:{
                        recordId: row.Id,
                        objectApiName:'To_Do__c',
                        actionName: 'edit'
                    }
                });

                break;
            
            //If delete was clicked then delete the record and refresh the data
            case 'delete':
                deleteRecord(row.Id)
                .then(() => {
                    refreshApex(this.rawData);

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Record deleted',
                            variant: 'success'
                        })
                    );
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error deleting record',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                    this.error = error;
                    console.error(this.error);
                });
        }
    }

    //When a new record is successfully created show a toast event and refresh the table data
    handleSuccess(event) {
        const evt = new ShowToastEvent({
            title: 'To Do Created',
            variant: 'success',
        });
        this.dispatchEvent(evt);
        this.closeModal();
        refreshApex(this.rawData);
    }

    //Toggles the modal boolean to true
    openModal(){
        this.showModal = true;
    }

    //Toggles the modal boolean to false
    closeModal(){
        this.showModal = false;
    }
}