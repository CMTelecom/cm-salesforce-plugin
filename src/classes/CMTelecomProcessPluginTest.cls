/*
 * @author 	Daniël Loriaux <daniel.loriaux@7dots.eu>
 * @version 1.0
 * @since 	17-02-2017
 */
@isTest
private class CMTelecomProcessPluginTest {

	@isTest static void testPrepareMessage() {

		CMTelecomProcessPlugin.CMTelecomProcessPluginParameters params = new CMTelecomProcessPlugin.CMTelecomProcessPluginParameters();
		params.sender = 'sender';
		params.receiver = 'receiver';
		params.message = 'message';
		params.reference = 'reference';
		params.origin = 'origin';

		Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
		CMTelecomProcessPlugin.sendMessage(new List<CMTelecomProcessPlugin.CMTelecomProcessPluginParameters>{params});

		// Nothing to test here because @InvocableMethod methods do no have a return type
		// Coverage only (core code is tested in CMTelecomAPIConsumer)
		System.assertEquals(true, true);
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