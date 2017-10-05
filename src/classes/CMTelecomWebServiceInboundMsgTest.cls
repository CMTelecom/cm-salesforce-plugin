/*
 * @author 	Tom Jansen <tom.jansen@7dots.eu>
 * @version 1.0
 * @since 	20-06-2017
 */
@isTest
public class CMTelecomWebServiceInboundMsgTest {
	@isTest static void test_WithReference_ReferenceExists() {
        CMSMSAPI__SMS_Sender__c s = new CMSMSAPI__SMS_Sender__c();
        s.CMSMSAPI__Phone__c = '0123456789';
        s.Name = 'Johnny Test';
        insert s;
        
        
        Event e = new Event();
		e.Subject = 'Test';
		e.Type = 'Message';
		e.WhatID = s.Id;
		e.Reference__c = 'a010Y00000ToIliQAF_20170620105591290';
		e.Description = 'Testing';
		e.DurationInMinutes = 1;
		e.ActivityDateTime = DateTime.now();
        insert e;


		String request = '<MESSAGES><MSG><ID>519161862</ID><RECEIVER>8850</RECEIVER><MESSAGE>Test</MESSAGE><UDH></UDH><SENDER OPERATOR="20601">0123456789</SENDER><BINARY>False</BINARY><REFERENCE>a010Y00000ToIliQAF_20170620105591290</REFERENCE><SENT>2017-06-20T10:57:39</SENT><DCS></DCS><RESERVED1></RESERVED1><RESERVED2></RESERVED2><RESERVED3></RESERVED3><RESERVED4></RESERVED4><RESERVED5></RESERVED5><CUSTOMGROUPING></CUSTOMGROUPING><CUSTOMGROUPING2></CUSTOMGROUPING2><CUSTOMGROUPING3>Salesforce</CUSTOMGROUPING3><SESSIONGUID></SESSIONGUID></MSG></MESSAGES>';

		RestRequest req = new RestRequest();
		req.requestBody = Blob.valueOf(request);
		RestResponse res = new RestResponse();

		req.requestURI = '';
		req.httpMethod = 'POST';
		RestContext.request = req;
		RestContext.response = res;
		CMTelecomWebServiceInboundMsg.doPost();
		System.assertEquals(true,true);
	}
    
    @isTest static void test_WithReference_ReferenceDoesNotExist_NonExistingSender() {

		String request = '<MESSAGES><MSG><ID>519161862</ID><RECEIVER>8850</RECEIVER><MESSAGE>Test</MESSAGE><UDH></UDH><SENDER OPERATOR="20601">0123456789</SENDER><BINARY>False</BINARY><REFERENCE>a010Y00000ToIliQAF_20170620105591290</REFERENCE><SENT>2017-06-20T10:57:39</SENT><DCS></DCS><RESERVED1></RESERVED1><RESERVED2></RESERVED2><RESERVED3></RESERVED3><RESERVED4></RESERVED4><RESERVED5></RESERVED5><CUSTOMGROUPING></CUSTOMGROUPING><CUSTOMGROUPING2></CUSTOMGROUPING2><CUSTOMGROUPING3>Salesforce</CUSTOMGROUPING3><SESSIONGUID></SESSIONGUID></MSG></MESSAGES>';

		RestRequest req = new RestRequest();
		req.requestBody = Blob.valueOf(request);
		RestResponse res = new RestResponse();

		req.requestURI = '';
		req.httpMethod = 'POST';
		RestContext.request = req;
		RestContext.response = res;
		CMTelecomWebServiceInboundMsg.doPost();
		System.assertEquals(true,true);
	}
    
