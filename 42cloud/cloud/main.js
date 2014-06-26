var TWILIO_SID = "AC9e34bf667ca57755d3a054861b982498";
var TWILIO_TOKEN = "0ac6451898241394d46014ff276e34ba";
var TWILIO_NUMBER = "+15162521824";

var twilio = require("twilio")(TWILIO_SID, TWILIO_TOKEN);

var generateKey = function(n) {
    // rand from 0 to 9, n times, for n digit random number
    var lolcode = "";
    for (var i = 0; i < n; i ++) {
        lolcode += Math.floor(Math.random() * 10).toString();
    }
    return lolcode;
};

/* User defaults and validation */
Parse.Cloud.beforeSave("User", function(request, response) {
    request.object.set('validationKey', null);
    request.object.set('validationLastSent', new Date());
    request.object.set('validatedPhone', false);
    request.object.set('validationCount', 0);
    response.success();
});

Parse.Cloud.define("sendValidationSMS", function(request, response) {
  /* 
   * This function is designed so you can run it again and again.
   * Not necessarily concurrent-safe.
   *
   * If validates more than MAX_VALIDATE_TEXTS_ALLOWED, return "max validation texts exceeded"
   *
   * Given a user, which must have a phone number, and is not already validated
   *   1. generate a validation key
   *   2. set the key on the user object,
   *        and a lastValidationSent datetime,
   *        and validationCount ++
   *   3. save the user object
   *   4. send a twilio text message. */

  var user = Parse.User.current();

  if (!user) {
    response.error("Not logged in.");
    return;
  }

  // 4 digit long key for now.
  user.validationKey = generateKey(4);

  // send via Twilio
  twilio.sendSms({
    from: TWILIO_NUMBER,
    to: user.phoneNumber,
    body: "Your code is " + user.validationKey
  }, {
    success: function(httpResponse) { response.success(user.validationKey); },
    error: function(httpResponse) { response.error("Uh oh, something went wrong"); }
  });

  // theoretical race condition where person tries to validate before the user object is saved
    // but that'll never happen, right?

  // Let us remember what just occured
  user.validationLastSent = new Date();
  user.validationCount += 1;
  user.save()

  response.success("Hello world!");
});

Parse.Cloud.define("validateSMSKey", function(request, response) {
    /**/
  response.success("Hello world!");
});

Parse.Cloud.afterSave("LocationSent", function(request) {

  // Our "LocationSent" class has a "text" key with the body of the comment itself
  var sendToUser = request.object.get('to');
  var fromUser   = request.object.get('from');
  console.log(request.object.id);

  request.object.get('from').fetch().then(function(fromUser) {
	var fromUserName = fromUser.get('username');  
	var pushQuery = new Parse.Query(Parse.Installation);
  pushQuery.equalTo('user', sendToUser);
    
  Parse.Push.send({
   	where: pushQuery, // Set our Installation query
    	data: {
     	  alert: fromUserName + " shared location with you!",
        objectId: request.object.id
    	}
  	},
	  {
    	success: function() { },
    	error: function(error) {
      	throw "Got an error " + error.code + " : " + error.message;
    	}
  	});
  });
});


