/**
* @author Daniël Loriaux - 7dots <daniel.loriaux@7dots.eu>
* @date 2017
*
* @description Bridge between the Service provided by CM Telecom and Salesforce. All methods here are available to be implementen in any Salesforce interface.
*/
global without sharing class CMTelecomAPIConsumer {

	// Api constants
	private static final String API_SEND_MESSAGE = 'https://gw.cmtelecom.com/v1.0/message';

	// HTTP codes
	global static final Integer ERROR_CODE_OK = 0;
  global static final Integer STATUS_OK = 200;
	global static final Integer STATUS_BAD_REQUEST = 400;
  global static final Integer STATUS_METHOD_NOT_ALLOWED = 405;
  global static final Integer STATUS_INTERNAL_SERVER_ERROR = 500;

	private static Data getConsumerData() {
		CM_SMS_Setup__c customSettingCM = CM_SMS_Setup__c.getInstance();
		String token = customSettingCM.Product_Token__c;
		if(token == null) {
			return new Data('');
		}

		return new Data(token);
	}

	private static String mogrifyJSON(String data) {

	    // Regex to match the start of the line and the key
	    // surrounded by quotes and ending with a colon
		String regexFormat = '"{0}":';

	    // A map of existing key to replacement key
	    Map<String, String> replacements = new Map<String, String> {'fromSender' => 'from','numberReceiver' => 'number'};

	    // Iterate over all the keys we want to replace
	    for (String key : replacements.keySet()) {

			// Generate our regex and replacement values
	        String regex = String.format(regexFormat,new List<String> {key});
	        String replacement = String.format(regexFormat,new List<String> {replacements.get(key)});

	        // Find all and replace
	        data = data.replaceAll(regex, replacement);
	    }

	    return data;
	}

  private static Response sendRequest(String url, CMTelecomAPIConsumer.Data data){

		// Convert the JSON to the expected data
		String acceptedBodyJSON = mogrifyJSON(JSON.serialize(data, true));

		// Create the http for sending api calls
		Http http = new Http();

		// build the request
		HttpRequest req = new HttpRequest();
		req.setMethod('POST');
		req.setHeader('Content-Type', 'application/json');
		req.setEndpoint(url.toLowerCase());
		req.setBody(acceptedBodyJSON);

		// get the response
		HttpResponse res = http.send(req);
		String outputBody = res.getBody();

		// Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		// String[] toAddresses = new String[] {'daniel.loriaux@7dots.eu'};
		// mail.setToAddresses(toAddresses);
		// mail.setReplyTo('daniel.loriaux@7dots.eu');
		// mail.setSenderDisplayName('Daniel');
		// mail.setSubject('SEND');
		// mail.setBccSender(false);
		// mail.setUseSignature(false);
		// mail.setPlainTextBody(outputBody);
		// Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

		// Create the custom response
		Response r = (Response)JSON.deserialize(outputBody, Response.class);
		r.statusCode = res.getStatusCode();
		r.inputData = data;

		// Return the response
		return r;
    }

	/**
    * @description Prepare a message send, returning all the needed content in a string. Useful for @future methods that only accept primitive types.
	* @param sender The phone number that sends the message.
	* @param receiver The phone number that receives the message. Use multiple numbers separated by a comma.
	* @param message The message to be send from the sender to receiver.
	* @param origin The source the message has been send from.
    * @return String The Data serialized string object.
    */
	global static String prepareMessage(String sender, String receiver, String message, String origin) {
		return prepareMessage(sender, receiver, message, origin, '');
	}

	/**
    * @description Prepare a message send, returning all the needed content in a string. Useful for @future methods that only accept primitive types.
	* @param sender The phone number that sends the message.
	* @param receiver The phone number that receives the message. Use multiple numbers separated by a comma.
	* @param message The message to be send from the sender to receiver.
	* @param origin The source the message has been send from.
	* @param reference The reference bound to the message, optional for generating events.
    * @return String The Data serialized string object.
    */
	global static String prepareMessage(String sender, String receiver, String message, String origin, String reference) {
		List<DataMessage> messageList = new List<DataMessage>();
		for(String r : receiver.split(',')){
			messageList.add(new DataMessage(sender, r, message, origin, reference));
		}
		return prepareMessages(messageList);
	}

	/**
    * @description Prepare a message send, returning all the needed content in a string. Useful for @future methods that only accept primitive types.
	* @param message The message object to send.
	* @return String The Data serialized string object.
    */
	global static String prepareMessage(DataMessage message) {
		return prepareMessages(new List<DataMessage>{message});
	}

	/**
    * @description Prepare a batch of messages to send, returning all the needed content in a string. Useful for @future methods that only accept primitive types.
	* @param messages The list of message objects to send.
	* @return String The Data serialized string object.
    */
	global static String prepareMessages(List<DataMessage> messages) {

		// Create the data
		Data data = getConsumerData();
		data.addMessages(messages);

		//	Serialize the data
		// return mogrifyJSON(JSON.serialize(data));
		return JSON.serialize(data);
	}

	/**
    * @description Sends a message.
	* @param sender The phone number that sends the message.
	* @param receiver The phone number that receives the message. Use multiple numbers separated by a comma.
	* @param message The message to be send from the sender to receiver.
	* @param origin The source the message has been send from.
	* @return Response The response generated by the request.
    */
	global static Response sendMessage(String sender, String receiver, String message, String origin) {
		return sendMessage(sender, receiver, message, origin, '');
	}

	/**
    * @description Sends a message.
	* @param sender The phone number that sends the message.
	* @param receiver The phone number that receives the message. Use multiple numbers separated by a comma.
	* @param message The message to be send from the sender to receiver.
	* @param origin The source the message has been send from.
	* @param reference The reference bound to the message, optional for generating events
	* @return Response The response generated by the request.
    */
	global static Response sendMessage(String sender, String receiver, String message, String origin, String reference) {
		List<DataMessage> messageList = new List<DataMessage>();
		for(String r : receiver.split(',')){
			messageList.add(new DataMessage(sender, r, message, origin, reference));
		}
		return sendMessages(messageList);
	}

	/**
    * @description Sends a message.
	* @param message The message object to send.
	* @return Response The response generated by the request.
    */
	global static Response sendMessage(DataMessage message) {
		return sendMessages(new List<DataMessage>{message});
	}

	/**
    * @description Sends a message batch.
	* @param messages The list of message objects to send.
	* @return Response The response generated by the request.
    */
	global static Response sendMessages(List<DataMessage> messages) {

		// Create the data
		Data data = getConsumerData();
		data.addMessages(messages);

		// Send the message
		return sendMessageWithData(data);
	}

	/**
    * @description Sends a Data serialized message (batch). Usefull when using @future methods where only primitive types can be passed (see: prepareMessage).
	* @param body The serialized Data object to send.
	* @return Response The response generated by the request.
    */
	global static Response sendMessagesWithJSON(String body) {

		// Serialize to data
		CMTelecomAPIConsumer.Data data = (CMTelecomAPIConsumer.Data)JSON.deserialize(body, CMTelecomAPIConsumer.Data.class);

		// Send the message
		return sendMessageWithData(data);
	}

	private static Response sendMessageWithData(CMTelecomAPIConsumer.Data data) {

		try {

			Map<String, DataMessage> outboundMessages = new Map<String, DataMessage>();
			for(Integer i = 0; i < data.messages.msg.size(); i++){
				DataMessage message = data.messages.msg[i];

				// Validate the messages
				if(message.body.content == '') {
					message.body.content = null;
					continue;
				}

				// Append a timestamp on the reference because passing an unique ID is only possible by
				// inserting a record first, which is not possible before a callout
				if(message.reference != '') {
					String reference = message.reference + '_' + DateTime.now().format('yMMdHmsS') + i;
					message.reference = reference;

					// store the outbound messages in a map with reference for later easier access
					outboundMessages.put(reference, message);
				}
			}

			// Send the message
			Response res = sendRequest(API_SEND_MESSAGE, data);

			// If an CM internal error occured, stop the process
			if(res.errorCode != ERROR_CODE_OK) {
				return new Response(res.errorCode, 'Error: ' + res.details);
			}

			// Loop the messages for validation and event saving
			List<Event> eventList = new List<Event>();
			for(ResponseMessage message : res.messages){

				// Check if there is a reference to work with
				if(outboundMessages.get(message.reference) == null) {
					continue;
				}

				// Check if the object is Activity enabled
				ID objectReference = message.reference.split('_')[0];
				Set<Schema.SObjectType> objectsWithActivitiesEnabled = new Set<Schema.SObjectType>();
				for (Schema.SObjectType objectType : Task.WhatId.getDescribe().getReferenceTo()) {
				   objectsWithActivitiesEnabled.add(objectType);
				}
				Schema.SObjectType sobjectType = objectReference.getSObjectType();
				Boolean objectIsActivitesEnabled = objectsWithActivitiesEnabled.contains(sobjectType);

				// Create an event if possible
				if(!objectIsActivitesEnabled) {continue;}

				// Get the data message
				DataMessage dataMessage = outboundMessages.get(message.reference);

				// Get the SMS sender if exists
				String name = dataMessage.fromSender;
				List<CMSMSAPI__SMS_Sender__c> senderList = [
					SELECT 	ID, Name
					FROM 		CMSMSAPI__SMS_Sender__c
					WHERE 	CMSMSAPI__Phone__c = :dataMessage.fromSender
					LIMIT 	1
				];
				if(!senderList.isEmpty()) {
					name = senderList[0].Name;
				}

				// Concatenate Sender(phonenumber) and Content of Message for Subject of Event
				String subject = name + ': ' + dataMessage.body.content;
				if(subject.length() > 255){
					 subject = subject.substring(0,255);
				}

				// Create the event
				if(
				!Schema.sObjectType.Event.fields.Subject.isCreateable() &&
				!Schema.sObjectType.Event.fields.Type.isCreateable() &&
				!Schema.sObjectType.Event.fields.WhatID.isCreateable() &&
				!Schema.sObjectType.Event.fields.Reference__c.isCreateable() &&
				!Schema.sObjectType.Event.fields.Message_status__c.isCreateable() &&
				!Schema.sObjectType.Event.fields.Description.isCreateable() &&
				!Schema.sObjectType.Event.fields.DurationInMinutes.isCreateable() &&
				!Schema.sObjectType.Event.fields.ActivityDateTime.isCreateable()
				) {
					return new Response(CMTelecomAPIConsumer.STATUS_INTERNAL_SERVER_ERROR, 'Event creation not allowed.');
				}
				Event e = new Event();
				e.Subject = subject;
				e.Type = 'Message';
				e.WhatID = objectReference;
				e.Reference__c =  message.reference;
				e.Message_status__c = message.status;
				e.Description = String.join(new List<String>{
					'Receiver: ' + message.to,
					'Content: ' + dataMessage.body.content,
					'Origin: ' + dataMessage.origin
				}, '\n');
				e.DurationInMinutes = 1;
				e.ActivityDateTime = DateTime.now();
				eventList.add(e);
			}

			// All all events
			insert eventList;

			return res;

		} catch(Exception e) {
			return new Response(CMTelecomAPIConsumer.STATUS_INTERNAL_SERVER_ERROR, e.getMessage());
		}
	}

	/**
	* @description Serializable object that matches the information needed for CM Telecom (docs.cmtelecom.com/bulk_sms/v1.0).
	*/
	global class Data {

		/**
	    * @description Contains the producttoken and the messages.
	    */
		public DataMessages messages {get; set;}

		/**
	    * @description Constructor.
		* @param producttoken The producttoken from CM Telecom.
	    */
		public Data(String producttoken) {
			this.messages = new DataMessages(producttoken);
		}

		/**
	    * @description Adds a message to the data object.
		* @param message The message to add.
	    */
		public void addMessage(DataMessage message) {
			this.messages.msg.add(message);
		}

		/**
	    * @description Adds a message batch to the data object.
		* @param message The message batch to add.
	    */
		public void addMessages(List<DataMessage> messages) {
			this.messages.msg.addAll(messages);
		}
	}

	/**
	* @description Serializable object that matches the information needed for CM Telecom (docs.cmtelecom.com/bulk_sms/v1.0).
	*/
	global class DataMessages {

		/**
	    * @description Contains the producttoken.
	    */
		public DataAuthentication authentication {get; set;}

		/**
	    * @description Contains all the messages that will be send once the data is passed on to CM Telecom.
	    */
		public List<DataMessage> msg {get; set;}

		/**
	    * @description Constructor.
		* @param producttoken The producttoken from CM Telecom.
	    */
		public DataMessages(String producttoken) {
			this.authentication = new DataAuthentication(producttoken);
			this.msg = new List<DataMessage>();
		}
	}

	/**
	* @description Serializable object that matches the information needed for CM Telecom (docs.cmtelecom.com/bulk_sms/v1.0).
	*/
	global class DataAuthentication {

		/**
	    * @description The producttoken from CM Telecom.
	    */
		public String producttoken {get; set;}

		/**
	    * @description Constructor.
		* @param producttoken The producttoken from CM Telecom.
	    */
		public DataAuthentication(String producttoken) {
			this.producttoken = producttoken;
		}
	}

	/**
	* @description Serializable object that matches the information needed for CM Telecom. All field descriptions are taken from docs.cmtelecom.com/bulk_sms/v1.0.
	*/
	global class DataMessage {

		/**
	    * @description Required. This is the sender name. The maximum length is 11 alphanumerical characters or 16 digits. Example: 'CM Telecom'.
	    */
		public String fromSender {get; set;}

		/**
	    * @description Required. This is the destination mobile number. Restrictions: this value should be in international format. A single mobile number per request. Example: '00447911123456'.
	    */
		public List<DataMessageTo> to {get; set;}

		/**
	    * @description Required. This is the message text. Restrictions: the maximum length is 160 characters.
	    */
		public DataMessageBody body {get; set;}

		/**
	    * @description The allowed channels field forces a message to only use certain routes. In this field you can define a list of which channels you want your message to use. Not defining any channels will be interpreted als allowing all channels.
	    */
		public List<String> allowedChannels {get; set;}

		/**
	    * @description Use an APPKEY for Hybrid Messaging purposes. If an APPKEY is added the gateway will deliver according the settings defined in the App Manager.
	    */
		public String appkey {get; set;}

		/**
	    * @description The custom grouping field is an optional field that can be used to tag messages. These tags will be used by future CM products, like the Transactions API and SMS campaigns. Despite not being immediately visible to you yet, custom groupings can already be assigned.
	    */
		public String customGrouping {get; set;}

		/**
	    * @description The custom grouping field is an optional field that can be used to tag messages. These tags will be used by future CM products, like the Transactions API and SMS campaigns. Despite not being immediately visible to you yet, custom groupings can already be assigned.
	    */
		public String customGrouping2 {get; set;}

		/**
	    * @description The custom grouping field is an optional field that can be used to tag messages. These tags will be used by future CM products, like the Transactions API and SMS campaigns. Despite not being immediately visible to you yet, custom groupings can already be assigned.
	    */
		public String customGrouping3 {get; set;}

		/**
	    * @description Here you can include your message reference. This information will be returned in a status report so you can match the message and it's status. It should be included in the XML when posting. Restrictions: 1 - 32 alphanumeric characters and reference will not work for demo accounts.
	    */
		public String reference {get; set;}

		/**
	    * @description HTTP POST only. You use the DCS (data coding scheme) paramater to indicate the type of message you are sending. If you set DCS to '0' or do not include the parameter, the messages uses standard GSM encoding. If DCS is set to '8' the message will be encoded using Unicode UCS2. View the Unicode paragraph for more information.
	    */
		public Integer dcs {get; set;}

		/**
	    * @description Used when sending multipart or concatenated SMS messages and always used together. Indicate the minimum and maximim of message parts that you allow the gateway to send for this message (also see Multipart). Technically the gateway will first check if a message is larger than 160 characters, if so, the message will be cut into multiple 153 characters parts limited by these parameters.
	    */
		public Integer minimumNumberOfMessageParts {get; set;}

		/**
	    * @description Used when sending multipart or concatenated SMS messages and always used together. Indicate the minimum and maximim of message parts that you allow the gateway to send for this message (also see Multipart). Technically the gateway will first check if a message is larger than 160 characters, if so, the message will be cut into multiple 153 characters parts limited by these parameters.
	    */
		public Integer maximumNumberOfMessageParts {get; set;}

		/**
	    * @description The source the message has been send from.
	    */
		public String origin {get; set;}

		/**
	    * @description Constructor.
		* @param fromSender The phone number that sends the message.
		* @param to The phone number that receives the message, separated by comma's.
		* @param body The message to be send from the sender to receiver.
		* @param origin The source the message has been send from.
	    */
		public DataMessage(String fromSender, String to, String body, String origin) {
			this(fromSender, to, body, origin, '', '', '');
		}

		/**
	    * @description Constructor.
		* @param fromSender The phone number that sends the message.
		* @param to The phone number that receives the message, separated by comma's.
		* @param body The message to be send from the sender to receiver.
		* @param origin The source the message has been send from.
		* @param reference The reference bound to the message, optional for generating events
	    */
		public DataMessage(String fromSender, String to, String body, String origin, String reference) {
			this(fromSender, to, body, origin, reference, '', '');
		}

		/**
	    * @description Constructor.
		* @param fromSender The phone number that sends the message.
		* @param to The phone number that receives the message, separated by comma's.
		* @param body The message to be send from the sender to receiver.
		* @param reference The reference bound to the message, optional for generating events
		* @param customgrouping1 The first message tag.
		* @param customgrouping1 The second message tag.
	    */
		public DataMessage(String fromSender, String to, String body, String origin, String reference, String customgrouping1, String customgrouping2) {
			this.fromSender = fromSender;
			this.to = new List<DataMessageTo>();
			this.to.add(new DataMessageTo(to));
			this.body = new DataMessageBody(body);
			this.reference = reference;
			this.customGrouping = customgrouping1;
			this.customGrouping2 = customgrouping2;
			this.customGrouping3 = 'Salesforce';
			this.origin = origin;
		}
	}

	/**
	* @description Serializable object that matches the information needed for CM Telecom (docs.cmtelecom.com/bulk_sms/v1.0).
	*/
	global class DataMessageTo {

		/**
	    * @description Required. This is the destination mobile number. Restrictions: this value should be in international format. A single mobile number per request. Example: '00447911123456'.
	    */
		public String numberReceiver {get; set;}

		/**
	    * @description Constructor.
		* @param numberReceiver The phone number that receives the message.
	    */
		public DataMessageTo(String numberReceiver) {
			this.numberReceiver = numberReceiver;
		}
	}

	/**
	* @description Serializable object that matches the information needed for CM Telecom (docs.cmtelecom.com/bulk_sms/v1.0).
	*/
	global class DataMessageBody {

		/**
	    * @description Required. This is the message text. Restrictions: the maximum length is 160 characters.
	    */
		public String content {get; set;}

		/**
	    * @description Encoding type, defaults to 'AUTO'.
	    */
		public String type {get; set;}

		/**
	    * @description Constructor.
		* @param content The content of the message to be send.
	    */
		public DataMessageBody(String content) {
			this.content = content;
			this.type = 'AUTO';
		}
	}

	/**
	* @description Response class that extends AbstractResponse, used for initializing.
	*/
	global class Response extends AbstractResponse {

		/**
	    * @description Constructor.
		* @param statusCode The statuscode that has been given back.
	    */
		public Response(Integer statusCode){
			super(statusCode);
		}

		/**
	    * @description Constructor.
		* @param statusCode The statuscode that has been given back.
		* @param details A defining message that has been given back.
	    */
		public Response(Integer statusCode, String details){
			super(statusCode, details);
		}
	}

	/**
	* @description Abstract response class. Used for copying the HttpResponse class but in a way that it matches CM Telecom specifics. All properties here are expected client side. For additional properties extend this class. Cant be initialized.
	*/
	global abstract class AbstractResponse {

		/**
	    * @description A defining message that has been given back.
	    */
		@AuraEnabled
		global String details {get; set;}

		/**
	    * @description The errorCode that has been given back.
	    */
		@AuraEnabled
		global Integer errorCode {get; set;}

		/**
	    * @description The statuscode that has been given back.
	    */
		@AuraEnabled
		global Integer statusCode {get; set;}

		/**
	    * private, serialize property
	    */
		global List<ResponseMessage> messages {get; set;}

		/**
	    * @description The input data used to generate the response
	    */
		public Data inputData {get; set;}

		/**
	    * @description Constructor.
		* @param statusCode The statuscode that has been given back.
	    */
		public AbstractResponse(Integer statusCode){
			this(statusCode, null);
		}

		/**
	    * @description Constructor.
		* @param statusCode The statuscode that has been given back.
		* @param details A defining message that has been given back.
	    */
		public AbstractResponse(Integer statusCode, String details){
			this.statusCode = statusCode;
			this.errorCode = 0;
			this.details = details;
			this.messages = new List<ResponseMessage>();
		}

	}

	/**
	* private, serialize class
	*/
	global class ResponseMessage {
		global String to {get; set;}
		global String status {get; set;}
		global String reference {get; set;}
		global Integer parts {get; set;}
		global String messageDetails {get; set;}
		global Integer messageErrorCode {get; set;}
	}
}