    @isTest static void test_WithReference_ReferenceDoesNotExist_ExistingSender() {
		CMSMSAPI__SMS_Sender__c s = new CMSMSAPI__SMS_Sender__c();
        s.CMSMSAPI__Phone__c = '0123456789';
        s.Name = 'Johnny Test';
        insert s;
        
		String request = '<MESSAGES><MSG><ID>519161862</ID><RECEIVER>8850</RECEIVER><MESSAGE>Test</MESSAGE><UDH></UDH><SENDER OPERATOR="20601">0123456789</SENDER><BINARY>False</BINARY><REFERENCE>a010Y00000ToIliQAF_20170620105591290</REFERENCE><SENT>2017-06-20T10:57:39</SENT><DCS></DCS><RESERVED1></RESERVED1><RESERVED2></RESERVED2><RESERVED3></RESERVED3><RESERVED4></RESERVED4><RESERVED5></RESERVED5><CUSTOMGROUPING></CUSTOMGROUPING><CUSTOMGROUPING2></CUSTOMGROUPING2><CUSTOMGROUPING3>Salesforce</CUSTOMGROUPING3><SESSIONGUID></SESSIONGUID></MSG></MESSAGES>';

		RestRequest req = new RestRequest();
		req.requestBody = Blob.valueOf(request);
		RestResponse res = new RestResponse();

		req.requestURI = '';
		req.httpMethod = 'POST';
		RestContext.request = req;
		RestContext.response = res;
		CMTelecomWebServiceInboundMsg.doPost();
		System.assertEquals(true,true);
	}
    
    @isTest static void test_WithoutReference_NonExistingSender() {

		String request = '<MESSAGES><MSG><ID>519161862</ID><RECEIVER>8850</RECEIVER><MESSAGE>Test</MESSAGE><UDH></UDH><SENDER OPERATOR="20601">0123456789</SENDER><BINARY>False</BINARY><REFERENCE></REFERENCE><SENT>2017-06-20T10:57:39</SENT><DCS></DCS><RESERVED1></RESERVED1><RESERVED2></RESERVED2><RESERVED3></RESERVED3><RESERVED4></RESERVED4><RESERVED5></RESERVED5><CUSTOMGROUPING></CUSTOMGROUPING><CUSTOMGROUPING2></CUSTOMGROUPING2><CUSTOMGROUPING3>Salesforce</CUSTOMGROUPING3><SESSIONGUID></SESSIONGUID></MSG></MESSAGES>';

		RestRequest req = new RestRequest();
		req.requestBody = Blob.valueOf(request);
		RestResponse res = new RestResponse();

		req.requestURI = '';
		req.httpMethod = 'POST';
		RestContext.request = req;
		RestContext.response = res;
		CMTelecomWebServiceInboundMsg.doPost();
		System.assertEquals(true,true);
	}
    
    @isTest static void test_WithoutReference_ExistingSender() {
		CMSMSAPI__SMS_Sender__c s = new CMSMSAPI__SMS_Sender__c();
        s.CMSMSAPI__Phone__c = '0123456789';
        s.Name = 'Johnny Test';
        insert s;
        
		String request = '<MESSAGES><MSG><ID>519161862</ID><RECEIVER>8850</RECEIVER><MESSAGE>Test</MESSAGE><UDH></UDH><SENDER OPERATOR="20601">0123456789</SENDER><BINARY>False</BINARY><REFERENCE></REFERENCE><SENT>2017-06-20T10:57:39</SENT><DCS></DCS><RESERVED1></RESERVED1><RESERVED2></RESERVED2><RESERVED3></RESERVED3><RESERVED4></RESERVED4><RESERVED5></RESERVED5><CUSTOMGROUPING></CUSTOMGROUPING><CUSTOMGROUPING2></CUSTOMGROUPING2><CUSTOMGROUPING3>Salesforce</CUSTOMGROUPING3><SESSIONGUID></SESSIONGUID></MSG></MESSAGES>';

		RestRequest req = new RestRequest();
		req.requestBody = Blob.valueOf(request);
		RestResponse res = new RestResponse();

		req.requestURI = '';
		req.httpMethod = 'POST';
		RestContext.request = req;
		RestContext.response = res;
		CMTelecomWebServiceInboundMsg.doPost();
		System.assertEquals(true,true);
	}
}