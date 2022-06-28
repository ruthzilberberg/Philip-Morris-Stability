/****************************************************************************************
Name              : FieldMappingHandler  
Description       :
Revision History  :
Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
----------------------------------------------------------------------------------------
1. Hanit                                             Kiril              [SW-32135]
----------------------------------------------------------------------------------------*/
public class FieldMappingHandler  
{
    public class SettingWrapper{
   
      public String settingType;
      public String settingApiName;
      public String recordName;
      public List<sObject>  sobjSettings;
      private List<String> objFields;
      private Map<String,sObject> objSettingsMap;
      private List<String> recordsName;
     
      public SettingWrapper(String settingApiName,String recName,String settingType){
            this.objFields = new List<String>();
            this.recordsName = new List<String>();
            objSettingsMap = new Map<String,sObject>();
            this.recordName = recName;
            this.settingApiName = settingApiName;
            this.settingType = settingType;
      }

      public boolean isCustomSetting(){
         return settingType.toLowerCase() == 'customsetting';
      }
      public boolean isCustomMetaData(){
         return settingType.toLowerCase() == 'custommetadata';
      }
      public void addSetting(String fld,String recName){
        
            addField(fld);
            addRecordName(recName);

      }
      private void addField(String fld){
        objFields.add(fld);
      }
      private void addRecordName(String recName){
        recordsName.add(recName);
      }

      public Map<String,sObject> getObj(){
            return isObjExist();  
      }
      private Map<String,sObject> isObjExist()
      {
            if(sobjSettings == null)
            {
                  String fldName = isCustomMetaData() ? 'MasterLabel' : 'Name';
                  if(!objFields.contains(fldName))
                  {     
                     objFields.add(fldName);
                  } 
                  String query = 'Select ' + String.join(objFields,',') + ' From ' + settingApiName;
                  if(!recordsName.isEmpty())
                        query += ' where ' +  fldName + ' IN : recordsName'; 
                  sobjSettings = Database.query(query);
                  for(sObject obj : sobjSettings)
                  {
                    objSettingsMap.put((String)obj.get(fldName),obj);
                  }
            }
            return objSettingsMap;
      }
       
   }

    public static Object getRelationShipField(String apiPath, Map<String,Object> fieldmap){
  
        List<String> apiPathFields = apiPath.split('\\.');
        Integer lstsize = apiPathFields.size();
        Object val;
        Integer i=0;
        Map<String,Object> fmapp = fieldmap.clone();
        for(;fmapp.containsKey(apiPathFields[i]) && fmapp.get(apiPathFields[i]) instanceof sObject && i<lstsize-1;i++){
             fmapp = ((sObject)fmapp.get(apiPathFields[i])).getPopulatedFieldsAsMap();
        }
        val = fmapp.get(apiPathFields[i]);
        return val;
  }

   public static Map<String,SettingWrapper> getSettingsMap(List<FieldMapping__mdt> fldMappingLst,Integer startIndx){
    
        Map<String,SettingWrapper> settingWrapperMap = new Map<String,SettingWrapper>();

        for(Integer i=startIndx; i<fldMappingLst.size(); i++){
            FieldMapping__mdt fm = fldMappingLst[i];
            SettingWrapper setWarp;
            if(!settingWrapperMap.containsKey(fm.SettingDeveloperName__c)){
                settingWrapperMap.put(fm.SettingDeveloperName__c,new SettingWrapper(fm.SettingDeveloperName__c,fm.SettingRecordName__c,fm.SettingType__c));
            }
            
            setWarp = settingWrapperMap.get(fm.SettingDeveloperName__c);
            setWarp.addSetting(fm.SettingFieldName__c,fm.SettingRecordName__c);
        }
        return settingWrapperMap;
   }
  
  
 
