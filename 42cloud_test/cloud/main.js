var _ = require('underscore');

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
Parse.Cloud.beforeSave(Parse.User, function(request, response) {
    
    request.object.set('validationKey', null);
    request.object.set('validationLastSent', new Date());
    request.object.set('validatedPhone', false);
    request.object.set('validationCount', 0);

    var phoneNumber = request.object.get('phone');

    if (!phoneNumber || phoneNumber == null || phoneNumber =='') { 
      response.error("User must have a phone number.");
      return;
    }

    var query = new Parse.Query(Parse.User);
    query.equalTo("phone", phoneNumber); // find users that match
    query.find({
      success: function (users) {
        if(users.length > 0) {
          response.error("User with phone number exists.");
        }
        else {
          response.success();
        }
      },
      error: function (error) {

      }
    });

});

/* User defaults and validation */
Parse.Cloud.beforeSave("Follow", function(request, response) {

    var fromUser = request.object.get('from');
    var toUser   = request.object.get('to');

    if (fromUser == null || toUser == null) {
      response.error("Following or follower cannot be blank.");
    }

    var query = new Parse.Query("Follow");
    query.equalTo("to", toUser); // find users that match
    query.equalTo("from", fromUser); // find users that match

    query.find({
      success: function (follows) {
        if(follows.length > 0) {
          response.error("Already following.");
        }
        else {
          response.success();
        }
      },
      error: function (error) {

      }
    });

});

/* User defaults and validation */
Parse.Cloud.afterSave("Follow", function(request, response) {

    var fromUser = request.object.get('from');
    var toUser   = request.object.get('to');

    if (fromUser == null || toUser == null) {
      response.error("Following or follower cannot be blank.");
    }

    var query = new Parse.Query("Follow");
    query.equalTo("to", fromUser); // find users that match
    query.equalTo("from", toUser); // find users that match

    fromUser.fetch().then(function(fromUserDetails) {
      var fromUserName = fromUserDetails.get('username');  
      var obj = {
            alert: fromUserName + " added you back!",
            objectId: request.object.id
      }

      sendPushNotification(toUser, obj);

    });


    query.find({
      success: function (follows) {
        if(follows.length > 0) {
          sendPushNotification(toUser, {
            alert: +' added you back!'
          })
        }
      },
      error: function (error) {

      }
    });

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
  user.set('validationKey', generateKey(4));

  // send via Twilio
  twilio.sendSms({
    from: TWILIO_NUMBER,
    to: user.get('phone'),
    body: "Your code is " + user.get('validationKey')
  },  function(err, responseData) {
    if (err) {
      console.log(err);
      response.error("Uh oh, something went wrong"); 

    } else { 
      console.log(responseData.from); 
      console.log(responseData.body);
      response.success("ok"); 
    }
  });

  // theoretical race condition where person tries to validate before the user object is saved
    // but that'll never happen, right?

  // Let us remember what just occured
  user.set('validationLastSent', new Date());
  user.set('validationCount', user.get('validationCount') + 1);
  user.save()
});

Parse.Cloud.define("validateSMSKey", function(request, response) {
    var user = Parse.User.current();
    var clientkey = request.params.validationKey;
    if (clientkey === user.get('validationKey')) {
        user.set('validatedPhone', true);
        user.set('validatedDate', new Date());
        user.save();
        response.success('1');
    } else {
        response.success('0');
    }
});

Parse.Cloud.define("searchUsers", function(request, response) {
  
  var searchQ = request.params.searchQuery;

  var query = new Parse.Query(Parse.User);
  query.startsWith("username", searchQ); // find users that match
  query.find({
      success: function (users) {
          response.success(users);
      },
      error: function (error) {
          //Show if no user was found to match
          console.log("Search error:" + error);
      }
  });

});

Parse.Cloud.afterSave("LocationSent", function(request) {

  // Our "LocationSent" class has a "text" key with the body of the comment itself
  var sendToUser = request.object.get('to');
  console.log("Sending to: " + sendToUser);
  var fromUser   = request.object.get('from');
  console.log(request.object.id);

  // check if the receiver is following the sender
  var query = new Parse.Query("Follow");
  query.equalTo("from", sendToUser); // find users that match
  query.equalTo("to", fromUser); // find users that match

  query.find({
      success: function (follows) {
          if (follows.length > 0) {
            
            request.object.get('from').fetch().then(function(fromUser) {
              var fromUserName = fromUser.get('username');  
              var obj = {
                    alert: fromUserName + " shared location with you!",
                    objectId: request.object.id
              }

              sendPushNotification(sendToUser, obj);

            });

          }
      },
      error: function (error) {
          //Show if no user was found to match
          console.log("Search error:" + error);
      }
  });


});


/* Object Sample 

{
          alert: fromUserName + " shared location with you!",
          objectId: request.object.id
        }

*/
function sendPushNotification(toUser, object) {
  
  var pushQuery = new Parse.Query(Parse.Installation);
  pushQuery.equalTo('user', toUser);
      
  Parse.Push.send({
        where: pushQuery, // Set our Installation query
        data: object
    },
    {
        success: function() { console.log("Push notification sent.")},
        error: function(error) {
          throw "Got an error " + error.code + " : " + error.message;
        }
    });
}



Parse.Cloud.define("getLocationReceived", function(request, response) {

  var queryFollowing =  new Parse.Query("Follow");
  queryFollowing.equalTo('from', Parse.User.current());
  queryFollowing.find({
      success: function (follows) {
        
        var users = _.map(follows,function(follow) {
          return follow.get('to');
        });
        
        console.log(users);

        var query = new Parse.Query("LocationSent");
        query.equalTo('to', Parse.User.current());
        query.containedIn('from', users);
        query.include('from');
        query.limit = 40;
        query.find({
            success: function (locations) {
                response.success(locations);
            },
            error: function (error) {
                //Show if no user was found to match
                console.log("Getting locations error:" + error);
            }
        });

      },
      error: function (error) {
          //Show if no user was found to match
          console.log("Getting followers error:" + error);
      }
  });

});

