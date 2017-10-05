/**
* @author Tom Jansen - 7dots <tom.jansen@7dots.eu>
* @date 2017
*
* @description Webservice for the CM Telecom Inbound Messages
*/

@RestResource(urlMapping='/v1.0/inbound/')
global without sharing class CMTelecomWebServiceInboundMsg {

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
			// Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			// String[] toAddresses = new String[] {'daniel.loriaux@7dots.eu'};
			// mail.setToAddresses(toAddresses);
			// mail.setReplyTo('daniel.loriaux@7dots.eu');
			// mail.setSenderDisplayName('Daniel');
			// mail.setSubject('INBOUND');
			// mail.setBccSender(false);
			// mail.setUseSignature(false);
			// mail.setPlainTextBody(jsonInstance);
			// Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

			//Pass body to Method to Save Inbound Message
			saveInboundMessages(jsonInstance);

			return new CMTelecomAPIConsumer.Response(CMTelecomAPIConsumer.STATUS_OK, 'webhook received');
		} catch(Exception e) {
			return new CMTelecomAPIConsumer.Response(CMTelecomAPIConsumer.STATUS_INTERNAL_SERVER_ERROR, 'webhook error:' + e.getMessage());
		}
	}

	/**
    * @description Creates a related event with the input from the CM webhook for every inbound message.
		* @param jsonInstance json from the CM webhook.
    */
	public static void saveInboundMessages(String jsonInstance){

    // Convert String to XML
		XmlStreamReader xsr = new XmlStreamReader(jsonInstance);
    List<CMTelecomInboundMsgXMLReader.message> msgs = CMTelecomInboundMsgXMLReader.parseMessages(xsr);
		List<Event> eventListDML = new List<Event>();

		// Loop through all messages
		for(Integer i = 0; i < msgs.size(); i++) {
			CMTelecomInboundMsgXMLReader.message msg = msgs[i];
			String reference = '';
			String sender = '';
			String whatID = null;
			String name = '';

			// Get reference and sender
			if(msg.reference != null && msg.reference != '') {reference = msg.reference;}
			if(msg.sender != null && msg.sender != '') {sender = msg.sender;}
			if(reference == '' && sender == '') {continue;}

			// Find the SMS Sender by sender
			CMSMSAPI__SMS_Sender__c senderObj = null;
			if(sender != '') {
				List<CMSMSAPI__SMS_Sender__c> senderList = [
					SELECT 	ID, Name
					FROM 		CMSMSAPI__SMS_Sender__c
					WHERE 	CMSMSAPI__Phone__c = :sender
					LIMIT 	1
				];
				if(senderList.isEmpty()) {
					name = sender;
				} else {
					senderObj = senderList[0];
					name = senderObj.Name;
				}
			}

			// Find event by reference
			if(reference != '') {

				// Find the event
				List<Event> eventList = [
					SELECT	ID, WhatId
					FROM 		Event
					WHERE 	Reference__c = :reference
					LIMIT 	1
				];

				// If no event is found, bind it to the SMS sender
				if(eventList.isEmpty()) {

					// If no sender is found, create the SMS sender
					if(senderObj == null) {
						CMSMSAPI__SMS_Sender__c s = new CMSMSAPI__SMS_Sender__c();
						s.Name = sender;
						s.CMSMSAPI__Phone__c = sender;
						insert s;

						// Save the ID of the new SMS sender
						whatID = s.ID;
					} else {
						// Save the ID of the SMS sender
						whatID = senderObj.ID;
					}
				} else {
					// Save the whatID of the event
					whatID = eventList[0].WhatID;
				}
			} else {

				if(senderObj == null) {
					CMSMSAPI__SMS_Sender__c s = new CMSMSAPI__SMS_Sender__c();
					s.Name = sender;
					s.CMSMSAPI__Phone__c = sender;
					insert s;

					// Save the ID of the new SMS sender
					whatId = s.ID;
				} else {
					whatId = senderObj.ID;
				}
			}

			// Concatenate Sender(phonenumber) and Content of Message for Subject of Event
			String subject = name + ': ' + msg.text;
			if(subject.length() > 255){
				 subject = subject.substring(0,255);
			}

			// Create new Event
			Event e = new Event();
			e.Subject = subject;
			e.Type = 'Message';
			e.WhatID = whatId;
			e.Reference__c = whatId + '_' + DateTime.now().format('yMMdHmsS') + i ;
			e.Description = String.join(new List<String>{
			'Sender: ' + sender,
			'Content: ' + msg.text
			}, '\n');
			e.DurationInMinutes = 1;
			e.ActivityDateTime = DateTime.now();
			eventListDML.add(e);
		}

		// Insert new Event
		insert eventListDML;
	}
}