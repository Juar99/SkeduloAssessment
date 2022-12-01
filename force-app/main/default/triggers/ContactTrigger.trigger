/**
 * @description       : Apex trigger for Contact Object
 * @author            : Adam Dirks
 * @last modified on  : 12-01-2022
 * @last modified by  : Adam Dirks
**/
trigger ContactTrigger on Contact (after update, after insert, after delete) {
    if(Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)){
        //Updates the Account's Total_Contacts__c field if a contact is changed to active (via Active__c checkbox)
        ContactToAccountUpdate.updateAccountTotalContacts(Trigger.new, Trigger.oldMap);
    }

    if(Trigger.isAfter && Trigger.isDelete){
        //Updates the Account's Total_Contacts__c field if an active contact is deleted
        ContactToAccountUpdate.updateAccountTotalContacts(trigger.old, null);
    }
}