Parse.Cloud.define("changeUsername", function(request, response) {


	Parse.User.become("session-token-here").then(function (user) {
	  console.log('user');
	  console.log(user);
	}, function (error) {
	  console.log('could not get user');
	});


});


