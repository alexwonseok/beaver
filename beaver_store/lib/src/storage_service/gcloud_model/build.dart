import 'package:gcloud/db.dart';

@Kind()
class BeaverBuild extends Model {
  @StringProperty()
  String projectName;

  @IntProperty()
  int number;

  @BlobProperty()
  List<int> triggerData;

  @StringProperty()
  String triggerType;

  @StringProperty()
  String triggerHeaders;

  @StringProperty()
  String parsedTriggerEvent;

  @StringProperty()
  String parsedTriggerUrl;

  @StringProperty()
  String taskInstance;

  @StringProperty()
  String taskInstanceStatus;

  @StringProperty()
  String taskStatus;

  @StringProperty()
  String taskConfigCloudType;

  @StringProperty()
  String taskConfigCloudSettings;

  @BlobProperty()
  List<int> taskLog;
}
