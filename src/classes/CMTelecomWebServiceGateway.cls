/**
* @author Daniël Loriaux - 7dots <daniel.loriaux@7dots.eu>
* @date 2017
*
* @description Webservice for the CM Telecom Webhook
* @deprecated Use CMTelecomWebServiceInboundMsg instead
*/
@RestResource(urlMapping='/v1.0/gateway/')
global without sharing class CMTelecomWebServiceGateway {

	/**
    * @description Creates a related event with the input from the CM webhook.
		* @param jsonInstance json from the CM webhook.
    */
	public static void confirmMessage(String jsonInstance) {

		// Deserialize input
		GatewayInboundParam param = null;
		if(jsonInstance != '') {
			param = (GatewayInboundParam)JSON.deserialize(jsonInstance, GatewayInboundParam.class);
		}

		//	Map the status to readable text
		Map<String, String> humanizeStatus = new Map<String, String>{
			'0' => 'Accepted',
			'1' => 'Rejected',
			'2' => 'Delivered',
			'3' => 'Failed'
		};

		// Get the event by reference
		List<Event> eventList = [
			SELECT	ID
			FROM 	Event
			WHERE 	Reference__c = :param.reference
			LIMIT 	1
		];
		if(eventList.isEmpty()) {
			return;
		}
		Event e = eventList[0];

		// Update the event
		e.Message_status__c = humanizeStatus.get(param.status);
		e.From_Status_Report__c = true;
		update e;
	}

	/**
    * @description Creates a related event with the input from the CM webhook. Async.
		* @param jsonInstance json from the CM webhook.
    */
	@future
	public static void confirmMessageASYNC(String jsonInstance) {
		confirmMessage(jsonInstance);
	}

	/**
    * @description GET method receiving method.
    */
	@HttpGet
	global static CMTelecomAPIConsumer.Response doGet() {

		// Pass parameters to the confirmation process
		GatewayInboundParam p = new GatewayInboundParam();
		p.reference = RestContext.request.params.get('REFERENCE');
		p.status = RestContext.request.params.get('STATUS');
		CMTelecomWebServiceGateway.confirmMessageASYNC(JSON.serialize(p));

		return new CMTelecomAPIConsumer.Response(CMTelecomAPIConsumer.STATUS_OK, 'webhook received');
	}

	/**
    * @description POST method receiving method.
		* XML https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_xml_dom.htm
    */
	@HttpPost
	global static CMTelecomAPIConsumer.Response doPost() {
		try {
			// Process body
			String jsonInstance = RestContext.request.requestBody.toString();

			// Debug
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = new String[] {'daniel.loriaux@7dots.eu'};
			mail.setToAddresses(toAddresses);
			mail.setReplyTo('daniel.loriaux@7dots.eu');
			mail.setSenderDisplayName('Daniel');
			mail.setSubject('OUTBOUND');
			mail.setBccSender(false);
			mail.setUseSignature(false);
			mail.setPlainTextBody(jsonInstance);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

			// Pass body to the confirmation process
			// CMTelecomWebServiceGateway.confirmMessageASYNC(jsonInstance);

			return new CMTelecomAPIConsumer.Response(CMTelecomAPIConsumer.STATUS_OK, 'webhook received');
		} catch(Exception e) {
			return new CMTelecomAPIConsumer.Response(CMTelecomAPIConsumer.STATUS_INTERNAL_SERVER_ERROR, 'webhook error:' + e.getMessage());
		}
	}

	/**
	* @description Used to store data from GET and POST
	*/
	global class GatewayInboundParam {
		public String status;
		public String reference;
	}
}