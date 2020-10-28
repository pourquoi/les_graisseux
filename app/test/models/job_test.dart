import 'package:app/models/job.dart';
import 'package:app/models/service_tree.dart';
import 'package:test/test.dart';

void main()
{
  test('job to json', () {
    Job job = new Job();
    ServiceTree task = new ServiceTree(id: 1, label: 'service');
    job.addTask(task);

    Map<String, dynamic> json = job.toJson();

    assert(json.containsKey('tasks'));

  });
}