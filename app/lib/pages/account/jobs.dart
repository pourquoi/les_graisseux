import 'package:app/controllers/jobs.dart';
import 'package:app/controllers/user.dart';
import 'package:app/models/user.dart';
import 'package:app/widgets/ui/drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app/routes.dart' as routes;

class _AccountJobsController extends JobsController {}

class AccountJobsPage extends StatefulWidget
{
  final _AccountJobsController controller = Get.put(_AccountJobsController());
  final UserController userController = Get.find();

  _AccountJobsPageState createState() => _AccountJobsPageState();
}

class _AccountJobsPageState extends State<AccountJobsPage> {

  void initState() {
    super.initState();
    widget.controller.params.value.user = widget.userController.user.value.id;
    widget.controller.load();
  }

  Widget build(BuildContext context) {
      return Scaffold(
        floatingActionButton: IconButton(icon: Icon(Icons.add), onPressed: () {
          Get.toNamed(routes.onboarding, arguments: {'type': ProfileType.Customer});
        }),
        drawer: AppDrawer(),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
              
              floating: true,
              snap: false,
              actions: <Widget>[
                IconButton(icon: Icon(Icons.settings), onPressed: null)
              ],
              pinned: true,
              expandedHeight: 150.0,
              flexibleSpace: FlexibleSpaceBar(
                background: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                    ]
                  )
                ),
                
                stretchModes: <StretchMode>[
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                  StretchMode.fadeTitle,
                ],
                title: Text('My jobs')
              ),
            ),
            Obx( () =>
              SliverList(
                

                delegate: SliverChildBuilderDelegate(
                  (context, idx) {
                      
                        if (idx < widget.controller.items.length)
                          return buildRow(context, idx);
                        else if (idx == widget.controller.items.length) {
                          if (widget.controller.pagination.value.next != null) {
                            widget.controller.more();
                            return CircularProgressIndicator();
                          } else {
                            return Text('1');
                          }
                        } else {
                          return Text('2');
                        }
                      
                    
                  },
                  childCount: widget.controller.items.length + 1
                )
                
                ),
            )
            
            
                
            

          ],
        )
      );
  }

  Widget buildRow(BuildContext context, int idx) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(routes.account_job.replaceFirst(':job', widget.controller.items[idx].id.toString()));
      },
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Text('${widget.controller.items[idx].id} ${idx}' +
          (widget.controller.items[idx].title ?? '')))
    );
  }
}
