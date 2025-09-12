@isTest
public class ObjectServiceTest {
    
    @isTest
    static void testGetAllObjects(){
        Test.startTest();
        List<String> sObjectNames = ObjectService.getAllObjects();
        Test.stopTest();
        //1. verify that the sobject list should not null
        System.assertNotEquals(null, sObjectNames, 'The sObject list should not be null');
        // the list should contain these standard object 
        Assert.isTrue(sObjectNames.contains('Account'), 'The list should contain Account');
        Assert.isTrue(sObjectNames.contains('Contact'), 'The list should contain Contact');
        Assert.isTrue(sObjectNames.size() > 0,'The list size should be greater than zero');  
    }
    
    @isTest
    static void testGetFieldsOfObject(){
         String objectApiName = 'Contact';
         List<Map<String,String>> fields = ObjectService.getFieldsOfObject(objectApiName);
         Assert.areNotEqual(null,fields, 'The field should not be null');
        Assert.isTrue(fields.size() > 0,'The list size should be greater than zero'); 
        Boolean hasLastName = false;
         for(Map<String,String> field : fields){
             if(field.containsKey('value') && field.get('value') == 'LastName'){
                 Assert.areEqual('LastName', field.get('value'), 'The contact should contain the LastName');
                  hasLastName = true;
                 break ;
             }   
         }
         Assert.isTrue(hasLastName, 'LastName field should be present in Contact');
    }
    
    @isTest
    static void testGetFieldOfObjectNotCorrect(){
        String objectApiName= 'not';
        List<Map<String,String>> fields = ObjectService.getFieldsOfObject(objectApiName);
                    System.assertEquals(0, fields.size(), 'Field list should be empty for an invalid object');
        
    }
    
    @isTest
    static void testGetRecords(){
       Contact con = new Contact(
        LastName = 'Test Contact',
        Phone = '1234',
        Email = 'abc@gmail.com'
       );
       insert con;
        
       String objectApiName = 'Contact';
       List<String> fields = new List<String>{'LastName', 'Phone', 'Email'};
       Integer offsetSize =0;
       Integer limitSize= 4;
        
       List<SObject> record = ObjectService.getRecords( objectApiName, fields , offsetSize, limitSize) ;
        
        Assert.areNotEqual(null,objectApiName , 'The object should not be null');
        Assert.isTrue(fields.size() > 0,'The list size should be greater than zero');
        Contact returnedContact = (Contact)record[0];
        
        Assert.areEqual('Test Contact',returnedContact.LastName , 'Last Name should be match');
        Assert.areEqual('1234', returnedContact.Phone , 'Phone should be match');
        Assert.areEqual('abc@gmail.com',returnedContact.Email , 'Email should be match');     
    }
    
    @isTest
    static void testGetRecordForNullFields(){
        Contact con = new Contact();
        String objectApiName = 'Contact';
        List<String> fields = new List<String>();
        Integer offsetSize =0;
        Integer limitSize= 4;  
        List<SObject> record = ObjectService.getRecords( objectApiName, fields , offsetSize, limitSize) ;
        Assert.areEqual(0,record.size(),'The size of list is empty'); 
    }
     
    @isTest
    static void testUpdateRecords(){
        //insert contact
        Contact testContact = new Contact(LastName='Test');
        insert testContact;
        //update contact  last name
        testContact.LastName = 'Test Contact';
        List<SObject> listOfobject = new List<SObject> {testContact };
         String result = ObjectService.updateRecords(listOfobject);
        Contact updatedContact = [Select LastName from Contact where Id = :testContact.Id];
        Assert.areEqual('Test Contact',updatedContact.LastName ,'Last Name should be updated'); 
        Assert.areEqual('Records updated successfully', result, 'Method should return a success message');
    }
    
    @isTest
    static void testUpdateRecordsCatch(){
          List<Sobject> contacts= new List<sobject>();
        for(Integer i=0; i<10; i++){
            contacts.add(new Contact(LastName='Test Contact '+i));
        }
          String result = ObjectService.updateRecords(contacts);
          Assert.areEqual('Error updating records', result, 'Error message show');

    }

}