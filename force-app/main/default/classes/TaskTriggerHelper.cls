/****************************************************************************************
Name              : TaskTriggerHelper
Description       :
Revision History  :
Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
----------------------------------------------------------------------------------------
1. Nevo Harari               25/11/2018             Kirill Hantayev          [SW-31407]
2. Arkadi Luder              29/11/2018             Kirill Hantayev          [SW-31407]
3. Nevo Harari (smallBugfix) 06/12/2018             Kirill Hantayev          [SW-31407]
----------------------------------------------------------------------------------------*/
public class TaskTriggerHelper {

    public class applicationException extends Exception {}

    public void populateTemplateWithValues(List<Task> TasksNewList, map<Id, Task> TaskOldMAp) {
        List<Task> tasks = new List<Task>();
        Set<ID> templatesIds = new Set<Id>();
        System.debug('for TasksNewList:');
        for (Task myTask : TasksNewList) {
            system.debug(myTask);
            if (myTask.SMS_Template__c != null ) {
                if (Trigger.isUpdate && myTask.SMS_Template__c != TaskOldMAp.get(myTask.id).SMS_Template__c) {
                    tasks.add(myTask);
                    templatesIds.add(myTask.SMS_Template__c);
                } else {
                    tasks.add(myTask);
                    templatesIds.add(myTask.SMS_Template__c);
                }
            }
        }

        if (templatesIds.size() > 0) {
            System.debug('templatesIds==' + templatesIds);
		   
            Map<Id, SMS_Template__c> templatesMap = new Map<Id, SMS_Template__c>([select id,SMS_Template__c FROM SMS_Template__c WHERE ID IN:templatesIds]);

            //Get Fields To select Dynamic From Task
            String filedList = 'id';
            Set<String> fieldSet = new Set<String>();
            String whatFields = 'Id';
            String whoFields = 'Id';
            Set<Id> whatSet = new Set<Id>();
            Set<Id> whoSet = new Set<Id>();
            String WhatObjectName;
            String WhoObjectName;
			Map<id ,SObject> whoMap = new Map<id ,SObject>();
            for (SMS_Template__c template : templatesMap.values()) {
                String taskTemp = template.SMS_Template__c;
                System.debug('arkadi template: ' + taskTemp);
                List<string> dirtyWords = taskTemp.split(' ');
                for (string dirtWord : dirtyWords) {
                    if (dirtWord.contains('{{{')) {
                        String objName = getObjName(dirtWord);
                        String fieldName = getFieldName(dirtWord);
                        System.debug('arkadi word: ' + dirtWord + ' - ' + objName + '.' + fieldName);
                        if (objName == 'Contact' || objName == 'Lead') {
                            FieldSet.add('Who.' + fieldName);
							WhoObjectName = objName;
							if(!fieldName.contains('.')){
							   whoFields += ','+fieldName;
							}
                        } else {
                            if(!dirtWord.contains('.')){
								 filedList += ',' + fieldName;
							}else{
								WhatObjectName = objName;
	//                          FieldSet.add('What.' + fieldName);
								if(!whatFields.contains(fieldName)) ///Nevo SW-40678
								    whatFields += ','+fieldName;
							}
                       }
                    }
                }
            }
            for (String fieldName : FieldSet) {
                filedList += ',' + fieldName;
            }
			System.debug('arkadi filedList: '+filedList);
            for(Task t : tasks){
               if(t.WhatId != null){
			      whatSet.add(t.WhatId);
				}
				if(t.WhoId != null){
				  whoSet.add(t.WhoId);
				}
            }
            Map<Id,SObject> whatList = new Map<Id,SObject> ();
			if(WhatObjectName != null){
					
				try{
					whatList = new Map<Id,SObject>(Database.query('SELECT '+whatFields+' FROM '+WhatObjectName+' WHERE Id IN: whatSet'));
					System.debug('whatList=='+whatList);
				}catch(Exception e){System.debug('***Exception error ==='+e);}
			}
			system.debug('======> Select ' + filedList + ' From Task Where ID IN: tasks');
             List<Task> myDatabaseTasks =  New List<Task>();
            try{
            	///////myDatabaseTasks = Database.query('Select ' + filedList + ' From Task Where ID IN: tasks');    
				if(WhoObjectName != null ){
				    System.debug('=====SELECT '+whoFields+' FROM '+WhoObjectName+' WHERE Id IN: '+whatSet);
					whoMap = new Map<id ,SObject>( Database.query('SELECT '+whoFields+' FROM '+WhoObjectName+' WHERE Id IN: whoSet'));
					System.debug('whoMap==='+whoMap);
				}
            }Catch(exception e){ System.debug('Exception error ==='+e);} 
              
			System.debug('myDatabaseTasks==='+myDatabaseTasks);
            Map<Id, Task> DatabaseTaskMAp = new Map<Id, Task>(myDatabaseTasks);
            List<Task> TasksToUpdate = new List<Task>();

            //Do MergFields
            for (task myTask : tasks) {
                task myDatabaseTask = DatabaseTaskMAp.get(myTask.id);
                string newComment = '';
                String taskTemp = templatesMap.get(myTask.SMS_Template__c).SMS_Template__c;
                if (taskTemp != null && taskTemp != '') {
                    List<string> dirtyWords = taskTemp.split(' ');
                    for (string dirtWord : dirtyWords) {
                        if (dirtWord.contains('{{{')) {
                            //Do MAgic
                            String objName = getObjName(dirtWord);
                            string value = '';
                            string continueText = dirtWord.substringAfterLast('}');
                            System.debug('continueText==' + continueText);
                            string myfield = getFieldName(dirtWord);
                          if (objName == 'Contact' || objName == 'Lead') {
                                System.debug('objName==' + objName);

                                System.debug('dirtWord==' + objName);
                                System.debug('myDatabaseTask.Who==' + myDatabaseTask);
                               // if (myDatabaseTask != null)
								   // value = getMergeFields(dirtWord, myDatabaseTask.Who);//String.valueOf(myTask.Who.get(myfield));//
                                 if(whoMap.get(myTask.WhoId) != null &&  whoMap.get(myTask.WhoId).get(myfield) != null){
								    
								    value = String.valueOf( whoMap.get(myTask.WhoId).get(myfield) );
								 }
                            } else {
							     System.debug('whatList=='+whatList);
							     System.debug('myfield=='+myfield);
							     System.debug('whatList.get(myTask.WhoId==='+whatList.get(myTask.WhoId));
							     if(!whatList.values().isEmpty()){
								    value = String.valueOf( whatList.values()[0].get(myfield) );
								 }
                               /* System.debug('objName==' + objName);
                                if (myDatabaseTask != null)
                                    value = getMergeFields(dirtWord, whatList.get(myTask.WhatId));*/
                            }
                            newComment += ' ' + value + ' ';
							//newComment += '\n';
                            newComment += continueText != null ? continueText : '';
                            System.debug('value==' + value);
                        } else {
                            newComment += ' ' + dirtWord + ' ';
                        }
                    }
                }
				newComment = newComment.replaceAll('br','\n');
                System.debug('newComment==' + newComment);
                if (Trigger.isInsert) {
                    TasksToUpdate.add(new Task (Id = myTask.id, Description = newComment));
                } else {
                    myTask.Description = newComment;
                }
            }
            if (TasksToUpdate.size() > 0 && Trigger.isAfter) {
                update TasksToUpdate;
            }
        }

    }


    //Util Methods

    private String getObjName(string template) {
        template = template.substringBetween('{{{', '}}}');
        System.debug('template=====' + template);
        String objNAme = template.split('\\.')[0];
        return objNAme;
    }
    private String getFieldName(string template) {
        template = template.substringBetween('{{{', '}}}');
        System.debug('template=====' + template);
        String fieldNAme = template.split('\\.')[1];
        return fieldNAme;
    }
    private String getMergeFields(string template, sobject obj) {
        template = template.substringBetween('{{{', '}}}');
        String fieldNAme = template.split('\\.')[1];
        System.debug('fieldNAme=====' + fieldNAme);
        System.debug('obj=====' + obj);
        if (obj == null) return '';
        if (fieldNAme == null) return '';
		if(template.containsIgnoreCase('Account')){
		   
			return String.valueOf(obj.get(template));
		}
        return String.valueOf(obj.get(fieldNAme));
    }


}