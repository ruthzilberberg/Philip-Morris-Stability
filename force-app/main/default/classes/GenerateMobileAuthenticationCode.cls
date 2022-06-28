public with sharing class GenerateMobileAuthenticationCode {
    // public Account acc;
    // public Lead curLead;
    public GenerateMobileAuthenticationCode() {
        // this.acc = acc;
        // this.curLead = l;
    }
    @InvocableMethod
    public void generatecode(Account acc, Lead l) {
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
