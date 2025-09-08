public  class ObjectService {

    @AuraEnabled(cacheable=true)
    public static List<String> getAllObjects(){
        List<String> objectNames = new List<String>();
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

        for (String sObjName : gd.keySet()) {
         objectNames.add(sObjName);
        }
            objectNames.sort();
        return objectNames;
    }
}