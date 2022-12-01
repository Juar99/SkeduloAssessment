/**
 * @description       : Apex helper class for the ToDoList LWC
 * @author            : Adam Dirks
 * @last modified on  : 12-01-2022
 * @last modified by  : Adam Dirks
**/
public with sharing class ToDoLwcHelper {
    /**
    * @description Query method to retieve To Do records owned by the current user with a status of To Do
    * @author Adam Dirks | 12-01-2022 
    * @return List<To_Do__c> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<To_Do__c> getToDoList(){
        return [SELECT Id, Name, Contact__c, Contact__r.Name, Actions__c, Status__c 
                FROM To_Do__c 
                WHERE OwnerId = :UserInfo.getUserId() AND Status__c = 'To Do'
                ORDER BY createdDate desc];
    }
}