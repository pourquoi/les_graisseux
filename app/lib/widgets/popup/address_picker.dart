import 'package:flutter/material.dart';
import 'package:app/services/google/places.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/instance_manager.dart';
import 'package:geolocator/geolocator.dart';

class _CurrentLocation extends StatefulWidget {
  final Function onChange;
  final PlaceApiProvider placeApi = Get.find();

  _CurrentLocation({Key key, @required this.onChange}) : super(key: key);

  @override
  __CurrentLocationState createState() => __CurrentLocationState();
}

class __CurrentLocationState extends State<_CurrentLocation> {
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
          padding: EdgeInsets.symmetric(horizontal: 35),
          child: RaisedButton(
          onPressed: () async {
            if (loading) return;
            setState(() => loading = true);
            try {
              Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium, timeLimit: Duration(seconds: 3));
              print(position);
              Suggestion suggestion = await widget.placeApi.reverseGeocode(lat: position.latitude, lng: position.longitude);
              widget.onChange(suggestion);
            } catch(err) {
              print(err);
            }
            setState(() => loading = false);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              loading ? CircularProgressIndicator() : Padding(padding: EdgeInsets.only(right:10), child:Icon(FontAwesomeIcons.compass)),
              Text('Use my current location')
            ]
          )
          ))
        ]
      )
    );
  }
}
   
class AddressSearch extends SearchDelegate<Suggestion> {
  Widget placeholder;
  String sessionToken;
  PlaceApiProvider placeApi = Get.find();

  @override
  ThemeData appBarTheme(BuildContext context) => Theme.of(context);

  AddressSearch({this.placeholder, String hintText = 'Input your address'}) : 
    super(searchFieldLabel: hintText, keyboardType: TextInputType.streetAddress);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: query == "" ? null : placeApi.fetchSuggestions(query),
      builder: (context, snapshot) {
        if (query == '') {
          if (placeholder != null) return placeholder;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 14),
                _CurrentLocation(
                  onChange: (Suggestion suggestion) {
                    close(context, suggestion);
                  }
                )
              ]
            )
          );
        } else {
          if (snapshot.hasData) {
            if (snapshot.data.length == 0) {
              return Center(
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: Icon(FontAwesomeIcons.mehRollingEyes),
                )
              );
            }
            return ListView.builder(
              itemBuilder: (context, index) => Card(child:ListTile(
                title: Text(snapshot.data[index].description),
                leading: Icon(FontAwesomeIcons.mapMarkerAlt),
                onTap: () {
                  close(context, snapshot.data[index]);
                },
              )),
              itemCount: snapshot.data.length,
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator()
              )
            );
          } else {
            return Center(
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Icon(FontAwesomeIcons.heartBroken),
              )
            );
          }
        }
      }   
    );
  }
}