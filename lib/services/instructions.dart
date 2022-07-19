import 'package:http/http.dart' as http;
import 'dart:convert';

class Instructions {
  //var lat, lng;
  // RoadSpeedLimit(this.lat, this.lng);

  final mykey = 'AIzaSyDchoSlvd7X5B1mGJ3urtU1kL11iVhR8tU';

  Future getInstruction(var originLatlng, var destinationLatlng) async {
    var url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${originLatlng.latitude},${originLatlng.longitude}&destination=${destinationLatlng.latitude},${destinationLatlng.longitude}&key=$mykey';
    var response = await http.get(Uri.parse(url));
    var myJson = json.decode(response.body);
    print(".................Directions Info.........." + response.body.toString());
    var jsonResult = myJson['routes']['legs'];
    
    return print(".................Directions Info.........." + response.body);
  }
}
