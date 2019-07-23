import 'package:dadguide2/components/version_info.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

Future<void> sendMonsterErrorEmail(Monster monster) async {
  return sendErrorEmail('[Monster ${monster.monsterId}] ${monster.nameNa}');
}

Future<void> sendDungeonErrorEmail(Dungeon dungeon, SubDungeon subDungeon) async {
  return sendErrorEmail('[No.${subDungeon.subDungeonId}] ${dungeon.nameNa}');
}

Future<void> sendErrorEmail(String subject) async {
  var info = await getVersionInfo();
  var body = '[${info.platformVersion} - ${info.projectVersion}(${info.projectCode})';
  body += '\n\nPlease describe the issue below:\n';

  var email = Email(
    subject: subject,
    body: body,
    recipients: ['tactical0retreat@gmail.com'],
  );
  await FlutterEmailSender.send(email);
}
