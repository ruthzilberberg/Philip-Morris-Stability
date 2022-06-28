public without sharing class ObjectHistoryHandler {

    
    
    List<sObject> newList;
    Map<Id,sObject> oldMap;
    String dmlType;
    String objectName;
    
    public Map<String,ObjectHistoryTrackingFields__mdt> fieldsToTrack;
    public List<String> ObjectHistoryFieldsToPopulate;
    public List<String> SourceObjectFieldsForPopulation;  


    /*
    private static Map<String, Schema.SObjectField> schemaMap;
    public  Map<String, Schema.SObjectField> getObjectFieldMap(){
        if(objectName ==null)
        {
            schemaMap = null;
        }
        else if(schemaMap == null){
            schemaMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        }
        return schemaMap;
    }
    */
    private ObjectHistoryTracking__mdt x_objectHistoryTrackingSettingds;
    public ObjectHistoryTracking__mdt objectHistoryTrackingSettingds
    {
        get{
            if(x_objectHistoryTrackingSettingds == null){
                x_objectHistoryTrackingSettingds = [Select ObjectHistoryFieldsToPopulate__c,SourceObjectFieldsForPopulation__c,
                     (Select FieldToTrack__c,Tracking_Field_is_Lookup__c From ObjectHistoryTrackingFields__r)
                     From ObjectHistoryTracking__mdt where SourceObjectName__c =:objectName ][0];
            }
            return x_objectHistoryTrackingSettingds;
        }
    }


    public ObjectHistoryHandler() {

    }


    public ObjectHistoryHandler( List<sObject> newList,Map<Id,sObject> oldMap,String dmlType,String objectName) {
        this.newList=newList;
        this.oldMap=oldMap;
        this.dmlType=dmlType;
        this.objectName=objectName;
        this.fieldsToTrack = new Map<String,ObjectHistoryTrackingFields__mdt >();
        this.ObjectHistoryFieldsToPopulate = new List<String>();
        this.SourceObjectFieldsForPopulation = new List<String>();
        init();


    }
  

    public void init(){
        for(ObjectHistoryTrackingFields__mdt trkObj : objectHistoryTrackingSettingds.ObjectHistoryTrackingFields__r){
            fieldsToTrack.put(trkObj.FieldToTrack__c,trkObj);
        }
        
        ObjectHistoryFieldsToPopulate = objectHistoryTrackingSettingds.ObjectHistoryFieldsToPopulate__c.split(';');
        System.debug('ObjectHistoryFieldsToPopulate:----->'+ObjectHistoryFieldsToPopulate);
        SourceObjectFieldsForPopulation = objectHistoryTrackingSettingds.SourceObjectFieldsForPopulation__c.split(';');
        System.debug('SourceObjectFieldsForPopulation----->'+SourceObjectFieldsForPopulation);
    }


    public List<ObjectHistory__c> create_related_record(){

    List<ObjectHistory__c> list_history= new List<ObjectHistory__c>();

        //SObject obj; // This takes all available fields from the required object. 
        //Schema.SObjectType objType = obj.getSObjectType(); 
        //Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.obj.fields.getMap(); 

        //Map<String,Schema.SObjectField>mapFields= new Map<String,SObjectField>();
        //mapFields = Schema.getGlobalDescribe().get('Campaign').getDescribe().Fields.getMap();

        // when dmlType='Insert' there is no oldMap
        //if(this.dmlType!='Insert'){


        System.debug('newList:'+newList);

        //Map<String, Schema.SObjectField> objMap = getObjectFieldMap();
        boolean isFieldReferenceType = false;
        for(sObject new_obj : newList)
        {
           // if(new_obj.get(str) != old_obj.get(str)){
                sObject old_obj = this.dmlType=='Insert' ? null : this.oldMap.get(new_obj.Id);
               
                
                for(String trackField : fieldsToTrack.keySet()){
                        
                        

                        // system.debug('fieldsToTrack = ' + fieldsToTrack);
                        // system.debug('this.dmlType = ' + this.dmlType);
                        // system.debug('new_obj.get(trackField) = ' + new_obj.get(trackField));
                        // if(this.dmlType!='Insert'){
                        //     system.debug('old_obj.get(trackField) = ' + old_obj.get(trackField));
                        // }
                        if((this.dmlType=='Insert' && new_obj.get(trackField) != null && new_obj.get(trackField) != '') || (this.dmlType=='Update' && new_obj.get(trackField) != old_obj.get(trackField))){   
                                ObjectHistory__c obj_history = new ObjectHistory__c();
                                obj_history.isTrackingFieldTypeLookup__c = fieldsToTrack.get(trackField).Tracking_Field_is_Lookup__c;
                                obj_history.Object_Name__c=this.objectName;
                                obj_history.Field__c=trackField;
                                if(this.dmlType!='Insert'){
                                  obj_history.Old_Value__c=String.valueOf(old_obj.get(trackField));
                                }
                                obj_history.New_Value__c= String.valueOf(new_obj.get(trackField));
                                obj_history.Type__c=this.dmlType;
                                obj_history.Modify_by__c = UserInfo.getUserId();
                                obj_history.DateTime__c = System.now(); //IN GMT, FORMAT IT TO CURRENT TIME 

                                for(Integer i=0;i<ObjectHistoryFieldsToPopulate.size();i++){
                                    obj_history.put(ObjectHistoryFieldsToPopulate[i],new_obj.get(SourceObjectFieldsForPopulation[i]));
                                }
                                list_history.add(obj_history);
                        }
                  
                }       
         }
         //}
         system.debug('list_history = ' + list_history);
         if(list_history.size()>0){
             insert list_history;
         }   
         return null;
            
            











            /*
            for (String str : mapFields.keyset()) 
            { 
               
                try 
                { 
                    if(new_obj.get(str) != old_obj.get(str))
                    { 
                        obj_history.Name=this.objectName;
                        obj_history.Field__c=str;
                        obj_history.Old_Value__c=String.valueOf(old_obj.get(str));
                        obj_history.New_Value__c= String.valueOf(new_obj.get(str));
                        obj_history.Type__c=this.dmlType;
                        obj

                        System.Debug(this.objectName+' Field changed: ' + str + '. The value has changed from: ' + old_obj.get(str) + ' to: ' + new_obj.get(str)); 
                    } 
                } 
                catch (Exception e) 
                { 
                    System.Debug('Error: ' + e); 
                } 
            }

            ObjectHistory__c empty_obj_history = new ObjectHistory__c();
            if(empty_obj_history==obj_history){
            }else{
                list_history.add(obj_history);
            }*/
            
        //}
    }

// { 
//   Lead LeadObject = new Lead(); 
// // This takes all available fields from the required object. 
// Schema.SObjectType objType = LeadObject.getSObjectType(); 
// Map<String, Schema.SObjectField> M = Schema.SObjectType.Lead.fields.getMap(); 
// for (String str : M.keyset()) 
// { 
//     try { 
//         System.debug('Field name: '+str +'. New value: ' + NewLead.get(str) +'. Old value: '+OldLead.get(str)); 
//         if(NewLead.get(str) != OldLead.get(str))
//         { 
//             system.debug('******The value has changed!!!! '); // here goes more code } } catch (Exception e) { System.debug('Error: ' + e); 
//             } 
//         } 
//     }

    //return list_history;

}