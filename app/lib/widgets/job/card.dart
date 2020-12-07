import 'package:app/models/job.dart';
import 'package:app/models/media.dart';
import 'package:app/models/user.dart';
import 'package:flutter/material.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final Function onTap;
  final User user;

  const JobCard({Key key, @required this.job, @required this.onTap, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Media media;
    if (job.pictures.length > 0) media = job.pictures[0];
    else if (job.customer.user.avatar != null) media = job.customer.user.avatar;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            (
              media != null ? 
              Align(
                alignment: Alignment.centerLeft,
                child: Padding( 
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Ink.image(
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    image: NetworkImage(media.thumbUrl)
                  )
                )
              ) 
              : SizedBox.shrink()
            ),
            Expanded(child: Column(
              children: [
                ListTile(
                  title: Text(job.title ?? ''),
                  subtitle: Text(job.customer.user.username ?? ''),
                ),
                (
                  job.tasks.length > 0 ? 
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      children: job.tasks.where((task) => task.label != null).map((task) => Chip(label: Text(task.label))).toList(),
                    )
                  )
                  : SizedBox.shrink()
                ),
                (
                  job.vehicle != null && job.vehicle.type != null ?
                  Row(
                    children: [
                      Flexible(child: Text(job.vehicle.type.fullName.toUpperCase())),
                      (
                        job.vehicle.type.logo != null ? 
                        CircleAvatar(
                          backgroundImage: NetworkImage(job.vehicle.type.logo),
                        ) : SizedBox.shrink()
                      )
                    ]
                  ) :
                  SizedBox.shrink()
                ),
              ]
            ))
          ]
        )
      )
    );
  }
}