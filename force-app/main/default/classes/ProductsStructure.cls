/*-----------
Input JSON:
-----------



"products[]"  - array of options to select one or more sub products (color/flawors).

selectMethod:"Quantity"  - Users select's a positive quantity. All products are with quantity 0 as default.
                            Product with quantity >0 should be marked also as selected=true.

selectMethod:"Selection" - Each line item can be selected or not, meaning the quantity is eather 0 or 1. The bundle product must be selected=true to be passed to the result JSON.

selectMethod:"all"       - No selection/de-selection allowed, all products included with the default provided quantity.

selected: <true> | <false>  Identify selected product. 
                            product.selected = true , must also be with quantity >0
                            productGroup.selected = true, must have sub product.selected=true
                            bundleProduct.selected = true, meaning that first level sub products/groups are *all* selected
                            
viewType: <List> | <Tabs>   Tabs: Group products are showen as Tabs, and the options as list of products.
                            List: Products showen as list of products.
                            
color - valid css attribute value 
*/

public class ProductsStructure{


public class RootObject
{   
    public string OrderType { get; set; }
    public List<FssOwner> orderFssOwner {get;set;}
    public String orderPayMethod {get;set;}
    public string orderPromotionCode {get;set;}
    public boolean isFssRequired { get; set; }
    public List<FssOwner> FssOwners { get; set; }
    public List<Category> categories { get; set; }
    public string userRoleName {get;set;}
    
    
}

public class Category
{
    public string name { get; set; }
    public string selectMethod { get; set; }
    public string viewType { get; set; }
    public List<Product> products { get; set; }
    public List<LineItem> lineItems { get; set; }
    public List<BundleLineItem> bundleLineItems { get; set; }
    
}


public virtual class Product
{
    public string type { get; set; }
    public string name { get; set; }
    public string color { get; set; }
    public string productId { get; set; }
    public string Product_type_Id { get; set; }  
    public Double quantity { get; set; }
    public boolean isSelect { get; set; }
    public string DCS_Product_Id { get; set; }
    public string DCS_Chain_ID {get; set;}
    public string chain_Id {get; set;}
    public boolean isDevice {get; set;}
}

public virtual  class LineItem extends Product
{ 
    public string groupAttribute1 { get; set; }
    public List<Product> products { get; set; }
}

public class BundleLineItem extends LineItem
{
    public string productBundleId { get; set; }
    public boolean selected { get; set; }
    public string selectMethod { get; set; }
    public List<LineItem> lineItems { get; set; }
}

public virtual class FssOWner
{
    public string value { get; set; }
    public string label  { get; set; }
    
    public FssOwner(string value,string label){
      this.value= value;
      this.label = label;
    }
    public FssOwner(){}
}


public static string roleField=null;

private static UserRole x_usrRole;

public static UserRole getUsrRole(String role_id){
    if(x_usrRole == null && String.isNotBlank(role_id)){
        x_usrRole = [Select Id,DeveloperName From UserRole where Id=:role_id][0];
    }
    return x_usrRole;
}

public static boolean getIsFssRequired(String role_id){
   if(String.isBlank(role_id)) return false;
   String role = getUsrRole(role_id).DeveloperName;
   return (String.isNotBlank(role) && role.equalsIgnoreCase('fss'));
}

public static String getAvailableFor(String role_id){
 
   
    if(roleField == null){
        if(String.isNotBlank(role_id)){
            String usrRole =  getUsrRole(role_id).DeveloperName;
                ProductsScreenRoleFilter__mdt productsRoleFilter = [Select DeveloperName,Product_Api_Field__c From ProductsScreenRoleFilter__mdt 
                where DeveloperName =: usrRole Limit 1][0];
            roleField = productsRoleFilter.Product_Api_Field__c;
        }
        if(roleField == null) roleField='';
    }
    return roleField;

    
}



public static List<FssOwner> getFssOwner(List<FssOwner> orderFssOwner){

    List<String> condition=new List<String>{'FSS','Pop Up Shop Coach'};
    

    List<Contact> contacts= [SELECT Id,Name FROM Contact WHERE Employee_Location__c IN:condition];
    List<FssOwner> fssOwner_list=new List<FssOwner>();
    if(orderFssOwner != null && orderFssOwner.size()>0){
       fssOwner_list.add(orderFssOwner[0]);
       fssOwner_list.add(new FssOwner(null,''));
    }else{
      
      fssOwner_list.add(new FssOwner(null,''));
    }
    for (Contact con : contacts) {

        FssOwner fss= new FssOwner();
        fss.value=con.Id;
        fss.label=con.Name;
        fssOwner_list.add(fss);
        
    }

    return fssOwner_list;
}

private static Order x_Order;
public static Order getOrder(String orderId){
  if(x_Order == null){
     x_Order =  [SELECT Id,Type,FSS_Owner__c,FSS_Owner__r.Name,Payment_Method__c,Promotion_code__c FROM Order Where Id=:orderId];
  }
  return x_Order;  
}

public static String getOrderType(String orderId){


    Order ord= getOrder(orderId);//[SELECT Id,Type,FSS_Owner__c,FSS_Owner__r.Name,Payment_Method__c,Promotion_code__c FROM Order Where Id=:orderId];
    String orderType=ord.Type;
    return orderType;

    
}



public static Category buildHeets(List<Product> heets){
 
  //loop SOQL FOR PRODUCTS
  //name , productId,color,quantity,select

    System.debug('heets----->'+JSON.serialize(heets));
      Category local_heets= new  Category();
      local_heets.name='Heets';
      local_heets.selectMethod='Quantity';
      local_heets.viewType='List';
      local_heets.products=heets;

       System.debug('local_heets.products----->'+local_heets.products);

return local_heets;
  
}
public static Category buildKit(List<Product> kits){
 
  //loop SOQL FOR PRODUCTS
  //name , productId,color,quantity,select
      Category local_kits= new  Category();
      local_kits.name='Kit';
      local_kits.selectMethod='Quantity';
      local_kits.viewType='List';
      local_kits.products=kits;
      System.debug('local_kits.products----->'+local_kits.products);

return local_kits;
  
}

