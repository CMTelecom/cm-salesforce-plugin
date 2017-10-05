/*
 * @author 	Daniël Loriaux <daniel.loriaux@7dots.eu>
 * @version 1.0
 * @since 	17-02-2017
 */
@isTest
private class CMTelecomComponentControllerTest {

	@isTest static void testGetPhoneFieldSuccess() {
		Test.startTest();
		// Set a test value
		String myTestPhone = '1234567890';

		// Create the mock account
		Account a = new Account(name='TestAccount');
		a.Phone = myTestPhone;
		insert a;

		// get the field
		String myRetrievedPhoneJSON = CMTelecomComponentController.getPhoneField('Phone', String.valueOf(a.ID));
		CMTelecomAPIConsumer.Response data = (CMTelecomAPIConsumer.Response)JSON.deserialize(myRetrievedPhoneJSON, CMTelecomAPIConsumer.Response.class);
		Test.stopTest();

		System.assertEquals(data.details, myTestPhone);
	}

	@isTest static void testGetPhoneFieldNoAPI() {
		Test.startTest();
		// Set a test value
		String myTestPhone = '1234567890';

		// Create the mock account
		Account a = new Account(name='TestAccount');
		a.Phone = myTestPhone;
		insert a;

		// get the field
		String myRetrievedPhoneJSON = CMTelecomComponentController.getPhoneField(null, String.valueOf(a.ID));
		CMTelecomAPIConsumer.Response data = (CMTelecomAPIConsumer.Response)JSON.deserialize(myRetrievedPhoneJSON, CMTelecomAPIConsumer.Response.class);
		Test.stopTest();

		System.assertEquals(data.statusCode, CMTelecomAPIConsumer.STATUS_OK);
	}

	@isTest static void testGetPhoneFieldNoObject() {
		Test.startTest();
		// Set a test value
		String myTestPhone = '1234567890';

		// Create the mock account
		Account a = new Account(name='TestAccount');
		a.Phone = myTestPhone;
		insert a;
		ID newAccountID = a.ID;
		delete a;

		// get the field
		String myRetrievedPhoneJSON = CMTelecomComponentController.getPhoneField('Phone', String.valueOf(newAccountID));
		CMTelecomAPIConsumer.Response data = (CMTelecomAPIConsumer.Response)JSON.deserialize(myRetrievedPhoneJSON, CMTelecomAPIConsumer.Response.class);
		Test.stopTest();

		System.assertEquals(data.statusCode, CMTelecomAPIConsumer.STATUS_OK);
	}

	@isTest static void testGetPhoneFieldNoField() {
		Test.startTest();
		// Set a test value
		String myTestPhone = '1234567890';

		// Create the mock account
		Account a = new Account(name='TestAccount');
		a.Phone = myTestPhone;
		insert a;
		ID newAccountID = a.ID;
		delete a;

		// get the field
		String myRetrievedPhoneJSON = CMTelecomComponentController.getPhoneField('DOESNOTEXISTS', String.valueOf(newAccountID));
		CMTelecomAPIConsumer.Response data = (CMTelecomAPIConsumer.Response)JSON.deserialize(myRetrievedPhoneJSON, CMTelecomAPIConsumer.Response.class);
		Test.stopTest();

		System.assertEquals(data.statusCode, CMTelecomAPIConsumer.STATUS_BAD_REQUEST);
	}

	@isTest static void testGetPhoneFieldValues() {
		Test.startTest();
		// Set a test value
		String myTestPhone = '1234567890';

		// Create the mock account
		SMS_Sender__c n = new SMS_Sender__c(name='TestPhone');
		n.Phone__c = '0000';
		insert n;

		// get the field
		String myRetrievedPhoneJSON = CMTelecomComponentController.getPhoneSelectValues();
		CMTelecomComponentController.ResponseSelect data = (CMTelecomComponentController.ResponseSelect)JSON.deserialize(myRetrievedPhoneJSON, CMTelecomComponentController.ResponseSelect.class);
		Test.stopTest();

		System.assertEquals(data.items.isEmpty(), false);
	}

	@isTest static void testResponse() {
		CMTelecomComponentController.ResponseSelect rs1 = new CMTelecomComponentController.ResponseSelect(CMTelecomAPIConsumer.STATUS_OK);
		CMTelecomComponentController.ResponseSelect rs2 = new CMTelecomComponentController.ResponseSelect(CMTelecomAPIConsumer.STATUS_OK, 'test');

		System.assertEquals(rs1.statusCode, CMTelecomAPIConsumer.STATUS_OK);
		System.assertEquals(rs2.details, 'test');
	}

	@isTest static void testSendMessage() {
		Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
		String myMessageJSON = CMTelecomComponentController.sendMessage('sender', 'receiver', 'message', 'origin', null);
		CMTelecomAPIConsumer.Response data = (CMTelecomAPIConsumer.Response)JSON.deserialize(myMessageJSON, CMTelecomAPIConsumer.Response.class);

		System.assertEquals(data.statusCode, CMTelecomAPIConsumer.STATUS_OK);
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