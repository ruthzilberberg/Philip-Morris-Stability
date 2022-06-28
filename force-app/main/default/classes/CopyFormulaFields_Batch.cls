global class CopyFormulaFields_Batch implements Database.Batchable<SObject> {
	
	//Schedualed Apex for each Object is in seperate classes  : LeadCopyFields_Sched | AccountCopyFields_Sched  |  ContactCopyFields_Sched 
	
	

	public String fieldsSelect = '';
	public String ObjectType = '';  
    public datetime prevRun;

	global CopyFormulaFields_Batch(String objectType) {
	    
        this.prevRun = prevRun;
  
        //Manage 3 objects to run in a Chain
		list<CopyFormulaFields_Batch__c>  csList = new list<CopyFormulaFields_Batch__c>([select id,Current_Object_Running__c from CopyFormulaFields_Batch__c limit 1]);//CopyFormulaFields_Batch__c.getInstance();
		CopyFormulaFields_Batch__c  cs = new CopyFormulaFields_Batch__c();
		if(csList.isEmpty()){ 
			insert  cs;
		   }else{
			cs = csList[0];
		   }
		if(objectType == 'Account' )  cs.Current_Object_Running__c = 'Account'; 
		if(objectType == 'Contact' )  cs.Current_Object_Running__c = 'Contact';
        if(objectType == 'Lead' )  cs.Current_Object_Running__c = 'Lead';
        update cs;
        
		this.ObjectType = objectType;
		for(CopyFormulasMapping__mdt mdt : [select  SourceFiled__c, TargetField__c from CopyFormulasMapping__mdt WHERE sObjectType__c =: ObjectType] ){
			fieldsSelect += ','+mdt.SourceFiled__c + ','+mdt.TargetField__c; 
		}
	}
	
	
	global Database.QueryLocator start(Database.BatchableContext context) {
		CopyFormulaFields_Batch_Time__c csTime = CopyFormulaFields_Batch_Time__c.getinstance();
        prevRun = csTime.Prev_Time__c;
		//return Database.getQueryLocator('SELECT Id'+ fieldsSelect +' FROM '+ ObjectType +'  Where LastmodifiedDate >=: prevRun');
		return Database.getQueryLocator('SELECT Id'+ fieldsSelect +' FROM '+ ObjectType);
	}

	
   	global void execute(Database.BatchableContext context, List<SObject> scope) {
	    
		List<SObject> scopeToUpdate = new List<SObject>();

		List<CopyFormulasMapping__mdt> mdt  = new List<CopyFormulasMapping__mdt>([select  SourceFiled__c, TargetField__c from CopyFormulasMapping__mdt WHERE sObjectType__c =: ObjectType]) ;
		
		for(SObject mySobj : scope){
			Boolean isObjectUpdated = false;
		    for(CopyFormulasMapping__mdt mdtMap : mdt){
				object val = mySobj.get(mdtMap.SourceFiled__c);
				if(mySobj.get(mdtMap.SourceFiled__c) != mySobj.get(mdtMap.TargetField__c)){
					mySobj.put(mdtMap.TargetField__c, val);
					isObjectUpdated = true;
				}
			}
			if(isObjectUpdated)scopeToUpdate.add(mySobj);
		}
		if(scopeToUpdate.size() > 0) update scopeToUpdate;
	}
	
	  
	global void finish(Database.BatchableContext context) {
		CopyFormulaFields_Batch__c  cs = [select id,Current_Object_Running__c from CopyFormulaFields_Batch__c limit 1];//CopyFormulaFields_Batch__c.getInstance();
		String nextObject = null;
		switch on cs.Current_Object_Running__c {
			when 'Account' {
				nextObject = 'Contact';
				
			}
			when 'Contact' {
				nextObject = 'Lead';
			}
			when else {
				
			}
		}
		if(nextObject != null) {
			cs.Current_Object_Running__c = nextObject;
			Database.executeBatch(new CopyFormulaFields_Batch(nextObject));
		}
		if(!Test.isRunningTest())update cs;
	}
	//Schedualed Apex for each Object is in seperate classes  : LeadCopyFields_Sched | AccountCopyFields_Sched  |  ContactCopyFields_Sched 
}