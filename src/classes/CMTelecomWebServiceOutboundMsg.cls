/**
* @author Daniël Loriaux - 7dots <daniel.loriaux@7dots.eu>
* @date 2017
*
* @description Webservice for the CM Telecom Webhook
*/
@RestResource(urlMapping='/v1.0/outbound/')
global without sharing class CMTelecomWebServiceOutboundMsg {

	/**
    * @description Creates a related event with the input from the CM webhook.
		* @param jsonInstance json from the CM webhook.
    */
	public static void confirmMessage(String jsonInstance) {

		// Deserialize input
		OutboundParam param = null;
		if(jsonInstance != '') {
			param = (OutboundParam)JSON.deserialize(jsonInstance, OutboundParam.class);
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
		OutboundParam p = new OutboundParam();
		p.reference = RestContext.request.params.get('REFERENCE');
		p.status = RestContext.request.params.get('STATUS');
		CMTelecomWebServiceOutboundMsg.confirmMessageASYNC(JSON.serialize(p));

		return new CMTelecomAPIConsumer.Response(CMTelecomAPIConsumer.STATUS_OK, 'webhook received');
	}

	/**
    * @description POST method receiving method.
		* XML https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_xml_dom.htm
    */
	@HttpPost
	global static CMTelecomAPIConsumer.Response doPost() {
		try {
			// Convert String to XML
			String jsonInstance = RestContext.request.requestBody.toString();
			XmlStreamReader xsr = new XmlStreamReader(jsonInstance);
	    List<CMTelecomInboundMsgXMLReader.message> msgs = CMTelecomInboundMsgXMLReader.parseMessages(xsr);

			// Debug
			// Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			// String[] toAddresses = new String[] {'daniel.loriaux@7dots.eu'};
			// mail.setToAddresses(toAddresses);
			// mail.setReplyTo('daniel.loriaux@7dots.eu');
			// mail.setSenderDisplayName('Daniel');
			// mail.setSubject('OUTBOUND');
			// mail.setBccSender(false);
			// mail.setUseSignature(false);
			// mail.setPlainTextBody(jsonInstance);
			// Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

			for(Integer i = 0; i < msgs.size(); i++) {
				CMTelecomInboundMsgXMLReader.message msg = msgs[i];
				OutboundParam p = new OutboundParam();
				p.reference = msg.reference;
				p.status = msg.code;

				// Pass body to the confirmation process
				CMTelecomWebServiceOutboundMsg.confirmMessageASYNC(JSON.serialize(p));
			}

			return new CMTelecomAPIConsumer.Response(CMTelecomAPIConsumer.STATUS_OK, 'webhook received');
		} catch(Exception e) {
			return new CMTelecomAPIConsumer.Response(CMTelecomAPIConsumer.STATUS_INTERNAL_SERVER_ERROR, 'webhook error:' + e.getMessage());
		}
	}

	/**
	* @description Used to store data from GET and POST
	*/
	global class OutboundParam {
		public String status;
		public String reference;
	}
}