global with sharing class GenerateMobileAuthenticationCode {
    // public Account acc;
    // public Lead curLead;
    global GenerateMobileAuthenticationCode() {
        // this.acc = acc;
        // this.curLead = l;
    }
    @InvocableMethod
    global void generatecode(Account acc, Lead l) {
        String code = String.valueOf(Math.round((Math.random() * (9000) + 1000)));
        System.debug(code);
        if (acc){
            acc.Verification_Code_Number__c = code;
            acc.Issued_Verification_Code_Time__c = datetime.now();
        }
        else if(l){
            l.Code_Number__c = code;
            l.Issued_Verification_Code_Time__c = datetime.now();
        }
            
    }
}
