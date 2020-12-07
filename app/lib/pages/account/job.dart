import 'package:app/controllers/account/job.dart';
import 'package:app/controllers/job.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountJobPage extends StatelessWidget
{
  final AccountJobController controller = Get.put(AccountJobController());

  AccountJobPage({Key key}) : super(key: key) {
    controller.load(int.parse(Get.parameters['job']));
  }

  Widget build(BuildContext context) {
    return Obx( () {
      if (controller.job.value.id != null) {
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              bottom: TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.directions_car), text: 'Job'),
                  Tab(icon: Icon(Icons.directions_transit), text: 'Messages'),
                  Tab(icon: Icon(Icons.directions_bike)),
                ],
              ),
              title: Text(controller.job.value.title),
            ),
            body: TabBarView(
              children: [
                Column(
                  children: [
                    Center(child: Text(controller.job.value.title)),
                    Row(
                      children: controller.job.value.tasks.map((task) => Text(task.label)).toList()
                    )
                  ],
                ),
                Icon(Icons.directions_transit),
                Column(
                  children: [
                    Obx(() {
                      if (controller.job.value.pictures.length > 0) {
                        return Container(
                          height: 150,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(controller.job.value.pictures[0].thumbUrl),
                              fit: BoxFit.cover
                            )
                          )
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    }),
                  ],
                )
              ],
            ),
          ),
        );
      } else {
        return CircularProgressIndicator();
      }
    });
    
  }
}
