angular.module('starter.controllers', [])

.controller('DashCtrl', function($scope, $http) {
  // $scope.url = "http://192.168.29.177:4001";
  // $scope.url = "http://localhost:4001";
  // $scope.url = "http://192.168.24.1:4001";
  $scope.url = "//"+location.host.split(":")[0] + ":4001";
  $scope.ssids = [];

  $http.get($scope.url + "/scan").then(function(response){
      $scope.ssids = response.data;
      console.log(response.data);
    }, function(error){
      console.log(error);
  });
  $scope.email = document.getElementById("emailbox");
  $scope.pwd = document.getElementById("pwdbox");
  $scope.ssid = document.getElementById("ssidselector");
  $scope.psk = document.getElementById("pskbox");
  $scope.server = document.getElementById("server_box");
  $scope.server.value = "http://staging.farmbot.io/"

  $scope.submitButton = function(){
    var email = $scope.email.value;
    var pwd = $scope.pwd.value;
    var server = $scope.server.value;
    var ssid = $scope.ssid.value;
    var psk = $scope.psk.value;
    json = { "email" : email,
           	 "password": pwd,
           	 "server": server,
           	 "wifi": { "ssid": ssid,
           		         "psk": psk} };
    console.log(JSON.stringify(json));
    if(json.email == "" || json.pwd == "" || json.ssid == "" || json.psk == ""){
      // i suck at javascript
      console.log("NO");
    } else {
      console.log("YES");
      $http.post($scope.url + "/login", json).then(function(response){
          $scope.ssids = response.data;
          console.log(response.data);
        }, function(error){
          console.log(error);
      });
    }
  };
})

.controller('ChatsCtrl', function($scope, Chats) {
  // With the new view caching in Ionic, Controllers are only called
  // when they are recreated or on app start, instead of every page change.
  // To listen for when this page is active (for example, to refresh data),
  // listen for the $ionicView.enter event:
  //
  //$scope.$on('$ionicView.enter', function(e) {
  //});

  $scope.chats = Chats.all();
  $scope.remove = function(chat) {
    Chats.remove(chat);
  };
})

.controller('ChatDetailCtrl', function($scope, $stateParams, Chats) {
  $scope.chat = Chats.get($stateParams.chatId);
})

.controller('AccountCtrl', function($scope) {
  $scope.settings = {
    enableFriends: true
  };
});
