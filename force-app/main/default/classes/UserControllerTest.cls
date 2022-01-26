@isTest
public with sharing class UserControllerTest {

        @isTest static void testUpdate(){
     User u1 = ObjectFactory.createNewUser('aldora@gmail.com', 'test@aldora.com');
    	
           
        User gToUpdate = 
        [SELECT Id, IsActive, ManagerId, Name, AboutMe FROM User 
         WHERE Id = :u1.Id
         LIMIT 1];

            gToUpdate.AboutMe='aldora';
        update gToUpdate;
            Test.startTest();
            UserController.AfterUpdate(new Set<Id>{u1.Id});
            test.stopTest();
            
    }
}