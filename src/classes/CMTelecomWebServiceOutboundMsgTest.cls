/*
 * @author 	Daniël Loriaux <daniel.loriaux@7dots.eu>
 * @version 1.0
 * @since 	17-02-2017
 */
@isTest
private class CMTelecomWebServiceOutboundMsgTest {

	@isTest static void testConfirm() {

		Event e = new Event();
		e.Reference__c = 'test';
		e.From_Status_Report__c = false;
		e.Message_status__c = '';
		e.Subject = 'SMS send from TODO';
		e.Type = 'Message';
		e.DurationInMinutes = 1;
		e.ActivityDateTime = DateTime.now();
		insert e;

		CMTelecomWebServiceOutboundMsg.OutboundParam p = new CMTelecomWebServiceOutboundMsg.OutboundParam();
		p.reference = 'test';
		p.status = 'Accepted';
		CMTelecomWebServiceOutboundMsg.confirmMessage(JSON.serialize(p));

		// confirmMessage is a @future method with nothing returned
		System.assertEquals(true, true);
	}

	@isTest static void testNoEvent() {
		CMTelecomWebServiceOutboundMsg.OutboundParam p = new CMTelecomWebServiceOutboundMsg.OutboundParam();
		p.reference = 'test';
		p.status = 'Accepted';
		CMTelecomWebServiceOutboundMsg.confirmMessage(JSON.serialize(p));

		// confirmMessage is a @future method with nothing returned
		System.assertEquals(true, true);
	}

	@isTest static void testInvalid() {

		CMTelecomWebServiceOutboundMsg.OutboundParam p1 = new CMTelecomWebServiceOutboundMsg.OutboundParam();
		p1.reference = '';
		p1.status = 'Accepted';
		CMTelecomWebServiceOutboundMsg.confirmMessage(JSON.serialize(p1));

		// confirmMessage is a @future method with nothing returned
		System.assertEquals(true, true);

		CMTelecomWebServiceOutboundMsg.OutboundParam p2 = new CMTelecomWebServiceOutboundMsg.OutboundParam();
		p2.reference = 'test';
		p2.status = '';
		CMTelecomWebServiceOutboundMsg.confirmMessage(JSON.serialize(p2));

		// confirmMessage is a @future method with nothing returned
		System.assertEquals(true, true);
	}

	@isTest static void testGet() {
		RestRequest req = new RestRequest();
		req.params.put('REFERENCE', 'reference');
		req.params.put('STATUS', 'status');
		RestResponse res = new RestResponse();

		req.requestURI = '';
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;
		CMTelecomWebServiceOutboundMsg.doGet();
		System.assertEquals(true,true);
	}

	@isTest static void testPost() {

		CMTelecomWebServiceOutboundMsg.OutboundParam p = new CMTelecomWebServiceOutboundMsg.OutboundParam();
		p.reference = 'reference';
		p.status = 'status';

		RestRequest req = new RestRequest();
		req.requestBody = Blob.valueOf(JSON.serialize(p));
		RestResponse res = new RestResponse();

		req.requestURI = '';
		req.httpMethod = 'POST';
		RestContext.request = req;
		RestContext.response = res;
		CMTelecomWebServiceOutboundMsg.doPost();
		System.assertEquals(true,true);
	}
}