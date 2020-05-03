import 'package:dadguide2/components/config/settings_manager.dart';
import 'package:dadguide2/components/images/icons.dart';
import 'package:dadguide2/components/images/images.dart';
import 'package:dadguide2/components/models/data_objects.dart';
import 'package:dadguide2/components/models/enums.dart';
import 'package:dadguide2/components/notifications/tracking.dart';
import 'package:dadguide2/components/ui/lists.dart';
import 'package:dadguide2/components/ui/navigation.dart';
import 'package:dadguide2/components/utils/formatting.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/screens/dungeon/dungeon_search_bloc.dart';
import 'package:dadguide2/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

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
            Fimber.e('Error listing dungeons', ex: snapshot.error);
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

          return ScrollableStackWidget(
            numItems: data.length,
            builder: (_, controller, listener) => ScrollablePositionedList.separated(
              itemCount: listItems.length,
              separatorBuilder: (context, index) =>
                  listItems[index] is DungeonRowItem ? Divider(height: 0) : Container(),
              itemBuilder: (context, index) {
                var item = listItems[index];
                if (item is HeadingItem) {
                  return Container(
                    color: grey(context, 300),
                    child: Center(
                        child: Padding(padding: EdgeInsets.all(4), child: Text(item.section.name))),
                  );
                } else if (item is DungeonRowItem) {
                  return DungeonListRow(item.model);
                } else {
                  throw 'Unexpected item type';
                }
              },
              itemScrollController: controller,
              itemPositionsListener: listener,
            ),
          );
        });
  }
}

/// A row representing a dungeon.
class DungeonListRow extends StatelessWidget {
  final ListDungeon model;

  const DungeonListRow(this.model, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TrackingNotifier>(create: (context) => TrackingNotifier()),
        Consumer<TrackingNotifier>(
          builder: (context, trackedNotifier, __) => InkWell(
            onLongPress: () async {
              var isTracked = Prefs.trackedDungeons.contains(model.dungeon.dungeonId);
              await showDungeonMenu(context, model.dungeon.dungeonId, isTracked);
              trackedNotifier.trackingChanged();
            },
            onTap: goToDungeonFn(context, model.dungeon.dungeonId, null),
            child: DungeonListRowContents(model),
          ),
        ),
      ],
    );
  }
}

/// The contents of a row representing a dungeon.
class DungeonListRowContents extends StatelessWidget {
  final ListDungeon model;

  const DungeonListRowContents(this.model, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isTracked = Prefs.trackedDungeons.contains(model.dungeon.dungeonId);
    var d = model.dungeon;
    var m = model.iconMonster;

    return Container(
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
                        if (isTracked) TrackedChip(),
                        Spacer(),
                        typeContainer(m?.type1Id, size: 18, leftPadding: 4),
                        typeContainer(m?.type2Id, size: 18, leftPadding: 4),
                        typeContainer(m?.type3Id, size: 18, leftPadding: 4),
                      ])),
                  FittedBox(alignment: Alignment.centerLeft, child: Text(model.name())),
                  DefaultTextStyle(
                    style: Theme.of(context).textTheme.caption,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconAndText(DadGuideIcons.mp,
                            model.maxAvgMp != null ? commaFormat(model.maxAvgMp) : null),
                        SizedBox(width: 8),
                        IconAndText(DadGuideIcons.srank,
                            model.maxScore != null ? commaFormat(model.maxScore) : null),
                        Spacer(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
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
