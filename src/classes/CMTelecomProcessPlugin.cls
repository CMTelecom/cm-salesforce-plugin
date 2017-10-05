/**
* @author Daniël Loriaux - 7dots <daniel.loriaux@7dots.eu>
* @date 2017
*
* @description Plugin for ProcessBuilder/Flows that uses APIConsumer.
*/
global without sharing class CMTelecomProcessPlugin {

	/**
    * @description Sends a SMS from the sender to the receiver containing the message.
	* @param params The parameters that are filled in with ProcessBuilder/Flow
    */
	@InvocableMethod(label='CM Send SMS' description='Sends a SMS from the sender to the receiver containing the message')
	global static void sendMessage(List<CMTelecomProcessPluginParameters> params) {

		// Bulkify all messages
		List<CMTelecomAPIConsumer.DataMessage> messages = new List<CMTelecomAPIConsumer.DataMessage>();
		for(CMTelecomProcessPluginParameters param : params){
			CMTelecomAPIConsumer.DataMessage message = new CMTelecomAPIConsumer.DataMessage(param.sender, param.receiver, param.message, param.origin);
			message.reference = param.reference;
			messages.add(message);
		}

		// Send the SMS
		sendMessagesToService(CMTelecomAPIConsumer.prepareMessages(messages));
	}

	@future(callout=true)
	private static void sendMessagesToService(String body) {
		CMTelecomAPIConsumer.Response result = CMTelecomAPIConsumer.sendMessagesWithJSON(body);
	}

	/**
	* @description The parameters available in ProcessBuilder/Flow
	*/
	global class CMTelecomProcessPluginParameters {

		/**
		* @description The phone number that sends the message.
		*/
		@InvocableVariable(required=true)
		global String sender;

		/**
		* @description The phone number that receives the message.
		*/
		@InvocableVariable(required=true)
		global String receiver;

		/**
		* @description The message to be send from the sender to receiver.
		*/
		@InvocableVariable(required=true)
		global String message;

		/**
		* @description The source the message has been send from.
		*/
		@InvocableVariable(required=true)
		global String origin;

		/**
		* @description The object reference (recordID)
		*/
		@InvocableVariable(required=false)
		global String reference;
	}
}