/****************************************************************************************
Name              : Async_PromotionLogic
Description       :
Revision History  :
Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
----------------------------------------------------------------------------------------
1. Nevo Harari               18/06/2019              Ella Bernachik         [SW-33792]
----------------------------------------------------------------------------------------*/
public class Async_PromotionLogic  implements Queueable {

    private List<Order> Orders;
    //private Map<Id,Order> orderMap; 
    public Async_PromotionLogic(List<Order> orders) {
        this.Orders = orders;
        //Set<Id> orderIds = (new Map<Id,Order> (orders)).keySet();
        //this.orderMap = new Map<Id,Order>([Select Id,Account.PersonContactId,AccountId From Order where Id in : orderIds ]);
        
    }

    public void execute(QueueableContext context) {
        
        Map<Id, List<Order>> accIdToOrders = new Map<Id, List<Order>>();
        Map<String, Order> codeToOrders = new Map<String, Order>();
        Map<Id, String> accIdToCode = new Map<Id, String>();
        Map<String, Promotion__c> promotionCodeToPromotion = new Map<String, Promotion__c>();
        //collect codes
        List<String> orderCodes = new List<String>();
        for (Order ordr : Orders) {
            
            if(ordr.Promotion_code__c != null){
                ordercodes.add(ordr.Promotion_code__c.trim().toLowerCase());
                codeToOrders.put(ordr.Promotion_code__c.trim().toLowerCase(), ordr);
            }
            //pop acc-orders map
            if(accIdToOrders.containsKey(ordr.AccountId)) accIdToOrders.get(ordr.AccountId).add(ordr);
            else{accIdToOrders.put(ordr.AccountId,new List<order>{ordr} ); }
        }
        System.debug('codeToOrders==='+codeToOrders);
        System.debug('ordercodes==='+ordercodes);
        

        //Sort Codes
        List<Promotion__c> promosUpdateStatus = new List<Promotion__c>();
        List<Promotion__c> promosPersonal = new List<Promotion__c>();
        Set<id> customersIds = new Set<id>();
        for(Promotion__c promotion : [select id, Customer__c,Customer__r.PersonContactId,Customer__r.Contact__c,Customer__r.Personal_Promotion_Code__pc, Type__c, Status__c, Promotion_Code__c from Promotion__c WHERE Promotion_Code__c IN: ordercodes  AND Status__c = 'Active' AND (Type__c = 'Benefit' OR Type__c = 'Personal Code')]){ 
            if(promotion.Type__c == 'Benefit')
               promosUpdateStatus.add(promotion);
            if(promotion.Type__c == 'Personal Code' && promotion.Customer__c != null){
               promosPersonal.add(promotion);
               customersIds.add(promotion.Customer__c);
            }
            accIdToCode.put(promotion.Customer__c,promotion.Promotion_Code__c.trim().toLowerCase());
            promotionCodeToPromotion.put(promotion.Promotion_Code__c.trim().toLowerCase(),promotion);

        }
        System.debug('ordercodes==='+ordercodes);
        System.debug('promosUpdateStatus==='+promosUpdateStatus);
        System.debug('customersIds==='+customersIds);
        System.debug('promosPersonal==='+promosPersonal);
        System.debug('accIdToCode==='+ accIdToCode);
        System.debug('promotionCodeToPromotion==='+promotionCodeToPromotion);
        
        
        //1.update the promotion status if found
        List<Promotion__c> promosToUpdate = new List<Promotion__c>();
        if(ordercodes.size() > 0){
            for(Promotion__c prom : promosUpdateStatus){
                
                Promotion__c Promotion =  new Promotion__c(Id = prom.Id); 
                Promotion.Status__c = 'Redeemed';
                /*system.debug('promotion = ' + prom);
                system.debug('prom.Promotion_Code__c = ' + prom.Promotion_Code__c);
                system.debug('codeToOrders= ' + codeToOrders);
                system.debug('promotion code contains = ' + (codeToOrders.containsKey(prom.Promotion_Code__c.trim().toLowerCase())));                
                */
                Order ord = codeToOrders.get(prom.Promotion_Code__c.trim().toLowerCase());
                system.debug('ord = ' + ord);
                Promotion.Customer_Order__c = ord.Id;
                Promotion.Redeemed_Channel__c = ord.Order_Channel__c;
                Promotion.Redeemed_Date__c = system.today();
                Promotion.Redeemed_Owner__c = ord.CreatedById;
                promosToUpdate.add(Promotion);
            }
            update promosToUpdate;
            //update promosUpdateStatus;
        }


        //2.Find and connect an open benefit to our customers for each Order
        Integer benefitLimit = customersIds.size();
        List<Account> customersToUpdate = new List<Account>();
        //String benefitQuery = 'select id from Promotion__c WHERE Type__c = \'Benefit\' AND Status__c = \'Open\' Limit  ' + benefitLimit;
        //List<Promotion__c>  freeBenefits = new List<Promotion__c>([select id from Promotion__c WHERE Type__c = 'Benefit' AND Status__c = 'Open' Limit benefitLimit]);// LIMIT : promosPersonal.size()+1
        //List<Promotion__c>  freeBenefits = database.query(benefitQuery);
        List<Promotion__c>  benefitsToUpdate = new List<Promotion__c>();
        List<Promotion__c>  benefitsToInsert = new List<Promotion__c>(); 
        //Integer count = 0;
        //Integer freeBenefitsSize = freeBenefits.size(); 
        for(id customerId : customersIds){
                  String myCode = accIdToCode.get(customerId).trim().toLowerCase();
                   Order myOrder = codeToOrders.get(myCode);            
                    Promotion__c benefitUpd = new Promotion__c();
                     system.debug('myOrder =' + myOrder );   
                        if(myOrder != null){
                            benefitUpd.Referred_By__c= myOrder.AccountId; 
                            benefitUpd.Order__c = myOrder.id;
                            benefitUpd.Referred_Channel__c = myOrder.Order_Channel__c;
                            benefitUpd.Referred_Owner__c = myOrder.CreatedById;
                        }
                        benefitUpd.Referred_Date__c = system.today();
                        benefitUpd.Customer__c = customerId;
                        benefitUpd.Contact__c = promotionCodeToPromotion.get(myCode).Customer__r.PersonContactId; 
                        benefitUpd.Status__c = 'Open';
                        benefitsToInsert.add(benefitUpd);
                    /*if(count < freeBenefitsSize ){
                        Promotion__c benefitUpd = new Promotion__c(Id = freeBenefits[count].Id);
                        
                        if(myOrder != null){
                            benefitUpd.Referred_By__c= myOrder.AccountId; 
                            benefitUpd.Order__c = myOrder.id;
                            //freeBenefits[count].Referred_By__c = myOrder.AccountId;
                            //freeBenefits[count].Order__c = myOrder.id;
                        }
                        //freeBenefits[count].Customer__c = customerId;
                        //freeBenefits[count].Contact__c = promotionCodeToPromotion.get(myCode).Customer__r.Contact__c; 
                        //freeBenefits[count].Status__c = 'Active';
                        benefitUpd.Customer__c = customerId;
                        benefitUpd.Contact__c = promotionCodeToPromotion.get(myCode).Customer__r.PersonContactId; 
                        benefitUpd.Status__c = 'Active';
                        benefitsToUpdate.add(benefitUpd);
                        System.debug('freeBenefits[count]==='+freeBenefits[count]);
                        count++;
                    }else{
                        //pop msg missing promotion
                        Account acc = new Account(id = customerId, Customer_Error_Message__c= label.MGM_Promo_Not_Created);
                        if(myOrder != null){
                            acc.Customer_Error_Message__c= label.MGM_Promo_Not_Created + myOrder.Id;
                        }
                        customersToUpdate.add(acc);
                    }*/
                
            
        }
        insert benefitsToInsert;
        /*if(freeBenefits.size() > 0)
            update freeBenefits;*/
        //update benefitsToUpdate;    
        /*if(customersToUpdate.size() > 0)
            update customersToUpdate;*/
        uncheckCreatePromotionFlag();//SW-40034
    }

    private void uncheckCreatePromotionFlag() {
        List<Order> ordersToUpdate = new List<Order>();
        for(Order iteratedOrder:Orders) {
            if(iteratedOrder.Create_Promotion__c == true) {
                ordersToUpdate.add(new Order(Id = iteratedOrder.Id, Create_Promotion__c = false));
            }
        }
        if(!ordersToUpdate.isEmpty()) {
            update ordersToUpdate;
        }
    }
}