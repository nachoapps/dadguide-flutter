import 'package:dadguide2/components/enums.dart';
import 'package:dadguide2/components/formatting.dart';
import 'package:dadguide2/components/icons.dart';
import 'package:dadguide2/components/images.dart';
import 'package:dadguide2/components/navigation.dart';
import 'package:dadguide2/data/data_objects.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/screens/dungeon/dungeon_search_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Parent class for rows in the dungeon list.
abstract class ListItem {}

/// A ListItem that contains data to display a heading.
class HeadingItem implements ListItem {
  final DungeonSubSection section;

  HeadingItem(this.section);
}

/// A ListItem that contains data to display an event row.
class EventRowItem implements ListItem {
  final ListDungeon model;

  EventRowItem(this.model);
}

List<ListItem> rowsToListItems(List<ListDungeon> events, DungeonTabKey tabKey) {
  if (events.isEmpty) {
    return [];
  }

  var results = <ListItem>[];
  results.add(HeadingItem(DungeonSubSection.full_list));
  results.addAll(events.map((m) => EventRowItem(m)));

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

          return ListView.builder(
            itemCount: listItems.length,
            itemBuilder: (context, index) {
              var item = listItems[index];
              if (item is HeadingItem) {
                return Container(
                  color: Colors.grey[300],
                  child: Center(
                      child: Padding(padding: EdgeInsets.all(4.0), child: Text(item.section.name))),
                );
              } else if (item is EventRowItem) {
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
    return InkWell(
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
                          Spacer(),
                          typeContainer(m?.type1Id, size: 18, leftPadding: 4),
                          typeContainer(m?.type2Id, size: 18, leftPadding: 4),
                          typeContainer(m?.type3Id, size: 18, leftPadding: 4),
                        ])),
                    FittedBox(alignment: Alignment.centerLeft, child: Text(_model.name())),
                    DefaultTextStyle(
                      style: Theme.of(context).textTheme.caption,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconAndText(DadGuideIcons.mp,
                              _model.maxAvgMp != null ? commaFormat(_model.maxAvgMp) : null),
                          SizedBox(width: 8),
                          IconAndText(DadGuideIcons.srank,
                              _model.maxScore != null ? commaFormat(_model.maxScore) : null),
                          Spacer(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
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
