import 'package:app/models/service_tree.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:get/state_manager.dart';

import 'package:app/controllers/services.dart';

class ServiceSearch extends SearchDelegate<ServiceTree> {
  final ServicesController controller = Get.put(ServicesController());
  Widget placeholder;

  @override
  ThemeData appBarTheme(BuildContext context) => Theme.of(context);

  ServiceSearch({this.placeholder, String hintText = 'Oil change...'}) : 
    super(searchFieldLabel: hintText, keyboardType: TextInputType.text);

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
    controller.params.value.q = query;
    return FutureBuilder(
      future: query == "" ? null : controller.load(),
      builder: (context, snapshot) {
        if (query == '') {
          if (placeholder != null) return placeholder;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 14),
                Text('Search for a service')
              ]
            )
          );
        } else {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator()
              )
            );
          } else {
            if (controller.items.length == 0) {
              return Center(
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: Icon(FontAwesomeIcons.mehRollingEyes),
                )
              );
            }
            return ListView.builder(
              itemBuilder: (context, index) => Card(
                child: ListTile(
                  title: Text(controller.items[index].label),
                  leading: Icon(FontAwesomeIcons.car),
                  onTap: () {
                    close(context, controller.items[index]);
                  },
                )
              ),
              itemCount: controller.items.length,
            );
          }
        }
      }   
    );
  }
}