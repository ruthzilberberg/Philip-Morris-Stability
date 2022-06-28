public class SafeChargePaymentController  {


    public static final String ITEM_LIST = 'item_List';
	public static final String KEY = 'key';
	public static final String CHECK_SUM = 'checksum';
	public static final String NUM_OF_ITEMS = 'numberofitems';
	public static final String TOT_AMOUNT = 'total_amount';
	public static final String TIME_STAMP = 'time_stamp';
	public static final String ENCODE_FORMAT = 'UTF-8';
	public static final String ALG_NAME = 'SHA-256';
	public static final String DATE_FORMAT ='yyyy-MM-dd HH:mm:ss';
	
	public class FormAttribute{
	  @AuraEnabled
	  public String key { get; set; }
	  @AuraEnabled
	  public Object val { get; set; }

	  public FormAttribute(String key, Object val){
	    this.key = key;
		this.val = val;
	  }
	}

	public class OrderWrapper
	{

		@AuraEnabled
		public String endpoint { get; set; }
		@AuraEnabled
		public String frmMethod { get; set; }
		@AuraEnabled
		public Boolean openInIframe { get; set; }
		@AuraEnabled
		public String responseMessage { get; set; }
		@AuraEnabled
		public boolean isSuccess { get; set; }
		@AuraEnabled
		public Map<Integer, FormAttribute> attMapByOrder { get; set; }


		public OrderWrapper(Map<Integer, FormAttribute> attMapByOrder, String endpoint, String frmMethod, boolean openInIframe, boolean isSuccess, String responseMessage)
		{
			this(isSuccess,responseMessage);
			this.attMapByOrder = attMapByOrder;
			this.endpoint = endpoint;
			this.frmMethod = frmMethod;
			this.openInIframe = openInIframe;

		}

		public OrderWrapper(boolean isSuccess,String responseMessage)
		{
			this.isSuccess = isSuccess;
			this.responseMessage = responseMessage;
		}

	}
	private static ServiceCredential__c x_Settings;
	private static ServiceCredential__c PaymentSettings {
		get {
			if (x_Settings == null) { 
				x_Settings = [Select Endpoint__c, OpenInIframe__c, Key__c, AdditionalData__c,Password__c, FormMethod__c, Default_UserId__c From ServiceCredential__c where Name = 'SafeCharge'] [0];
			}
			return x_Settings;
		}
		set {
		}
	}


	
	
	@AuraEnabled
	public static OrderWrapper getOrderData(Id OrderId, String Method) {
		Order ord = [Select Id, Status, Payment_Method__c, RecordType.DeveloperName From Order where Id = :OrderId] [0];
		OrderWrapper ordWrapperToReturn;
	
		if (ord.Status != null && ord.Status.equalsIgnoreCase('Ready to process') && String.isNotBlank(ord.Payment_Method__c) && ord.Payment_Method__c.equalsIgnoreCase('Credit Card')) {
			ordWrapperToReturn = PerformAction(OrderId, 'isPay__c', ord.RecordType.DeveloperName); 
		}
		if(ordWrapperToReturn == null ){
			ordWrapperToReturn = new OrderWrapper(true,'');
		}
		return ordWrapperToReturn;
	}
	

	private static OrderWrapper PerformAction(Id OrderId, String Method, String RecordTypeName)
	{
		OrderWrapper orw;
		Boolean isSuccess = true;
		ServiceCredential__c settings = PaymentSettings;
		Map<Integer, FormAttribute> attMapByOrder = getAttMap(OrderId, Method);
		system.debug('Method = ' + Method);
		Order ord = [Select Payment_Method__c From Order where Id = :OrderId Limit 1] [0];
		if (String.isNotBlank(ord.Payment_Method__c) && ord.Payment_Method__c.equalsIgnoreCase('Credit Card')) {
			orw = new OrderWrapper(attMapByOrder,settings.Endpoint__c, settings.FormMethod__c, settings.OpenInIframe__c, isSuccess, null);
		}

		System.debug('orw = ' + orw);
		return orw;
	}

	public static Map<Integer, FormAttribute> getAttMap(Id OrderId, String Method)
	{
		Map<String, String> attMap = FieldMappingHandler.getAttributeMap(OrderId, 'SC_Order', Method);
		OrderLineItemsMapWarpper orderLineItemsWrapper = getAttributeMap_Children('OrderId', OrderId, 'SC_OrderLineItem', Method);
		Map<String, String> orderLineItemMap = orderLineItemsWrapper.attMap;
		String timeStamp = System.now().format(DATE_FORMAT).deleteWhitespace();
		attMap.put(TIME_STAMP,timeStamp);
		attMap.putAll(orderLineItemMap);
		Map<Integer, FormAttribute> resMap = buildOrderedMapAndCheckSum(attMap,PaymentSettings.Key__c);
		return resMap;

	}
	

	public static Map<Integer, FormAttribute> buildOrderedMapAndCheckSum(Map<String, String> attMap, String secretKey){
	  
	  Integer i=0;
	  Map<Integer,FormAttribute> attributesOrderMap = new Map<Integer,FormAttribute>();
	  List<String> attLst = new List<String>(attMap.keySet());
	  attLst.sort();
	 
	  List<String> checkSumLst = new List<String>{secretKey};
	  for(String att : attLst){
			String val = attMap.get(att);
			if(val != null && (val.startsWith('http') || att.startsWith('email'))) {
			  //dont encode
			}
			else{
			   val = String.isNotBlank(val) ? (String)EncodingUtil.urlEncode(val, ENCODE_FORMAT) : '';
			}
			attributesOrderMap.put(i,new FormAttribute(att,val));
			if(val != ''){
				checkSumLst.add(val);
			}
	       i++;
	  }

	  String checkSumVal =  getCheckSum(ALG_NAME,String.join(checkSumLst,''));
	  attributesOrderMap.put(i,new FormAttribute(CHECK_SUM,checkSumVal));
	  return attributesOrderMap;
	}

	public static string getCheckSum(String algorithmName,String checkSumVal){
	  Blob hmacData = Crypto.generateDigest(algorithmName, Blob.valueOf(checkSumVal));
	  return EncodingUtil.convertToHex(hmacData);
	}

	public class OrderLineItemsMapWarpper {
		public Map<String, String> attMap; //Object
		public String CheckSumListItem;
		public List<FormAttribute> ordeLineItemsByOrder;
	}
	public static OrderLineItemsMapWarpper getAttributeMap_Children(String parentObjRelationshipFld, Id parentObjId, String objMappingRecord, String requestTypeBoolCondition) {

		OrderLineItemsMapWarpper response = new OrderLineItemsMapWarpper();
		System.debug('requestTypeBoolCondition = ' + requestTypeBoolCondition);
		List<ObjectMapping__mdt> objMapping = FieldMappingHandler.getObjMappingRecords(objMappingRecord, requestTypeBoolCondition);
		System.debug('objMapping = ' + objMapping);

		Map<String, FieldMapping__mdt> apiFld_fm = new Map<String, FieldMapping__mdt> ();
		Map<String, String> additionalFieldsMapping = new Map<String, String> ();
		getFieldMappingData(objMapping[0],additionalFieldsMapping,apiFld_fm);
		List<sObject> orderLineItemList;
		if (apiFld_fm.size() > 0) {
			apiFld_fm.put(parentObjRelationshipFld, null);
		    String query = buildQuery(apiFld_fm.keySet(),objMapping[0].SourceObject__c, parentObjRelationshipFld + ' = \'' + parentObjId + '\'');
			orderLineItemList = database.query(query);
			response = handleOrderItemList(apiFld_fm,orderLineItemList,additionalFieldsMapping);
		}
		return response;
	}

    public static void getFieldMappingData(ObjectMapping__mdt objMapping, Map<String, String> additionalFieldsMapping,/*Map<String, FieldMapping__mdt> fldAttribute_fldMap*/Map<String, FieldMapping__mdt> apiFld_fm){

		for (FieldMapping__mdt m : objMapping.FieldsMapping__r) {

			if (String.isNotBlank(m.FieldApiName__c)) {
				apiFld_fm.put(m.FieldApiName__c, m);
			}
			else if (String.isNotBlank(m.ParentApiNameFieldPath__c)) {
				apiFld_fm.put(m.ParentApiNameFieldPath__c, m);
			}
			else if(String.isNotBlank(m.AdditionalValue1__c) && m.AdditionalValue1__c.containsIgnoreCase('index_num')){
			   additionalFieldsMapping.put('index_num',m.MappingName__c);
			}

		}
	
	}

	public static String buildQuery(Set<String> fields, String sObjectName , String condition){
		
			String query = 'Select ' + String.join(new List<String> (fields), ',') + ' From ' + sObjectName + ' where ' + condition;
			System.debug('query = ' + query);
			return query;
	}

	public static OrderLineItemsMapWarpper handleOrderItemList(Map<String, FieldMapping__mdt> apiFld_fm,List<sObject> orderLineItemList,Map<String, String> additionalFieldsMapping){
	
		OrderLineItemsMapWarpper response = new OrderLineItemsMapWarpper();
		Map<String, String> attName_attVal = new Map<String, String>();
		Integer index = 1;
		Decimal totalAmount = 0;
		Integer totalQuantity = 0;
		List<FormAttribute> ordeLineItemsByOrder = new List<FormAttribute>();
		ItemWrapper itw;
		Map<String, Object> fieldsToValue;
		for (sObject obj : orderLineItemList) {
			
			itw = handleOrderLineItem(index,obj,apiFld_fm,attName_attVal,ordeLineItemsByOrder);
			if(additionalFieldsMapping.containsKey('index_num')){
			  attName_attVal.put(additionalFieldsMapping.get('index_num') + '' + index,'' + index);
			}
			totalAmount += (itW.ItemAmount * itW.ItemQuantity);
			totalQuantity += itw.ItemQuantity;
			index++;
		}
		//attName_attVal.put(TOT_AMOUNT, '' + totalAmount);
		attName_attVal.put(NUM_OF_ITEMS, '' + orderLineItemList.size());

		response.attMap = attName_attVal;
		response.ordeLineItemsByOrder = ordeLineItemsByOrder;
		return response;
	
	}

	
	public static ItemWrapper handleOrderLineItem(Integer index,sObject orderLineItem,Map<String, FieldMapping__mdt> apiFld_fm,Map<String, String> attName_attVal,List<FormAttribute> ordeLineItemsByOrder){
	  
			Map<String, Object> fieldsToValue = orderLineItem.getPopulatedFieldsAsMap();
			ItemWrapper itW = new ItemWrapper();
			itW.Index = index;
			for (String fld : fieldsToValue.keySet()) {
				
				  if (apiFld_fm.containsKey(fld) && apiFld_fm.get(fld) != null && fieldsToValue.get(fld) != null && fieldsToValue.get(fld) != '') {

					String mappingName = apiFld_fm.get(fld).MappingName__c + '' + index;
					Object val = fieldsToValue.get(fld);
					Object convertedVal = val;
					if (mappingName.containsIgnoreCase('name')) {
						itW.ItemName = ('' + val).trim();//.deleteWhitespace();
						//convertedVal = itW.ItemName;
					} else if (mappingName.containsIgnoreCase('amount')) {
						itW.ItemAmount = Decimal.valueOf('' + val);
						convertedVal = itW.ItemAmount;
					} else if (mappingName.containsIgnoreCase('quantity')) {
						itW.ItemQuantity = Integer.valueOf('' + val);
						convertedVal = itW.ItemQuantity;
					}
					attName_attVal.put(mappingName, '' + convertedVal);
					ordeLineItemsByOrder.add(new FormAttribute(mappingName,'' + convertedVal));
				}

			}
			return itW;
	
	}
	
	
	
	public class ItemWrapper {

		public String ItemName;
		public Decimal ItemAmount;
		public Integer ItemQuantity;
		public Integer Index;

		/*public string getCheckSumStr() {
			return '' + this.ItemName + '' + this.ItemAmount + '' + this.ItemQuantity;
		}*/

	}

	
}