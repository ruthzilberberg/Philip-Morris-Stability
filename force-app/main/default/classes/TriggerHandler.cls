/****************************************************************************************
Name              : TriggerHandler
Description      :
Revision History  :
Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
----------------------------------------------------------------------------------------
1. Samuel Boukhobza           24/07/2018             Gal Regev          [SW-30196]
----------------------------------------------------------------------------------------
****************************************************************************************/

public virtual class TriggerHandler {

    //IDAN - from TriggerSetting class
    private static Map<String, Set<String>> disabledTriggers;
    private static Set<String> disabledTriggersByTestOnWholeTriggerName = new Set<String>();

    // static map of handlername, times run() was invoked
    private static Map<String, LoopCount> loopCountMap;
    private static Set<String> bypassedHandlers;

    private static String namespace;

    private static List<Triggers_Manager__c> Triggers_ManagerCs_x;
    public static List<Triggers_Manager__c> Triggers_ManagerCs{
        get{
            if(Triggers_ManagerCs_x == null){
                Triggers_ManagerCs_x = [SELECT Name,context__c,Action__c,Active__c,User__c,Profile__c FROM Triggers_Manager__c WHERE Namespace__c =: namespace];
                return Triggers_ManagerCs_x;
            }else{
                return Triggers_ManagerCs_x;
            }
        }
    }

    // the current context of the trigger, overridable in tests
    @TestVisible
    private TriggerContext context;

    // the current context of the trigger, overridable in tests
    @TestVisible
    private Boolean isTriggerExecuting;

    // static initialization
    static {
        loopCountMap = new Map<String, LoopCount>();
        bypassedHandlers = new Set<String>();
    }

    public TriggerHandler(){
        this.setTriggerContext();
    }

    /***************************************
     * public instance methods
     ***************************************/

    public void setNamespace(String name){
        namespace = name;
    }

    // main method that will be called during execution
    public void run() {

        if(!isNamespaceActive()) return;

        if(!validateRun()) return;

        addToLoopCount();

        // dispatch to the correct handler method

        If(!isContextActive()) return;
        if(this.context == TriggerContext.BEFORE_INSERT) {
            this.beforeInsert();
        } else if(this.context == TriggerContext.BEFORE_UPDATE) {
            this.beforeUpdate();
        } else if(this.context == TriggerContext.BEFORE_DELETE) {
            this.beforeDelete();
        } else if(this.context == TriggerContext.AFTER_INSERT) {
            this.afterInsert();
        } else if(this.context == TriggerContext.AFTER_UPDATE) {
            this.afterUpdate();
        } else if(this.context == TriggerContext.AFTER_DELETE) {
            this.afterDelete();
        } else if(this.context == TriggerContext.AFTER_UNDELETE) {
            this.afterUndelete();
        }

    }

    public void setMaxLoopCount(Integer max) {
        String handlerName = getHandlerName();
        if(!TriggerHandler.loopCountMap.containsKey(handlerName)) {
            TriggerHandler.loopCountMap.put(handlerName, new LoopCount(max));
        } else {
            TriggerHandler.loopCountMap.get(handlerName).setMax(max);
        }
    }

    public void clearMaxLoopCount() {
        this.setMaxLoopCount(-1);
    }

    public void createTrigger(String name, String level){
	    
		set<String> csNames = new set<string>();
		for(Triggers_Manager__c tm : Triggers_ManagerCs){
			csNames.add(tm.Name);
		}

        String cryptoName       =   namespace;

        String context  =   '';

        if( level.contains( 'Context' ) ) {
            context = String.valueOf(this.context);
        }
        if( context != '' ){
            cryptoName += ':' + context;
        }
        if( name != '' ){
            cryptoName += ':' + name;
        }

        cryptoName  =   this.generateCryptoName( cryptoName );
        System.debug('cryptoName size ' + cryptoName.length());
        Triggers_Manager__c trg = new Triggers_Manager__c(Name = cryptoName,Namespace__c = namespace,Active__c = true,Context__c=context,Action__c=name,User__c='',Profile__c='');
        try{
		  if(!csNames.contains(cryptoName)){
			insert trg;
		  }
        }catch(Exception e){system.debug(e.getMessage());}
        
        return;

    }

    //IDAN - from TriggerSetting class
    private Boolean validateTrigger(Triggers_Manager__c trg, String functionName, String level ) {
        if( trg == null ){
            this.createTrigger( functionName, level );
            return true;
        }

        Boolean active = trg.Active__c && filterBy(trg);

        return active;
    }

    public  Boolean isNamespaceActive(){
        return this.validateTrigger( this.getNamespaceTrigger(), '','Name' );
    }

    public Boolean isContextActive(){
        return this.validateTrigger( this.getContextTrigger(), '', 'Context' );
    }

    public  Boolean isActionAllowed( String actionName){
        return this.validateTrigger( this.getActionTrigger( actionName ), actionName, 'ContextAction' );
    }

    public String generateCryptoName( String name ){
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(name));
        return EncodingUtil.convertToHex(hash);
    }

    public Triggers_Manager__c getNamespaceTrigger(){
        List<Triggers_Manager__c> trgList       =   Triggers_ManagerCs;
        List<Triggers_Manager__c> nameSpaceTrigger    =   new List<Triggers_Manager__c>();
        for(Triggers_Manager__c t:trgList){
            if( t.Context__c == null && t.Action__c == null ){
                nameSpaceTrigger.add(t);
                break;
            }
        }
        Triggers_Manager__c trg             =   nameSpaceTrigger.size() > 0 ? nameSpaceTrigger.get(0) : null;
        return trg;
    }

    public Triggers_Manager__c getContextTrigger(){
        List<Triggers_Manager__c> trgList       =   Triggers_ManagerCs;
        List<Triggers_Manager__c> contextTrigger      =   new List<Triggers_Manager__c>();
        for(Triggers_Manager__c t:trgList){
            if( t.Context__c == String.valueOf( this.context ) && t.Action__c == null ){
                contextTrigger.add(t);
                break;
            }
        }
        Triggers_Manager__c trg             =   contextTrigger.size() > 0 ? contextTrigger.get(0) : null;
        return trg;
    }

    public Triggers_Manager__c getActionTrigger( String functionName ){
        List<Triggers_Manager__c> trgList       =   Triggers_ManagerCs;
        List<Triggers_Manager__c> actionTrigger =   new List<Triggers_Manager__c>();
        for(Triggers_Manager__c t:trgList){
            if( t.Context__c == String.valueOf( this.context ) && t.Action__c == functionName ){
                actionTrigger.add(t);
                break;
            }
        }
        Triggers_Manager__c trg             =   actionTrigger.size() > 0 ? actionTrigger.get(0) : null;
        return trg;
    }




    public Boolean filterBy(Triggers_Manager__c trg){
        if( trg.Profile__c != null || trg.User__c != null){
            Boolean profileTest     = this.profileFilter( trg.Profile__c );
            Boolean userTest        = this.userFilter( trg.User__c );
			System.debug('userTest=='+userTest);
			System.debug('profileTest=='+profileTest);
            return  profileTest && userTest;
        }
        return true;
    }

    private Boolean profileFilter( String profile ){
        if( profile == null ){return true;}
        String profileId            =   UserInfo.getProfileId();
        String profileName          =   [SELECT Id,Name FROM Profile WHERE Id=:profileId].Name;
        List<String> profileList    =   profile.split(',');
        return !profileList.contains( profileName );
    }

    private Boolean userFilter( String user ){
        if( user == null ){return true;}
        String userName             =   UserInfo.getUserName();
        List<String> UserList       =   user.split(',');
        return !UserList.contains( userName );
    }

    /***************************************
     * public static methods
     ***************************************/

    public static void bypass(String handlerName) {
        TriggerHandler.bypassedHandlers.add(handlerName);
    }

    public static void clearBypass(String handlerName) {
        TriggerHandler.bypassedHandlers.remove(handlerName);
    }

    public static Boolean isBypassed(String handlerName) {
        return TriggerHandler.bypassedHandlers.contains(handlerName);
    }

    public static void clearAllBypasses() {
        TriggerHandler.bypassedHandlers.clear();
    }

    /***************************************
     * private instancemethods
     ***************************************/

    @TestVisible
    private void setTriggerContext() {
        this.setTriggerContext(null, false);
    }

    @TestVisible
    private void setTriggerContext(String ctx, Boolean testMode) {
        if(!Trigger.isExecuting && !testMode) {
            this.isTriggerExecuting = false;
            return;
        } else {
            this.isTriggerExecuting = true;
        }

        if((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) ||
                (ctx != null && ctx == 'before insert')) {
            this.context = TriggerContext.BEFORE_INSERT;
        } else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) ||
                (ctx != null && ctx == 'before update')){
            this.context = TriggerContext.BEFORE_UPDATE;
        } else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) ||
                (ctx != null && ctx == 'before delete')) {
            this.context = TriggerContext.BEFORE_DELETE;
        } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) ||
                (ctx != null && ctx == 'after insert')) {
            this.context = TriggerContext.AFTER_INSERT;
        } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) ||
                (ctx != null && ctx == 'after update')) {
            this.context = TriggerContext.AFTER_UPDATE;
        } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) ||
                (ctx != null && ctx == 'after delete')) {
            this.context = TriggerContext.AFTER_DELETE;
        } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) ||
                (ctx != null && ctx == 'after undelete')) {
            this.context = TriggerContext.AFTER_UNDELETE;
        }
    }

    // increment the loop count
    @TestVisible
    private void addToLoopCount() {
        String handlerName = getHandlerName();
        if(TriggerHandler.loopCountMap.containsKey(handlerName)) {
            Boolean exceeded = TriggerHandler.loopCountMap.get(handlerName).increment();
            if(exceeded) {
                Integer max = TriggerHandler.loopCountMap.get(handlerName).max;
                throw new TriggerHandlerException('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName);
            }
        }
    }

    // make sure this trigger should continue to run
    @TestVisible
    private Boolean validateRun() {

        if(!this.isTriggerExecuting || this.context == null) {
            throw new TriggerHandlerException('Trigger handler called outside of Trigger execution');
        }
        if(TriggerHandler.bypassedHandlers.contains(getHandlerName())) {
            return false;
        }
        return true;
    }

    @TestVisible
    private String getHandlerName() {
        return String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    }


    /***************************************
     * context methods
     ***************************************/

    // context-specific methods for override
    @TestVisible
    protected virtual void beforeInsert(){}
    @TestVisible
    protected virtual void beforeUpdate(){}
    @TestVisible
    protected virtual void beforeDelete(){}
    @TestVisible
    protected virtual void afterInsert(){}
    @TestVisible
    protected virtual void afterUpdate(){}
    @TestVisible
    protected virtual void afterDelete(){}
    @TestVisible
    protected virtual void afterUndelete(){}

    /***************************************
     * inner classes
     ***************************************/

    // inner class for managing the loop count per handler
    @TestVisible
    private class LoopCount {
        private Integer max;
        private Integer count;

        public LoopCount() {
            this.max = 5;
            this.count = 0;
        }

        public LoopCount(Integer max) {
            this.max = max;
            this.count = 0;
        }

        public Boolean increment() {
            this.count++;
            return this.exceeded();
        }

        public Boolean exceeded() {
            if(this.max < 0) return false;
            if(this.count > this.max) {
                return true;
            }
            return false;
        }

        public Integer getMax() {
            return this.max;
        }

        public Integer getCount() {
            return this.count;
        }

        public void setMax(Integer max) {
            this.max = max;
        }
    }

    // possible trigger contexts
    @TestVisible
    private enum TriggerContext {
        BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
        AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE,
        AFTER_UNDELETE
    }

    // exception class
    public class TriggerHandlerException extends Exception {}

}