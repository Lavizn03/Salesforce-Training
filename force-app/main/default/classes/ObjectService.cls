public with sharing class ObjectService {

    @AuraEnabled(cacheable=true)
    public static List<String> getAllObjects(){
        List<String> objectNames = new List<String>();
        for (Schema.SObjectType sObjName :  Schema.getGlobalDescribe().values()) {
         objectNames.add(sObjName.getDescribe().getName());
        }
            objectNames.sort();
        return objectNames;
    }


    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getFieldsOfObject(String objectApiName){
        System.debug('Object API Name:'+objectApiName);
        List<Map<String,String>> fieldList = new List<Map<String,String>>();
       try{
             Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectApiName);
            Schema.DescribeSObjectResult describeResult= objType.getDescribe();
            Map<String, Schema.SObjectField> fieldMap = describeResult.fields.getMap();

           for(String fieldName : fieldMap.keySet()){
                 Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
                  Map<String,String> fieldInfo = new Map<String,String>();
                  if(fieldDescribe.isAccessible()){
                     Boolean editable = fieldDescribe.isUpdateable();
                    String permission = editable ? 'true' : 'false';

                     fieldInfo.put('label',fieldDescribe.getLabel());
                    fieldInfo.put('value',fieldDescribe.getName());
                    fieldInfo.put('updateable',permission);
                     fieldList.add(fieldInfo);
           }
                  }
                 
           System.debug('Field List:'+fieldList);
       }catch(Exception e){
             System.debug('Error getting object fields:'+e.getMessage());
           }
        return fieldList;
       }

       @AuraEnabled
    public static List<SObject> getRecords(String objectApiName, List<String> selectedFields , Integer offsetSize, Integer limitSize) {
         if (selectedFields == null || selectedFields.isEmpty()) {
        selectedFields = new List<String>{'Id'};
    }
         if (!selectedFields.contains('Id')) {
        selectedFields.add('Id');
         }
    
            String fieldsForQuery = String.join(selectedFields, ',');

            String query = 'SELECT ' + fieldsForQuery + ' FROM ' + objectApiName + ' LIMIT ' + limitSize + ' OFFSET ' + offsetSize ;
             System.debug('Final Query: ' + query);
           return  Database.query(query);

    }
@AuraEnabled
public static String updateRecords(List<SObject> updatedRecords) {
    try {
        update updatedRecords;
        System.debug(' Updated records: ' + updatedRecords);
        return 'Records updated successfully';
    } catch (Exception e) {
      
        return 'Error updating records: ' + e.getMessage();
    }
}

}