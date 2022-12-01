/**
 * @description       : Test class for ToDoLwcHelper
 * @author            : Adam Dirks
 * @last modified on  : 12-01-2022
 * @last modified by  : Adam Dirks
**/
@isTest
public without sharing class ToDoLwcHelperTest {
    
    
    /**
    * @description Test method for getToDoList method
    * @author Adam Dirks | 12-01-2022 
    **/
    @isTest
    public static void getToDoListTest(){
        //Create a contact to attach To Dos to
        Contact newCon = new Contact(FirstName = 'John', LastName = 'Doe');
        insert newCon;

        //Create To Do test records. Some that should be retreived by getToDoList and some that shouldn't
        Integer numOfToDos = 20;
        List<To_Do__c> toDoList = new List<To_Do__c>();
        for(Integer i = 0; i < numOfToDos; i++){
            toDoList.add(new To_Do__c(Name = 'To Do ' + i, Status__c = 'To Do', Actions__c = 'Action 1', Contact__c = newCon.Id));
            toDoList.add(new To_Do__c(Name = 'To Do ' + i, Status__c = 'Done', Actions__c = 'Action 1', Contact__c = newCon.Id));
        }
        
        //Insert the To Do records
        insert toDoList;

        Test.startTest();
        //Call the getToDoList method and store the results
        List<To_Do__c> results = ToDoLwcHelper.getToDoList();
        Test.stopTest();

        //Verify that the correct number of records were retrieved
        System.assertEquals(numOfToDos, results.size(), 'An incorrect number of records were retrieved from getToDoList()');
    }
}