  public static List<ObjectMapping__mdt> getObjMappingRecords(String objMappingRecord, String requestTypeBoolCondition)
  {
     
     String query = 'SELECT SourceObject__c,( SELECT AdditionalValue1__c,DefaultValue__c,FieldApiName__c,isFromSetting__c,MappingName__c,ParentApiNameFieldPath__c,'+
                  + 'SettingDeveloperName__c,SettingFieldName__c,SettingRecordName__c,SettingType__c,AdditionalRelationship__c From FieldsMapping__r where Active__c = true And isUpdateOnFailure__c = false And' +
                  +' isUpdateOnSuccess__c = false And isUpdateOnPending__c = false And ' + requestTypeBoolCondition + '=true Order By SettingFieldName__c Nulls FIRST) FROM ObjectMapping__mdt where DeveloperName =: objMappingRecord';
     
     System.debug('query = '  +query);
     return Database.query(query);
     /*return  [SELECT
                SourceObject__c,
                ( SELECT
                    AdditionalValue1__c,
                    DefaultValue__c,
                    DeveloperName,
                    FieldApiName__c,
                    isFromSetting__c,
                    MappingName__c,
                    ParentApiNameFieldPath__c,
                    SettingDeveloperName__c,
                    SettingFieldName__c,
                    SettingRecordName__c,
                    SettingType__c,
                    AdditionalRelationship__c
                FROM FieldsMapping__r where Active__c = true And isUpdateOnFailure__c = false And isUpdateOnSuccess__c = false And RequestType__c in : reqType Order By SettingFieldName__c Nulls FIRST)
                FROM ObjectMapping__mdt where DeveloperName =: objMappingRecord];*/
  }
  public static String getUpdateType(String type){
        String typeField;
        switch on type.toLowerCase() {
        when  'success'{
            typeField ='isUpdateOnSuccess__c';
        }
        when 'failure' {
            typeField ='isUpdateOnFailure__c';
        }
        when 'pending'{
            typeField ='isUpdateOnPending__c';    
        }
    }
    return typeField;
  }

  public static List<ObjectMapping__mdt> getObjMappingRecordsToUpdateByReturnType(String objMappingRecord, String type, String requestTypeBoolCondition)
  {
     
    String typeField = getUpdateType(type);
    
    if(String.isNotBlank(typeField)){
        String query = 'SELECT SourceObject__c,( SELECT AdditionalValue1__c,DefaultValue__c,DeveloperName,FieldApiName__c,MappingName__c,ParentApiNameFieldPath__c,UpdateOnNullValue__c,isUpdateOnFailure__c,isUpdateOnSuccess__c' + 
        + ' FROM FieldsMapping__r where Active__c = true And ' + requestTypeBoolCondition + ' =true And ' + typeField + ' = true ) FROM ObjectMapping__mdt where DeveloperName =: objMappingRecord';
        System.debug('query = '  +query);
        return Database.query(query);
    }
    return null;
    
  } 
  private static List<ObjectMapping__mdt> getObjMappingRecordsToUpdate(String objMappingRecord, Boolean isSuccess,String requestTypeBoolCondition)
  {
     
     String query = 'SELECT SourceObject__c,( SELECT AdditionalValue1__c,DefaultValue__c,DeveloperName,FieldApiName__c,MappingName__c,ParentApiNameFieldPath__c,UpdateOnNullValue__c,isUpdateOnFailure__c,isUpdateOnSuccess__c' + 
       + ' FROM FieldsMapping__r where Active__c = true And ' + requestTypeBoolCondition + ' =true And' + (isSuccess ? ' isUpdateOnSuccess__c '  : ' isUpdateOnFailure__c ') + ' = true ) FROM ObjectMapping__mdt where DeveloperName =: objMappingRecord';
     System.debug('query = '  +query);
     return Database.query(query);
      /*    
    
     return  [SELECT
                SourceObject__c,
                ( SELECT
                    AdditionalValue1__c,
                    DefaultValue__c,
                    DeveloperName,
                    FieldApiName__c,
                    MappingName__c,
                    ParentApiNameFieldPath__c,
                    UpdateOnNullValue__c,
                    isUpdateOnFailure__c,
                    isUpdateOnSuccess__c
                FROM FieldsMapping__r where Active__c = true And (isUpdateOnFailure__c = true or isUpdateOnSuccess__c = true) Order By SettingFieldName__c Nulls FIRST)
                FROM ObjectMapping__mdt where DeveloperName =: objMappingRecord];*/
  }


