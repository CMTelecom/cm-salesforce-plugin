/*
 * @author 	Daniël Loriaux <daniel.loriaux@7dots.eu>
 * @version 1.0
 * @since 	17-02-2017
 */
@isTest
private class CMTelecomAPIConsumerTest {

	@isTest static void testPrepareMessage() {
		CMTelecomAPIConsumer.ResponseMessage msg = new CMTelecomAPIConsumer.ResponseMessage();
		msg.to = null;
		msg.status = null;
		msg.reference = null;
		msg.parts = null;
		msg.messageDetails = null;
		msg.messageErrorCode = null;
		String messageFormat1 = CMTelecomAPIConsumer.prepareMessage('sender', 'receiver', 'message', 'origin');
		CMTelecomAPIConsumer.Data data1 = (CMTelecomAPIConsumer.Data)JSON.deserialize(messageFormat1, CMTelecomAPIConsumer.Data.class);
		System.assertNotEquals(data1, null);

		String messageFormat2 = CMTelecomAPIConsumer.prepareMessage(new CMTelecomAPIConsumer.DataMessage('sender', 'receiver', 'message', 'origin'));
		CMTelecomAPIConsumer.Data data2 = (CMTelecomAPIConsumer.Data)JSON.deserialize(messageFormat2, CMTelecomAPIConsumer.Data.class);
		System.assertNotEquals(data2, null);
	}

	@isTest static void testSendMessage() {
    	Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
    	CMTelecomAPIConsumer.Response messageResponse = CMTelecomAPIConsumer.sendMessage('sender', 'receiver', 'message', 'origin');
		System.assertEquals(messageResponse.statusCode, CMTelecomAPIConsumer.STATUS_OK);
	}

	@isTest static void testAddMessages() {
    	CMTelecomAPIConsumer.Data data = new CMTelecomAPIConsumer.Data('TEST');
		CMTelecomAPIConsumer.DataMessage message = new CMTelecomAPIConsumer.DataMessage('sender', 'receiver', 'message', 'origin');
		message.allowedChannels = new List<String>{'A', 'B'};
		message.appKey = 'C';
		message.dcs = 8;
		message.minimumNumberOfMessageParts = 1;
		message.maximumNumberOfMessageParts = 8;
		data.addMessage(message);
		System.assertEquals(data.messages.msg.isEmpty(), false);
	}

	@isTest static void testResponse() {
		CMTelecomAPIConsumer.Response rs1 = new CMTelecomAPIConsumer.Response(CMTelecomAPIConsumer.STATUS_OK);
		CMTelecomAPIConsumer.Response rs2 = new CMTelecomAPIConsumer.Response(CMTelecomAPIConsumer.STATUS_OK, 'test');

		System.assertEquals(rs1.statusCode, CMTelecomAPIConsumer.STATUS_OK);
		System.assertEquals(rs2.details, 'test');
	}

	class ExampleCalloutMock implements HttpCalloutMock{
		public HttpResponse respond(HTTPRequest req){
	    	HttpResponse res = new HttpResponse();
		    res.setStatus('OK');
		    res.setStatusCode(CMTelecomAPIConsumer.STATUS_OK);
		    res.setBody(JSON.serialize(new CMTelecomAPIConsumer.Response(CMTelecomAPIConsumer.STATUS_OK)));
	    	return res;
	  	}
	}

}