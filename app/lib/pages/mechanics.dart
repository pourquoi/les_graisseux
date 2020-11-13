import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app/routes.dart' as routes;
import 'package:app/controllers/mechanics.dart';
import 'package:app/widgets/ui/drawer.dart';

class MechanicsPage extends StatefulWidget
{
  final MechanicsController controller = Get.put(MechanicsController());

  _MechanicsPageState createState() => _MechanicsPageState();
}

class _MechanicsPageState extends State<MechanicsPage> 
{
  void initState() {
    super.initState();
    widget.controller.load();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mechanics')),
      body: SafeArea(
        child:
          Obx(() {
            return ListView.builder(
              itemCount: widget.controller.items.length + 1,
              itemBuilder: (_, idx) {
                if (idx < widget.controller.items.length)
                  return buildRow(idx);
                else if (idx == widget.controller.items.length) {
                  if (widget.controller.pagination.value.next != null) {
                    widget.controller.more();
                    return Center(child:CircularProgressIndicator());
                  } else {
                    return Container(
                      color: Colors.blueGrey,
                      child: Center(child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text('end of results'.toUpperCase(), style: TextStyle(color: Colors.grey, fontSize: 10))
                      ))
                    );
                  }
                } else {
                  return Container();
                }
              },
            );
          }),
      )
    );
  }

  Widget buildRow(idx) {
    return GestureDetector(
        onTap: () {
          Get.toNamed(routes.mechanic.replaceFirst(':mechanic', widget.controller.items[idx].id.toString()));
        },
        child: Column(
          children: [
            Row(
              children: [
                Obx(() => (widget.controller.items[idx].user.avatar != null && widget.controller.items[idx].user.avatar.thumbUrl != null) ? 
                  Ink.image(
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    image: NetworkImage(widget.controller.items[idx].user.avatar.thumbUrl)
                  ) :
                  Icon(Icons.person, size: 72)
                ),
                Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('${idx}' + (widget.controller.items[idx].user.username ?? '-'), style: TextStyle(fontSize: 20))
                )
              ]
            )
          ]
        )
    );
  }
}