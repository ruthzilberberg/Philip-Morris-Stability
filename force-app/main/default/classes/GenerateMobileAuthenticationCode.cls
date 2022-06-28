public with sharing class GenerateMobileAuthenticationCode {
    public Account acc
    public GenerateMobileAuthenticationCode() {

    }
    public string generatecode() {
        String code = String.valueOf(Math.round((Math.random() * (9000) + 1000)));

    }
}