  public static  Map<String, Object> getSobjectMap(Set<String> apiFlds,String sObjectName, String objId)
  {
        String query = 'Select ' + String.join(new List<String>(apiFlds),',') + ' From ' + sObjectName + ' where Id = \'' + objId + '\'';
        System.debug('query = ' + query);
        sObject sObj = Schema.getGlobalDescribe().get(sObjectName).newSObject() ;
        sObj = Database.query(query);
        return sObj.getPopulatedFieldsAsMap();
  }


  @TestVisible
  private static string getObjApi(String obj)
  {
     switch on obj {
            when 'currentuser' {        
                return 'User';
            }
            /*  
            when value2 {       // when block 2
                // code block 2
            }
            when value3 {       // when block 3
                // code block 3
            }
            */
            when else {       // default block, optional
                return null;
            }
        } 
  }  
  
  public static void getAdditionalRelationShips(Map<String,String>additionalField_val)
  {
     Map<String,Set<String>> obj_apiFields = new Map<String,Set<String>>();
     Map<String,String> relationship_objApi = new Map<String,String>();
     
     for(String fld : additionalField_val.keySet())
     {
        String objRel = fld.substringbefore('.');
        String objApi =  getObjApi(objRel);
        System.debug('fld.substringbefore = ' + objRel);
        if(objApi ==null) continue;
        if(!relationship_objApi.containsKey(objRel)){
            relationship_objApi.put(objRel,objApi);
        }
        System.debug('relationship_objApi = ' + relationship_objApi);
        if(!obj_apiFields.containsKey(objApi))
            obj_apiFields.put(objApi,new Set<String>());
        obj_apiFields.get(objApi).add(fld.substringAfter('.'));
        System.debug('obj_apiFields = ' + obj_apiFields);
     }
     for(String rel : relationship_objApi.keySet())//obj_apiFields.keySet()) query inside a loop for each relation object
     {
           String obj = relationship_objApi.get(rel);
           String query = 'Select ' + String.join(new List<String>(obj_apiFields.get(obj)),',') + ' From '+ obj + ' Where ';
           if(rel == 'currentuser'){ 
              String userId = UserInfo.getUserId();
              query += ' Id=:userId';
           }
           else{
             query = null;
           }
           System.debug('query = ' + query);
           if(query != null)
           {
              
              List<sObject> objQuery = Database.query(query);
              Map<String,Object> objFields = objQuery[0].getPopulatedFieldsAsMap(); //currently 1 record
              System.debug('objFields = ' + objFields);
              if(rel == 'currentuser'){
                for(String fldName : objFields.keySet()){
                    String fldNameLowerCase = fldName.toLowerCase();
                     System.debug('relfldNameLowerCase = ' + ('' + rel + '.' + fldNameLowerCase));
                    if(additionalField_val.containsKey('' + rel + '.' + fldNameLowerCase)){ 
                        additionalField_val.put(('' + rel + '.' + fldNameLowerCase),'' + objFields.get(fldName));
                    }
                }
              }     
           }
      }
     
  }
  
  

