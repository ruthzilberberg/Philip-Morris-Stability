/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Rental_HandoverTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Rental_HandoverTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Rental_Handover__c());
    }
}