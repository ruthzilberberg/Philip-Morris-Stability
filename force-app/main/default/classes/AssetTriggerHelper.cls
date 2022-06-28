/****************************************************************************************
Name              : AccountTriggerHandler
Description       :
Revision History  : 
Coverage          : 83%
Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
----------------------------------------------------------------------------------------
1. Sam Boukhobza               16/01/2019            Ella Bernachik          [SW-32039]
2. Ori                         07/08/2019            Ella Bernachik          [SW-34363]
3. Dor Malka                   09/06/2020            Aya  Toledano           [SW-38009]
4.Nevo Harari                  30/06/2020            Harel Hout              [SW-38292]
5.Nevo Harari                  24/03/2021            Harel Hout              [SW-42132]

----------------------------------------------------------------------------------------*/
public class AssetTriggerHelper {

    public void updateDeviceCounts(List<Asset> assetList) {

        Set<Id> customersIds = new Set<Id>();
        for(Asset ass: assetList){
            if( ass.AccountId != null && ass.Product2Id != null) {   // product usage flag is true
                customersIds.add(ass.AccountId);
            }
        }
        List<Account> accsToUpdate = SharedCustomersDevices.updateDeviceCounts(customersIds);
        System.debug('accsToUpdate==>'+accsToUpdate);
        if(accsToUpdate.size() > 0) update accsToUpdate;
    }



    public void updateProduct(List<Asset> assetList,Map<Id,Asset> oldMapAsset){

        Set<String> idToUpdate = new Set<String>();//Set<ProductCode>
        Set<String> assetNames = new Set<String>();//Set<AssetName>
		
        List<Integer> validAssetIndxes = new List<Integer>();

        List<Asset> reduced_assetList=assetList;
        Map<Id,Asset> assetMap= new Map<Id,Asset>(); //assetList

        Integer i=0;
        for (Asset asset: assetList){
			//SW-42132
			string originProductCode = asset.Origin_Product_Code__c != null? asset.Origin_Product_Code__c.substringBefore('.'):asset.Origin_Product_Code__c;
            if(Trigger.isUpdate) {
                
				if (asset.Origin_Product_Code__c != oldMapAsset.get(asset.Id).Origin_Product_Code__c && asset.Origin_Product_Code__c != null) {
                    idToUpdate.add(originProductCode);
                    validAssetIndxes.add(i);
                    System.debug('IN ASSET UPDATE');
                }
            }else if( asset.Product2Id == null && asset.Origin_Product_Code__c != null){
                idToUpdate.add(originProductCode);
                 validAssetIndxes.add(i);
                 System.debug('IN ASSET INSERT');
            }
            i++;

        }

        Map<String,Id> prdMap = new Map<String,Id>();
        List<Asset> checkAgainAssets = new List<Asset> ();
        //if 'idToUpdate'==null query not valid
        if(!idToUpdate.isEmpty()){        

          //for(Product2 prd: [select id,ProductCode from Product2 WHERE ProductCode IN: idToUpdate]){
            for(Product2 prd: [select id,Product_Code_Formula__c from Product2 WHERE Product_Code_Formula__c IN: idToUpdate]){
                prdMap.put(prd.Product_Code_Formula__c, prd.Id);

            }
            
            //for(Integer i=0;i<reduced_assetList.size();i++){
             for(i=0; i<validAssetIndxes.size(); i++){
               
			    integer ix = validAssetIndxes[i]; //sw-38247
				string originProductCode = assetList[ix].Origin_Product_Code__c.substringBefore('.');
                if( (assetList[ix].Product2Id == null) && prdMap.containsKey(originProductCode) ){ 
				    System.debug('NO FOUND SEC TIME TO'); 
                    assetList[ix].Product2Id = prdMap.get(originProductCode);  
                    System.debug('FOUND===='+assetList[ix].Name);
                    //validAssetIndxes.remove(i);     
                }
                else{
                    //if in prdMap also no found match-->collect names for 3rd round of search(only Root Assets)
                    if(assetList[ix].Id==assetList[ix].RootAssetId){ 
                       // assetNames.add(assetList[ix].Name);
						//checkAgainAssets.add(assetList[ix]);
						System.debug('NO FOUND===>'+assetList[ix].Name);  
						 assetList[ix].Product_Error__c='No matching Product found';      
                    }
                }
            }
       }
        /*  
        System.debug('assetNames:'+assetNames);

        if(!assetNames.isEmpty() && !validAssetIndxes.isEmpty()){

            Map<String,Id> AssetName_Product2Id_map= new Map<String,Id>();

            //when add to query 'group by' the result are of 'AggregateResult' type.
            for(AggregateResult obj: [select Name,Product2Id from Asset where Name IN:assetNames and Product2Id != null group by Name,Product2Id]){
                String assetName=(String)obj.get('Name');
                Id AssetProduct2Id=(Id)obj.get('Product2Id');
                AssetName_Product2Id_map.put(assetName,AssetProduct2Id);
				System.debug('assetName:'+assetName);
				System.debug('AssetProduct2Id:'+AssetProduct2Id);
            }

             // runnig again all over asset and try to Placement macth result.    
			   for(Asset myAss : checkAgainAssets){//sw-38247
				   if( myAss.Product2Id == null && AssetName_Product2Id_map.containsKey(myAss.Name) ){
					   myAss.Product2Id=AssetName_Product2Id_map.get(myAss.Name);
				   }else{
					 myAss.Product_Error__c='No matching Product found';
				   }
			   }  
           }*/
        }

       //SW-38292
		public void populate_Origin_Product_Code(List<Asset> assetList,Map<Id,Asset> oldMapAsset){
			date past = Date.newInstance(2019,1,14);
			date jan19 = Date.newInstance(2019,1,15); 
			date dec19 = Date.newInstance(2019,12,24); 
			date future = Date.newInstance(2019,12,25);  

			 for (Asset myass: assetList){
			     if(myass.Integration_Error__c != null){
					 if(myass.PurchaseDate != null && myass.Integration_Error__c.containsIgnoreCase('400:INVALID_CODENTIFYID - Invalid Codentify ID')){
				
						if ((Trigger.isInsert )  || (oldMapAsset != null && myass.Integration_Error__c != oldMapAsset.get(myass.Id).Integration_Error__c ) ){
							if( myass.PurchaseDate <= past ) 	myass.Origin_Product_Code__c = 'DK000273.00';
							if( myass.PurchaseDate >= jan19 &&  myass.PurchaseDate <= dec19) 	myass.Origin_Product_Code__c = 'DK000544.00';
							if( myass.PurchaseDate >= future ) 	myass.Origin_Product_Code__c = 'DK001082.01';//chemged from DK001082.00 SW-41124 
						}
					 }
				 } 
								 
			 }
		}
    }