  public static Map<String,String> getAttributeMap(Id objId,String objMappingRecord, String requestTypeBoolCondition){
      
         
         
        System.debug('requestTypeBoolCondition = ' + requestTypeBoolCondition);
        List<ObjectMapping__mdt> objMapping = getObjMappingRecords(objMappingRecord,requestTypeBoolCondition);
        System.debug('objMapping = ' + objMapping);
        String sObjectName = objMapping[0].SourceObject__c;
        Map<String,FieldMapping__mdt> fldAttribute_fldMap = new Map<String,FieldMapping__mdt>();
        
        Set<String> apiFlds = new Set<String>(); 
        Integer indx = 0;
        Integer settingIndx = null;
        Map<String,String> additionalField_val = new Map<String,String>();
        for(FieldMapping__mdt m : objMapping[0].FieldsMapping__r){
            
            //System.debug(' fldMapp = ' +  m);
            fldAttribute_fldMap.put(m.MappingName__c,m);
            if(settingIndx == null && m.isFromSetting__c){
                settingIndx = indx;
            }
            else if(String.isNotBlank(m.AdditionalRelationship__c)){
                additionalField_val.put(m.AdditionalRelationship__c.toLowerCase(),null);
            }
            else if(String.isNotBlank(m.FieldApiName__c)){
                apiFlds.add(m.FieldApiName__c);
            }
            else if(String.isNotBlank(m.ParentApiNameFieldPath__c)){
                apiFlds.add(m.ParentApiNameFieldPath__c);
            }
            indx++;
        }
        if(additionalField_val.size()>0){
            getAdditionalRelationShips(additionalField_val);
        }
        System.debug('additionalField_val = ' + additionalField_val);
        System.debug('fldAttribute_fldMap = ' + fldAttribute_fldMap);
        Map<String,SettingWrapper> settingWrapperMap = getSettingsMap(objMapping[0].FieldsMapping__r,settingIndx);
        Map<String,String> attName_attVal = new Map<String,String>();
        /*
        String query = 'Select ' + String.join(new List<String>(apiFlds),',') + ' From ' + sObjectName + ' where Id = \'' + objId + '\'';
        
        sObject sObj = Schema.getGlobalDescribe().get(sObjectName).newSObject() ;
        sObj = Database.query(query);
        Map<String, Object> fieldsToValue = sObj.getPopulatedFieldsAsMap();
        */
        Map<String, Object> fieldsToValue;
        if(apiFlds.size()>0){
            fieldsToValue = getSobjectMap(apiFlds,sObjectName,objId);
        }

        for (FieldMapping__mdt fm : fldAttribute_fldMap.values())
        {
            String attName = fm.MappingName__c;        
            Object value;
            if(fm.isFromSetting__c){
               SettingWrapper setWrap = settingWrapperMap.get(fm.SettingDeveloperName__c);
               String val = '' + (setWrap.getObj() != null ? (setWrap.getObj().get(fm.SettingRecordName__c) != null ? setWrap.getObj().get(fm.SettingRecordName__c).get(fm.SettingFieldName__c) : '') : ''); 
               if(val ==null ) val = '';
               attName_attVal.put(attName,''+val);
            }
            else if(String.isNotBlank(fm.AdditionalRelationship__c) && additionalField_val.containsKey(fm.AdditionalRelationship__c.toLowerCase())){
                attName_attVal.put(attName,''+additionalField_val.get(fm.AdditionalRelationship__c.toLowerCase()));
            }
            else if(String.isNotBlank(fm.DefaultValue__c) && String.isBlank(fm.FieldApiName__c) && String.isBlank(fm.ParentApiNameFieldPath__c)) {
                attName_attVal.put(attName,'' + fm.DefaultValue__c);
            }
            else if(String.isNotBlank(fm.FieldApiName__c) && fieldsToValue != null && fieldsToValue.containsKey(fm.FieldApiName__c))
            {
                value = fieldsToValue.get(fm.FieldApiName__c);
                attName_attVal.put(attName,'' + (value == null ? '' : value));
            }
            else if(String.isNotBlank(fm.ParentApiNameFieldPath__c) && fieldsToValue != null && fieldsToValue.containsKey(fm.ParentApiNameFieldPath__c.substringBefore('.')))
            {
                value = getRelationShipField(fm.ParentApiNameFieldPath__c,fieldsToValue);
                attName_attVal.put(attName,'' + (value == null ? '' : value));
            }
            
            /*
            else if(String.isNotBlank(fm.DefaultValue__c)))
            {
                boolean parentFieldBlank =  fieldsToValue == null || (!fieldsToValue.containsKey(fm.ParentApiNameFieldPath__c.substringBefore('.') || getRelationShipField(fm.ParentApiNameFieldPath__c,fieldsToValue) == null)
                if()
                value = getRelationShipField(fm.ParentApiNameFieldPath__c,fieldsToValue);
                attName_attVal.put(attName,'' + (value == null ? '' : value));
            }
            */
            else{
              attName_attVal.put(attName,'');
            }   

            
        }
        System.debug('attName_attVal = ' + JSON.serialize(attName_attVal));
        return attName_attVal;
  }

  
  private static Object getValToUpdate(Map<String, Schema.SObjectField> sourceObjFieldMap, String apiField, String mappingVal)
  {
      Schema.SObjectField objFld = sourceObjFieldMap.get(apiField);
      String fielddataType = sourceObjFieldMap.get(apiField).getDescribe().getType().name();
      Object val = getDynamicVal(mappingVal,fielddataType);
      return val;
  }
  public static List<sObject> getObjectToUpdateByMapping(Id objId, String metadatName,Map<String,String> attMap,boolean isSuccess,String requestTypeBoolCondition){
      
        List<sObject> objectsToUpdate = new List<sObject>();
        List<ObjectMapping__mdt> paymentMappings =  getObjMappingRecordsToUpdate(metadatName,isSuccess,requestTypeBoolCondition);         
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        String objName =  paymentMappings[0].SourceObject__c;
        Map<String, Schema.SObjectField> sourceObjFieldMap = gd.get(objName).getDescribe().fields.getMap();
        sObject objToUpdate = gd.get(objName).newSObject();
        objToUpdate.Id = objId;
        for(FieldMapping__mdt fm : paymentMappings[0].FieldsMapping__r)
        {        
            //System.debug('fm = ' + fm);
            if(attMap.containsKey(fm.MappingName__c))
            {
                if(String.isBlank(attMap.get(fm.MappingName__c)) && fm.UpdateOnNullValue__c)
                {
                    objToUpdate.put(fm.FieldApiName__c,null);
                }
                else
                {
                    /*Schema.SObjectField objFld = sourceObjFieldMap.get(fm.FieldApiName__c);
                    String fielddataType = sourceObjFieldMap.get(fm.FieldApiName__c).getDescribe().getType().name();
                    Object val = getDynamicVal(attMap.get(fm.MappingName__c),fielddataType);
                    */
                    objToUpdate.put(fm.FieldApiName__c,getValToUpdate(sourceObjFieldMap,fm.FieldApiName__c,attMap.get(fm.MappingName__c)));
                }
            }
            else if(String.isNotBlank(fm.DefaultValue__c))
            {
               if(fm.DefaultValue__c.equalsIgnoreCase('NULL')){
                   objToUpdate.put(fm.FieldApiName__c,null);
               }
               else{
                    objToUpdate.put(fm.FieldApiName__c,getValToUpdate(sourceObjFieldMap,fm.FieldApiName__c,fm.DefaultValue__c));
               }
            }

        }
        System.debug('objToUpdate = ' + objToUpdate);
        objectsToUpdate.add(objToUpdate);
        return objectsToUpdate;
   }



