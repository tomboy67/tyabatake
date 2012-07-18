var map;
var marker;
var geocoder;

function initialize(lat, lng) {
  var latlng = new google.maps.LatLng(lat, lng);
  var opts = {
  	zoom: 15,
  	center: latlng,
  	mapTypeId: google.maps.MapTypeId.ROADMAP
  };
  map = new google.maps.Map(document.getElementById("map_canvas"), opts);
  marker = new google.maps.Marker({
    position: latlng,
    map: map
  });
  geocoder = new google.maps.Geocoder();
  geocoder.geocode({'location': latlng}, GetAddress);
}

function SetLocation(lat, lng){
	$('span.geoLat').html(lat);
   	$('span.geoLng').html(lng);
   	var latlng = new google.maps.LatLng(lat,lng);
   	marker.setPosition(latlng);
	map.setCenter(latlng);
    geocoder.geocode({'location': latlng}, GetAddress);
}

function GetAddress(results, status){
	if (status == google.maps.GeocoderStatus.OK){
	  if (results[1]) {
	    document.getElementById("address").value = results[1].formatted_address;
	  }
	} else {
		alert("住所を取得できませんでした");
	}
}

