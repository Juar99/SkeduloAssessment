/**
 * @description       : Test class for ContactToAccountUpdate
 * @author            : Adam Dirks
 * @last modified on  : 12-01-2022
 * @last modified by  : Adam Dirks
**/
@isTest
public class ContactToAccountUpdateTest {

    /**
    * @description Data setup for the tests
    * @author Adam Dirks | 12-01-2022 
    **/
    @TestSetup
    private static void makeData(){
        //Insert a test account
        Account testAcct = new Account(Name = 'Test Account');
        insert testAcct;

        //Create 200 inactive contact records on the test account
        List<Contact> contactsList = new List<Contact>();
        for(Integer i = 0; i < 200; i++){
            contactsList.add(new Contact(FirstName = 'John', LastName = 'Doe ' + i, AccountId = testAcct.Id, Active__c = false));
        }

        //Insert the contacts
        insert contactsList;
    }

    /**
    * @description Verify that Total_Contacts__c is updated correctly when contacts are switched to active
    * @author Adam Dirks | 12-01-2022 
    **/
    @isTest
    private static void updateAccountTotalContactsShouldIncrementOnInsert(){
        //Get the test account created in test setup
        Account testAcct = [Select Id, Name FROM Account WHERE Name = 'Test Account' LIMIT 1];

        //Query for 100 contacts to switch to active
        List<Contact> contactsToUpdate = [Select Id, Name, Active__c FROM Contact WHERE AccountId = :testAcct.Id LIMIT 100];

        //Loop over the queried contacts and change them to active
        for(Contact con : contactsToUpdate){
            con.Active__c = true;
        }

        Test.startTest();
        //Update the contacts to active
        update contactsToUpdate;
        Test.stopTest();

        //Re-query the test account to get the updated Total_Contacts__c value
        testAcct = [Select Id, Name, Total_Contacts__c FROM Account WHERE Id = :testAcct.Id];

        //Verify that the number of contacts we activated matches the number in Total_Contacts__c
        System.assertEquals(contactsToUpdate.size(), testAcct.Total_Contacts__c, 'Total_Contacts__c was not updated correctly when switching contacts to active');
    }

    /**
    * @description Verify that Total_Contacts__c is updated correctly when active contacts are deleted
    * @author Adam Dirks | 12-01-2022 
    **/
    @isTest
    private static void updateAccountTotalContactsShouldDecrementOnDelete(){
        //Get the test account created in test setup
        Account testAcct = [Select Id, Name FROM Account WHERE Name = 'Test Account' LIMIT 1];

        //Query for 100 contacts to switch to active
        List<Contact> contactsToUpdate = [Select Id, Name, Active__c FROM Contact WHERE AccountId = :testAcct.Id LIMIT 100];
        
        //Loop over the queried contacts and change them to active
        for(Contact con : contactsToUpdate){
            con.Active__c = true;
        }

        //Update the contacts to active
        update contactsToUpdate;

        //Query for 50 active contacts to delete
        List<Contact> contactsToDelete = [Select Id, Name, Active__c FROM Contact WHERE AccountId = :testAcct.Id AND Active__c = true LIMIT 50];

        Test.startTest();
        //Delete the active contacts
        delete contactsToDelete;
        Test.stopTest();

        //Re-query the test account to get the updated Total_Contacts__c value
        testAcct = [Select Id, Name, Total_Contacts__c FROM Account WHERE Id = :testAcct.Id];

        //Verify that the number of contacts we activated minus the ones we deleted matches the number in Total_Contacts__c
        System.assertEquals(contactsToUpdate.size() - contactsToDelete.size(), testAcct.Total_Contacts__c, 'Total_Contacts__c was not updated correctly when deleting active contacts');
    }
}