   public static List<sObject> getObjectToUpdateByMappingByReturnType(Id objId, String metadatName,Map<String,String> attMap,String type,String requestTypeBoolCondition){
      
        List<sObject> objectsToUpdate = new List<sObject>();
        List<ObjectMapping__mdt> paymentMappings =  getObjMappingRecordsToUpdateByReturnType(metadatName,type,requestTypeBoolCondition);         
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        String objName =  paymentMappings[0].SourceObject__c;
        Map<String, Schema.SObjectField> sourceObjFieldMap = gd.get(objName).getDescribe().fields.getMap();
        sObject objToUpdate = gd.get(objName).newSObject();
        objToUpdate.Id = objId;
        Map<String,String> attMapLowerCase = new Map<String,String>();
        for(String att : attMap.keySet()){
            attMapLowerCase.put(att.toLowerCase(),attMap.get(att)); 
        }
        system.debug('attMapLowerCase = ' + attMapLowerCase);
        for(FieldMapping__mdt fm : paymentMappings[0].FieldsMapping__r)
        {        
            //System.debug('fm = ' + fm);
            if(String.isNotBlank(fm.MappingName__c))
            {
                String mapName = fm.MappingName__c.toLowerCase();
                if(attMapLowerCase.containsKey(mapName))
                {
                    if(String.isBlank(attMapLowerCase.get(mapName)) && fm.UpdateOnNullValue__c)
                    {
                        objToUpdate.put(fm.FieldApiName__c,null);
                    }
                    else
                    {
                        /*Schema.SObjectField objFld = sourceObjFieldMap.get(fm.FieldApiName__c);
                        String fielddataType = sourceObjFieldMap.get(fm.FieldApiName__c).getDescribe().getType().name();
                        Object val = getDynamicVal(attMap.get(fm.MappingName__c),fielddataType);
                        */
                        objToUpdate.put(fm.FieldApiName__c,getValToUpdate(sourceObjFieldMap,fm.FieldApiName__c,attMapLowerCase.get(mapName)));
                    }
                }
            }
            else if(String.isNotBlank(fm.DefaultValue__c))
            {
               if(fm.DefaultValue__c.equalsIgnoreCase('NULL')){
                   objToUpdate.put(fm.FieldApiName__c,null);
               }
               else{
                    objToUpdate.put(fm.FieldApiName__c,getValToUpdate(sourceObjFieldMap,fm.FieldApiName__c,fm.DefaultValue__c));
               }
            }

        }
        System.debug('objToUpdate = ' + objToUpdate);
        objectsToUpdate.add(objToUpdate);
        return objectsToUpdate;
   }

