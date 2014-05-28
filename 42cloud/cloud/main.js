Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

Parse.Cloud.afterSave("LocationSent", function(request) {

  // Our "LocationSent" class has a "text" key with the body of the comment itself
  var sendToUser = request.object.get('to');
  var fromUser   = request.object.get('from');

  var pushQuery = new Parse.Query(Parse.Installation);
  pushQuery.equalTo('user', sendToUser);
    
  Parse.Push.send({
    where: pushQuery, // Set our Installation query
    data: {
      alert: fromUser.get('username') + " shared location with you!"
    }
  }, {
    success: function() {
      // Push was successful
    },
    error: function(error) {
      throw "Got an error " + error.code + " : " + error.message;
    }
  });
});


