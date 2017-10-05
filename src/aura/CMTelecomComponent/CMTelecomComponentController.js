({
	doInit : function(component, event, helper) {
        
        // Get the phone values
        var actionPhoneValues = component.get('c.getPhoneSelectValues');
        helper.enqueAction(component, actionPhoneValues, 'doInit:actionPhoneValues', function(res){
            component.set('v.outputSender', res.items[0].value);
            component.set('v.inputSender', res);
        });
        
        // Create the action
        var actionPhoneAPI = component.get('c.getPhoneField');
        actionPhoneAPI.setParams({
            'apiPhoneHandle':component.get('v.field'),
            'recordID':component.get('v.recordId')
        });
        helper.enqueAction(component, actionPhoneAPI, 'doInit:actionPhoneAPI', function(res){
        	component.set('v.inputReceiver', res.details);
        });
	},
    
    doSendMessage: function(component, event, helper) {
        
        // Get the sender
        var sender = component.get('v.outputSender');
        if(sender == 'Other') {
            sender = component.get('v.inputOtherSender');
        }
        
		// Create the action
        var action = component.get('c.sendMessage');
        action.setParams({
            'sender':sender,
            'receiver':component.get('v.inputReceiver'),
            'message':component.get('v.inputMessage'),
            'origin':component.get('v.origin'),
            'recordID':component.get('v.recordId')
        });
        helper.enqueAction(component, action, 'doSendMessage', function(res){
            // Send
        });
    }
})