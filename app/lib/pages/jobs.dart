import 'package:app/controllers/jobs.dart';
import 'package:app/widgets/ui/drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app/routes.dart' as routes;

class _PublicJobsController extends JobsController {}

class JobsPage extends StatefulWidget
{
  final _PublicJobsController controller = Get.put(_PublicJobsController());

  _JobsPageState createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  void initState() {
    super.initState();  
    widget.controller.load();
  }

  Widget build(BuildContext context) {
      return Scaffold(
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
                      Text('background 1'),
                      Text('background 2')
                    ]
                  )
                ),
                
                stretchModes: <StretchMode>[
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                  StretchMode.fadeTitle,
                ],
                title: Text('flexible')
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
        Get.toNamed(routes.job.replaceFirst(':job', widget.controller.items[idx].id.toString()));
      },
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Text('${widget.controller.items[idx].id} ${idx}' +
          (widget.controller.items[idx].title ?? '')))
    );
  }
}
