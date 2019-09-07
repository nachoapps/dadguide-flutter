import 'package:dadguide2/components/version_info.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

// TODO: needs localization

/// Launches the device email client with an error mail pre-populated with monster data.
Future<void> sendMonsterErrorEmail(Monster monster) async {
  return sendErrorEmail('[Monster ${monster.monsterId}] ${monster.nameNa}');
}

/// Launches the device email client with an error mail pre-populated with dungeon data.
Future<void> sendDungeonErrorEmail(Dungeon dungeon, SubDungeon subDungeon) async {
  return sendErrorEmail('[No.${subDungeon.subDungeonId}] ${dungeon.nameNa}');
}

/// Launches the device email client with an error email.
Future<void> sendErrorEmail(String subject) async {
  var info = await getVersionInfo();
  var body = '[${info.platformVersion} - ${info.projectVersion}(${info.projectCode})]';
  body += '\n\nPlease describe the issue below:\n';

  var email = Email(
    subject: subject,
    body: body,
    recipients: ['tactical0retreat@gmail.com'],
  );
  await FlutterEmailSender.send(email);
}

/// Launches the device email client with an feedback email.
Future<void> sendFeedback() async {
  var info = await getVersionInfo();
  var body = '[${info.platformVersion} - ${info.projectVersion}(${info.projectCode})]\n';

  var email = Email(
    subject: 'Feedback',
    body: body,
    recipients: ['tactical0retreat@gmail.com'],
  );
  await FlutterEmailSender.send(email);
}