 public static Category buildAccessoriesLineItem(Map<String,List<Product>> lineItems_map ){

    Category local_accessories= new  Category();
    List<LineItem> lineItems= new  List<LineItem>();

    for (String name : lineItems_map.keySet()) {

            LineItem lnItem=new LineItem();
            lnItem.name=name;
            lnItem.type='productGroup';
            lnItem.isSelect=false;
            lnItem.products=lineItems_map.get(name);

            lineItems.add(lnItem);
            
            System.debug('lnItem----->'+JSON.serialize(lnItem));
    }

    //fill the category obj
    local_accessories.name='Accessories';
    local_accessories.selectMethod='Quantity';
    local_accessories.viewType='Tabs';
    local_accessories.lineItems=lineItems;

    System.debug('local_accessories----->'+JSON.serialize(local_accessories));


    return local_accessories;


 }


public static Category buildChains(List<Product> chains){

    Category local_chains= new Category();
    List<LineItem> lnItems_list= new List<LineItem>();
    List<BundleLineItem> bundles = new List<BundleLineItem>();
    Map<Id,List<LineItem>> chain_lineitems = new Map<Id,List<LineItem>>();

    System.debug('chains----->'+chains);

    //create set for comf retrive in SOQL
    Set<Id> chains_ids= new Set<Id>();

    for (Product p : chains) {
          chains_ids.add(p.productId);
    }

    System.debug('chains_ids Set<Id>----->'+chains_ids);

    Map<Id,Product> chainId_Chain= new Map<Id,Product>();
    Map<Id,List<BundleLineItem>> bb= new Map<Id,List<BundleLineItem>>(); 

    for (Product p : chains) {
        chainId_Chain.put(p.productId, p);
    }
   

    


 String uRoleId = UserInfo.getUserRoleId();
 String availableFor= getAvailableFor(uRoleId);
 
  String availableForCondition=' ';
  if(String.isNotBlank(availableFor)) availableForCondition  = ' AND '+ availableFor + ' = true ';


 String chain_product_query='SELECT Id,Ordering__c,Chain__c,Name,Display_Name__c,Repeat_Selection__c,Type__c,Quantity__c,Selection_Attribute__c, (  SELECT id,Product__r.DCS_Product_Id__c,Chain__r.DCS_Chain_ID__c,Chain__c,Name,Color__c,Product__c, Display_Name__c,Ordering__c ,Price__c,Product__r.Device_Product__c FROM Chains_Products_Variants__r WHERE Active__c=true '+ availableForCondition +'  ORDER BY Ordering__c ASC, Display_Name__c ASC )  FROM Chain_Products__c WHERE Chain__c IN:chains_ids AND Active__c=true order by Ordering__c ASC';
 

 //EXECUTE QUERY///
  List<Chain_Products__c> chain_product_list  = database.query(chain_product_query);
/////////////////

    System.debug('chain_product_list----->'+chain_product_list);

    Map<Id,List<Product>> chainProductID_Variants= new Map<Id,List<Product>>(); 

    // create Map for level 2 ids(key) and there childs(Level 3)
     for (Chain_Products__c cp : chain_product_list) {

         LineItem lnItem= new LineItem();
         BundleLineItem bundle= new BundleLineItem();
        List<Product> prod_list= new List<Product>();

         for(Chain_Product_Variant__c variant:cp.Chains_Products_Variants__r){             
            System.debug('variant----->'+variant);
            //System.debug('variant DCS_ID----->'+variant.Product__r.DCS_Id__c);
            Product prod= new Product();
            prod.productId=variant.Id;

            //prod.name=variant.Name;

            if(!String.isBlank(variant.Display_Name__c)){
                   prod.name=variant.Display_Name__c;
                }else {
                     prod.name=variant.Name;
                }

            prod.DCS_Product_Id=variant.Product__r.DCS_Product_Id__c;
            prod.DCS_Chain_ID =variant.Chain__r.DCS_Chain_ID__c;
            prod.chain_Id=variant.Chain__c; 
            prod.Product_type_Id=variant.Product__c;
            prod.color=variant.Color__c;
            prod.isDevice=variant.Product__r.Device_Product__c;

            prod.isSelect=false;
           // prod.color=chainId_Chain.get(variant.Chain__c).Color__c;

            System.debug('prod variant before insert to list----->'+prod);
            prod_list.add(prod);//add variant     
         }

         lnItem.productId=cp.Id;  

       //  lnItem.name=cp.Name; 
           if(!String.isBlank(cp.Display_Name__c)){
                   lnItem.name=cp.Display_Name__c;
                }else {
                     lnItem.name=cp.Name;
                } 
        

         lnItem.type=cp.Type__c;  
         lnItem.quantity=cp.Quantity__c;  
         lnItem.groupAttribute1=cp.Selection_Attribute__c;  
         lnItem.products=prod_list;

         //if a line item need to create morw than once like Heets 1,Heets2 ....   
         if(cp.Repeat_Selection__c>1){

             Integer size=cp.Repeat_Selection__c.intValue()+1;
             for (Integer i = 1; i < size; i++) {
                    LineItem lnItem_duplicate = new lineItem();       
                    lnItem_duplicate=lnItem.clone();
                    String name=lnItem.name+' '+i;
                    lnItem_duplicate.name=name;
                    lnItems_list.add(lnItem_duplicate);

                     
                Boolean isChainExist=chain_lineitems.containsKey(cp.Chain__c);

                if(isChainExist){
                    List<LineItem> l_list=chain_lineitems.get(cp.Chain__c);
                    l_list.add(lnItem_duplicate);
                    chain_lineitems.put(cp.Chain__c,l_list);

                }else {
                    List<LineItem> l_list=new List<LineItem>();
                    l_list.add(lnItem_duplicate);
                    chain_lineitems.put(cp.Chain__c,l_list);
                }

                 
             }

         }
         else 
         {
             lnItems_list.add(lnItem);//  
              //classifay map for each lineItem object by its chain parent ()  
               
                Boolean isChainExist=chain_lineitems.containsKey(cp.Chain__c);

                if(isChainExist){
                    List<LineItem> l_list=chain_lineitems.get(cp.Chain__c);
                    l_list.add(lnItem);
                    chain_lineitems.put(cp.Chain__c,l_list);

                }else {
                    List<LineItem> l_list=new List<LineItem>();
                    l_list.add(lnItem);
                    chain_lineitems.put(cp.Chain__c,l_list);
                }

         }

       
               
     }           

    //get product_Chains

    System.debug('lnItems_list----->'+JSON.serialize(lnItems_list));

    List<BundleLineItem> bundle_list= new List<BundleLineItem>();

     for (Id id : chain_lineitems.keySet()) {

            BundleLineItem bundle =new BundleLineItem();
            bundle.productBundleId=id;
            bundle.selected=false;
            bundle.selectMethod='all';
            bundle.lineItems=chain_lineitems.get(id);
            
            bundle.name=chainId_Chain.get(Id).name;

            bundle_list.add(bundle);
   

     }

    local_chains.bundleLineItems=bundle_list;
    local_chains.name='Introduction Kit';
    local_chains.selectMethod='Selection';
    System.debug('local_chains----->'+JSON.serialize(local_chains));
    return local_chains;

}


@AuraEnabled(cacheable=true)
public static String getJson(String orderId){

String productChannelField;

    
    

    RootObject root= new RootObject();
    Order ord = getOrder(orderId);
    root.OrderType=getOrderType(orderId);
    root.orderPayMethod = ord.Payment_Method__c; 
    
    if(ord.FSS_Owner__c != null){
         FssOwner fssOwn = new FssOwner();
         fssOwn.value = ord.FSS_Owner__c;
         fssOwn.label = ord.FSS_Owner__r.Name;
         List<FssOwner> fssOwner_list=new List<FssOwner>{fssOwn};
         root.orderFssOwner = fssOwner_list; 
    }
    root.orderPromotionCode = ord.Promotion_code__c;
        
    boolean isRentingOrder = String.isNotBlank(root.OrderType) && root.OrderType.equalsIgnoreCase('Renting Order');
    boolean isCompleteRentingOrder = String.isNotBlank(root.OrderType) && root.OrderType.equalsIgnoreCase('Complete Renting Order');
    List<Category> categories_list= new List<Category>();
    // 1  - get all products
    Category heets= new  Category();
    Category kit= new  Category();
    Category accessories= new  Category();
    Category introductionKit= new  Category();

    List<Product>  products_heets= new List<Product>();      
    List<Product>  products_kit= new List<Product>();      
    List<lineItem>  accessoriesLineItem_list= new List<lineItem>();
    List<Product>  chains= new List<Product>();          

    Map<String,List<Product>> lineItems_map= new Map<String,List<Product>>();  


    // 2  -  classification by product.screenType to an arrays
    List<String> screenType = new List<String>{'Kits','Chains','Accessories','Heets'};
    //List<String> accessoriesScreenType = new List<String>{'Cap','Door','Sleeve','USB-C','Cleanig Stick','Cleanig Tool','Charger','Holder','Case','Tray','Single line up'};
    List<String> accessoriesScreenType = new List<String>();
    List<ordering_accessories__mdt> screenTypeCmdLst = [Select MasterLabel,Order__c From ordering_accessories__mdt 
                                                        where Active__c = true Order By Order__c ASC NULLS LAST];
    for(ordering_accessories__mdt rec : screenTypeCmdLst){
        accessoriesScreenType.add(rec.MasterLabel);    
    }
    
    String uRoleId = UserInfo.getUserRoleId();
    root.isFssRequired = getIsFssRequired(uRoleId);
    String availableFor= getAvailableFor(uRoleId);
    if(String.isNotBlank(uRoleId)){
        root.userRoleName = getUsrRole(uRoleId).DeveloperName;
    }

    String availableForCondition=' ';
    if(String.isNotBlank(availableFor)) availableForCondition  = ' AND '+ availableFor + ' = true ';

    String rentingOrderCondition= '';
    if(isRentingOrder || isCompleteRentingOrder ){
       rentingOrderCondition += ' And isRenting__c = true';
    }
    else{
      rentingOrderCondition += ' And isRenting__c = false';
    }
    //GENERAL QUERY////
    String productsQuery = 'Select Id,DCS_Chain_ID__c,Product_ID__c,Name,Display_Name__c,Product_Screen_Type__c,Product_Type__c,Quantity__c,Color__c,Device_Product__c From  Product2 where IsActive =true '+availableForCondition+ ' ' + rentingOrderCondition + ' ORDER BY Name';
    //////////////////

    //QUERY CONDITION////
   
    //if(String.isNotBlank(availableFor)) productsQuery  += ' And ' + availableFor + ' = true';
    if(String.isNotBlank(productChannelField)) productsQuery  += ' And ' + productChannelField + ' = true';
    ////////////////////

  //productsQuery += ' And Product_Screen_Type__c in : productsScreenType Order By Product_Screen_Type__c';

    System.debug('QUERY>>> '+productsQuery);

    ///EXECUTE QUERY/////
    List<Product2> products  = database.query(productsQuery);
     ///EXECUTE QUERY/////

    //system.debug('prods = ' + products);
    System.debug('prods = ----->'+JSON.serialize(products));
    //  3  -  
    
        //if the product is a heets product build is Line items and after that 
        //add it to the heets object 

         //build the lineItem object (one of the )
        //first classification of product
        for(Product2 prd : products){

                ///////////////////////
                ///classify Heets
                /////////////////////
            system.debug('isRentingOrder = ' + isRentingOrder );
            system.debug('isCompleteRentingOrder = ' + isCompleteRentingOrder);
            system.debug('prd.Product_Screen_Type__c = ' + prd.Product_Screen_Type__c);
            system.debug('isHeets = ' + (prd.Product_Screen_Type__c=='Heets'));
            system.debug('isHeets = ' + (prd.Product_Screen_Type__c=='Heets'));
            system.debug('isKit = ' + (prd.Product_Screen_Type__c=='Kit'));
            system.debug('accessoriesScreenType = ' + accessoriesScreenType);
            system.debug(' is accessories type = ' + (accessoriesScreenType.contains(prd.Product_Screen_Type__c)));
            if(!isRentingOrder && !isCompleteRentingOrder && prd.Product_Screen_Type__c=='Heets'){    

                //create the products field(LineItem) of the categories object(heets)    
                Product prod = new Product();
                prod.type=prd.Product_Screen_Type__c;

                if(!String.isBlank(prd.Display_Name__c)){
                   prod.name=prd.Display_Name__c;
                }else {
                     prod.name=prd.Name;
                }
               

                prod.productId=prd.Id;
                prod.color=prd.Color__c;
                prod.quantity=prd.Quantity__c;
                prod.DCS_Product_Id=prd.DCS_Chain_ID__c;
                prod.isSelect=false;
                prod.isDevice=prd.Device_Product__c;

                // add to list
                products_heets.add(prod);

            }

            ///////////////////////
            ///classify kit
            /////////////////////

            else if(!isRentingOrder && prd.Product_Screen_Type__c=='Kit'){    

                //create the products field(LineItem) of the categories object(heets)    
                Product prod = new Product();
                prod.type=prd.Product_Screen_Type__c;

                 if(!String.isBlank(prd.Display_Name__c)){
                   prod.name=prd.Display_Name__c;
                }else {
                     prod.name=prd.Name;
                }

                prod.productId=prd.Id;
                prod.color=prd.Color__c;
                prod.quantity=prd.Quantity__c;
                prod.DCS_Product_Id=prd.DCS_Chain_ID__c;
                prod.isSelect=false;
                prod.isDevice=prd.Device_Product__c;

                // add to list
                products_kit.add(prod);

            }

            ///////////////////////
            ///classify Accessories
            /////////////////////
            else if(!isRentingOrder && !isCompleteRentingOrder && accessoriesScreenType.contains(prd.Product_Screen_Type__c)){


                LineItem lnItem= new LineItem();
                Product prod = new Product();

                prod.type=prd.Product_Screen_Type__c;

                if(!String.isBlank(prd.Display_Name__c)){
                   prod.name=prd.Display_Name__c;
                }else {
                     prod.name=prd.Name;
                }

                prod.productId=prd.Id;
                prod.color=prd.Color__c;
                prod.quantity=prd.Quantity__c;
                prod.DCS_Product_Id=prd.DCS_Chain_ID__c;
                prod.isSelect=false;
                prod.isDevice=prd.Device_Product__c;

                //check if a type of accessories lineItem exist like 'Cap ,Sleeve etc...'
                Boolean accssesories_tab=lineItems_map.containsKey(prd.Product_Screen_Type__c);
                
                //if allready exist add it to the match key (list)
                //else create a new map key
                if(accssesories_tab){
                    List<Product> product_list=lineItems_map.get(prd.Product_Screen_Type__c);
                    product_list.add(prod);
                    lineItems_map.put(prd.Product_Screen_Type__c,product_list);
                }
                else{
                    List<Product> product_list=new List<Product>();
                    product_list.add(prod);
                    lineItems_map.put(prd.Product_Screen_Type__c,product_list);
                }

                //create the products field(LineItem) of the categories object(heets)    
            }


            ///////////////////////
            ///classify Chains
            /////////////////////

            else if(!isCompleteRentingOrder && prd.Product_Screen_Type__c=='Chain'){

                Product prod = new Product();
                prod.productId=prd.Id;

               if(!String.isBlank(prd.Display_Name__c)){
                   prod.name=prd.Display_Name__c;
                }else {
                     prod.name=prd.Name;
                }

                prod.color=prd.Color__c;
                //prod.DCS_Product_Id=prd.DCS_Chain_ID__c;
                chains.add(prod);

            }



    } // product for loop end



       



         //build the heets with buildHeets func


        System.debug('lineItems_map----->'+lineItems_map);
        System.debug('lineItems_map----->'+JSON.serialize(lineItems_map));
         System.debug('products_heets----->'+products_heets);
         heets=buildHeets(products_heets);
         System.debug('heets After build----->'+heets);
         System.debug('====> heets serialaize: ' + JSON.serialize(heets));

        //build the kit with buildKit func
         kit=buildKit(products_kit);
         System.debug('kit After build----->'+kit);
         System.debug('====> kit serialaize: ' + JSON.serialize(kit));


         //build Accessories
         accessories=buildAccessoriesLineItem(lineItems_map);

         //build introductionKit
        introductionKit= buildChains(chains);
         /////////////////////////////////////////////////
         //After build each Category build RootObject////
         ///////////////////////////////////////////////


        categories_list.add(heets);
        categories_list.add(kit);
        categories_list.add(accessories);
        categories_list.add(introductionKit);
        root.categories=categories_list;

        //FSS OWNER 
        List<FssOwner> fssOwners=getFssOwner(root.orderFssOwner);
        System.debug('fssOwners----->'+fssOwners);
        root.FssOwners=fssOwners;
        //root.OrderType=getOrderType('8011x000000vVs5AAE');

        // categories.categories.add(kit);
        System.debug('root----->'+JSON.serialize(root));

        return JSON.serialize(root);

 }

}