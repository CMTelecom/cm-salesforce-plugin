({
    DEBUG: true,
    
	enqueAction : function(component, action, name, callback) {
        var _this = this;
		component.set('v.outputWarningShow', false);
        action.setCallback(this, function(a){
            
            // Convert to JSON object
            var res = JSON.parse(a.getReturnValue());
            if(_this.DEBUG) {
            	console.log(name, res);
            }
            
            // Pass to callback if no errors found
            if(res.statusCode === 200) {
                callback(res);
            } else {
                component.set('v.outputWarningShow', true);
                var errorMessage = res.details;
                if(res.messages != null) {
                    var tempList = [];
                    res.messages.forEach(function(e){
                        tempList.push(e.messageDetails);
                    });
					errorMessage += ' [' + tempList.join(', ') + ']';
                }
                component.set('v.outputWarningMessage', errorMessage);
            }
            component.set('v.loading', '');
        });
        
        component.set('v.loading', 'loading');
		$A.enqueueAction(action);
	}
})