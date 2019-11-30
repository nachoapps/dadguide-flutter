import 'package:dadguide2/components/enums.dart';
import 'package:dadguide2/components/formatting.dart';
import 'package:dadguide2/components/icons.dart';
import 'package:dadguide2/components/images.dart';
import 'package:dadguide2/components/navigation.dart';
import 'package:dadguide2/components/settings_manager.dart';
import 'package:dadguide2/data/data_objects.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/screens/dungeon/dungeon_search_bloc.dart';
import 'package:dadguide2/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:provider/provider.dart';
import 'package:fimber/fimber.dart';

/// Parent class for rows in the dungeon list.
abstract class ListItem {}

/// A ListItem that contains data to display a heading.
class HeadingItem implements ListItem {
  final DungeonSubSection section;

  HeadingItem(this.section);
}

/// A ListItem that contains data to display an event row.
class DungeonRowItem implements ListItem {
  final ListDungeon model;

  DungeonRowItem(this.model);
}

List<ListItem> rowsToListItems(List<ListDungeon> events, DungeonTabKey tabKey) {
  if (events.isEmpty) {
    return [];
  }

  var results = <ListItem>[];
  results.add(HeadingItem(DungeonSubSection.full_list));
  results.addAll(events.map((m) => DungeonRowItem(m)));

  return results;
}

/// List of dungeons to display; a stream because this updates as the user clicks on the various
/// bottom tab options.
class DungeonList extends StatelessWidget {
  DungeonList({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);
    var displayState = Provider.of<DungeonDisplayState>(context);
    return StreamBuilder<List<ListDungeon>>(
        stream: displayState.searchBloc.searchResults,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Icon(Icons.error));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: CircularProgressIndicator());
          }

          var data = snapshot.data;
          var listItems = rowsToListItems(data, displayState.tab);
          if (listItems.isEmpty) {
            return Center(child: Text(loc.noData));
          }

          return ListView.separated(
            itemCount: listItems.length,
            separatorBuilder: (context, index) =>
                listItems[index] is DungeonRowItem ? Divider(height: 0) : Container(),
            itemBuilder: (context, index) {
              var item = listItems[index];
              if (item is HeadingItem) {
                return Container(
                  color: grey(context, 300),
                  child: Center(
                      child: Padding(padding: EdgeInsets.all(4.0), child: Text(item.section.name))),
                );
              } else if (item is DungeonRowItem) {
                return DungeonListRow(item.model);
              } else {
                throw 'Unexpected item type';
              }
            },
          );
        });
  }
}

/// A row representing a dungeon.
class DungeonListRow extends StatelessWidget {
  final ListDungeon _model;

  const DungeonListRow(this._model, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var d = _model.dungeon;
    var m = _model.iconMonster;

    /// Need to use Consumer and thus MultiProvider because the showDungeonMenu function is not a child of the Provider and needs the Provider
    return MultiProvider(providers: [
      ChangeNotifierProvider<DungeonTracked>(builder: (context) => DungeonTracked(d.dungeonId)),
      Consumer<DungeonTracked>(
          builder: (_, dungeonTracked, __) => InkWell(
                onLongPress: () {
                  showDungeonMenu(context, d.dungeonId, dungeonTracked);
                },
                onTap: goToDungeonFn(context, d.dungeonId, null),
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                    child: Row(
                      children: <Widget>[
                        PadIcon(d.iconId),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DefaultTextStyle(
                                  style: Theme.of(context).textTheme.caption,
                                  child: Row(children: [
                                    DungeonMiniInfo(d.dungeonId),
                                    Spacer(),
                                    typeContainer(m?.type1Id, size: 18, leftPadding: 4),
                                    typeContainer(m?.type2Id, size: 18, leftPadding: 4),
                                    typeContainer(m?.type3Id, size: 18, leftPadding: 4),
                                  ])),
                              FittedBox(
                                  alignment: Alignment.centerLeft, child: Text(_model.name())),
                              DefaultTextStyle(
                                style: Theme.of(context).textTheme.caption,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconAndText(
                                        DadGuideIcons.mp,
                                        _model.maxAvgMp != null
                                            ? commaFormat(_model.maxAvgMp)
                                            : null),
                                    SizedBox(width: 8),
                                    IconAndText(
                                        DadGuideIcons.srank,
                                        _model.maxScore != null
                                            ? commaFormat(_model.maxScore)
                                            : null),
                                    Spacer(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
              ))
    ]);
  }
}

/// Used to display srank/mp icons next to their values.
class IconAndText extends StatelessWidget {
  final Widget _icon;
  final String _text;

  IconAndText(this._icon, this._text);

  @override
  Widget build(BuildContext context) {
    if (_text == null) return Container(width: 0.0, height: 0.0);

    return Row(children: [
      _icon,
      Text(_text, style: Theme.of(context).textTheme.caption),
    ]);
  }
}

/// Displays the menu, trigger by a long press of the dungeon row.
showDungeonMenu(BuildContext context, int dungeonId, DungeonTracked dungeonTracked) {
  String addOrRemoveText =
      !dungeonTracked.tracked ? "Alert when dungeon is available." : "Untrack this dungeon";
  showMenu(position: buttonMenuPosition(context), context: context, items: [
    PopupMenuItem(
      child: Text(addOrRemoveText),
      value: dungeonId,
    )
  ]).then((value) {
    if (!dungeonTracked.tracked) {
      try {
        Prefs.addTrackedDungeon(dungeonId);
        dungeonTracked.tracked = true;
        Fimber.i('Added dungeonId $dungeonId to tracked dungeons');
      } catch (e, stacktrace) {
        Fimber.i("Unable to add dungeonId to tracked list.", ex: e, stacktrace: stacktrace);
      }
    } else {
      try {
        Prefs.removeTrackedDungeon(dungeonId);
        dungeonTracked.tracked = false;
        Fimber.i('Removed dungeonId $dungeonId from tracked dungeons');
      } catch (e, stacktrace) {
        Fimber.i("Unable to remove dungeonId from tracked list.", ex: e, stacktrace: stacktrace);
      }
    }
  });
}

/// showMenu() needs to be given the menu position as a parameter. This calculates where the context's Widget was on the screen.
RelativeRect buttonMenuPosition(BuildContext c) {
  final RenderBox bar = c.findRenderObject();
  final RenderBox overlay = Overlay.of(c).context.findRenderObject();
  final RelativeRect position = RelativeRect.fromRect(
    Rect.fromPoints(
      bar.localToGlobal(bar.size.centerLeft(Offset.zero), ancestor: overlay),
      bar.localToGlobal(bar.size.centerLeft(Offset.zero), ancestor: overlay),
    ),
    Offset.zero & overlay.size,
  );
  return position;
}

/// For the DungeonTracked provider
class DungeonTracked with ChangeNotifier {
  final initialTracked;
  bool _tracked;

  DungeonTracked(this.initialTracked) : _tracked = Prefs.trackedDungeons.contains(initialTracked);

  bool get tracked => _tracked;

  set tracked(bool value) {
    _tracked = value;
    notifyListeners();
  }
}

/// This is the area on the left in the line above the dungeon name
class DungeonMiniInfo extends StatelessWidget {
  final int dungeonId;

  const DungeonMiniInfo(this.dungeonId, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool _tracked = Provider.of<DungeonTracked>(context).tracked;
    return Row(children: [
      if (_tracked)
        Container(
          padding: EdgeInsets.all(3),
          child:
              Text("Tracking", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            color: Theme.of(context).primaryColor,
          ),
        )
    ]);
  }
}
