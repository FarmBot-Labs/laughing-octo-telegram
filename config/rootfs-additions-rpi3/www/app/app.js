var phonecatApp = angular.module('phonecatApp', []);

// Define the `PhoneListController` controller on the `phonecatApp` module
phonecatApp.controller('PhoneListController', function PhoneListController($scope, $http) {
  $scope.ssids = [];

  $scope.url = "http://" + location.host.split(":")[0] + ":4000"
  $http.get($scope.url + "/scan").then(function(resp){
    console.log(resp.data);
    $scope.ssids = resp.data;
  }).catch(function(error){
    console.log("not running on device?");
    $scope.ssids = ["test_ssid", "meep", "lawl"];
  })

  $scope.select_ssid = function(ssid){
    document.getElementById("wifissid").value = ssid;
  };

  $scope.submit = function(){

    ssid = document.getElementById("wifissid").value;
    psk = document.getElementById("wifipsk").value;
    email = document.getElementById("fbemail").value;
    password = document.getElementById("fbpwd").value;
    username = document.getElementById("fbserver").value;
    if(ssid != ""){
      json = {
        "email": email,
        "password": password,
        "wifi":{ "ssid": ssid, "psk": psk}
      };
      console.log(JSON.stringify(json));
      $http({
        method: 'POST',
        url: $scope.url + "/login",
        headers: [{'application': 'x-javascript'},
                  {'Content-Type': 'application/json'}]
      }).then(function(resp){
        console.log("Should never see this...");
      }).catch(function(error){
        console.log("will probably see this a lot...");
      });
    } else{
      console.log("write some better error handling n00b.")
    }
  };
});