   public static Object getDynamicVal(String value,String fielddataType){
   
     switch on fielddataType.toLowerCase()
     {
        when 'decimal' {system.debug('Decimal'); return Decimal.valueOf(value);}
        when 'double' {system.debug('Double'); return Decimal.valueOf(value);}
        when  'boolean' {system.debug('Boolean'); return Boolean.valueOf(value);}
        when  'date' {system.debug('Date'); return Date.valueOf(value);}
        when  'datetime' {system.debug('Datetime'); return Datetime.valueOf(value);}
        when 'percent' {return Decimal.valueOf(value);}
        when else{
            return value;
        }

    }
   
   }

   public static string ConvertMapToString(Map<string, string> dictionary,boolean sortList)
   {
        // Acquire keys and sort them.
        List<String> lst = new List<String>(dictionary.keySet());
        if (sortList)
        {
            lst.Sort();
        }

        String subString = '';
        String value = '';
        // Loop through keys.
        for (String key : lst)
        {
                
            value = (key != null && dictionary.get(key) != null) ? EncodingUtil.urlEncode(dictionary.get(key), 'UTF-8') : '';
            List<String> fillers = new String[]{key,value};
            subString += String.Format('{0}={1}&', fillers);
        }

        subString = subString.Substring(0, subString.length() - 1);
        system.debug('subString  = ' + subString);
        return subString;
    }

    public static Map<String,String> ConvertParamToMap(String params)
    {
            List<String> paramsSplited = params.Split('&');
            Map<string, string> paramsMap = new Map<string, string>();
            for(String pr : paramsSplited)
            {
              List<string> keyVal = pr.Split('=');
              paramsMap.put(keyVal[0],keyVal.size()>1? keyVal[1] : '');
            }
            return paramsMap;
    }

}