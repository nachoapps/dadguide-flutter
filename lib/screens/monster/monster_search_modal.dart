import 'package:dadguide2/components/enums.dart';
import 'package:dadguide2/components/icons.dart';
import 'package:dadguide2/components/images.dart';
import 'package:dadguide2/components/navigation.dart';
import 'package:dadguide2/data/data_objects.dart';
import 'package:dadguide2/data/database.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/screens/monster/monster_search_bloc.dart';
import 'package:dadguide2/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Displays controls that allow the user to filter the monster list.
class FilterMonstersScreen extends StatelessWidget {
  final FilterMonstersArgs args;

  FilterMonstersScreen(this.args);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: args.displayState,
      child: Column(
        children: [
          FilterMonstersTopBar(),
          Expanded(child: SingleChildScrollView(child: FilterWidget())),
          FilterMonstersBottomBar(),
        ],
      ),
    );
  }
}

/// Contains a back button and screen title.
class FilterMonstersTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);
    var displayState = Provider.of<MonsterDisplayState>(context);

    return Container(
        color: Colors.blue,
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Row(
          children: [
            SizedBox(
                width: 32,
                height: 32,
                child: InkWell(
                  child: Icon(Icons.chevron_left),
                  onTap: () => Navigator.of(context).pop(displayState),
                )),
            Expanded(child: Center(child: Text(loc.monsterFilterModalTitle))),
            SizedBox(width: 32, height: 32),
          ],
        ));
  }
}

/// Contains a close button; just an alias for the back button.
class FilterMonstersBottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);
    var displayState = Provider.of<MonsterDisplayState>(context);

    return SizedBox(
      height: 32,
      child: Container(
          color: Colors.grey,
          padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Row(
            children: [
              FlatButton(
                child: Text(loc.close),
                onPressed: () => Navigator.of(context).pop(displayState),
              ),
              Spacer(),
              FlatButton(
                child: Text(loc.monsterFilterModalReset),
                onPressed: () {
                  displayState.filterArgs = MonsterFilterArgs();
                  displayState.sortType = MonsterSortType.released;
                  displayState.sortAsc = false;
                  displayState.notify();
                },
              ),
            ],
          )),
    );
  }
}

class FilterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinksRow(),
        SizedBox(height: 4),
        AttributeFilterRow(),
        Divider(),
        RarityCostFilterRow(),
        Divider(),
        TypeSeriesFilterRow(),
        Divider(),
        AwokenSkillsFilterRow(),
        Divider(),
        ActiveSkillTagsRow(),
        Divider(),
        LeaderSkillTagsRow(),
      ],
    );
  }
}

class LinksRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Spacer(),
        ActionChip(
          onPressed: () => launch('https://ilmina.com/#/ADVANCED_SEARCH'),
          label: Text('Ilmina'),
          avatar: Icon(Icons.open_in_new),
        ),
        SizedBox(width: 8),
        ActionChip(
          onPressed: () => launch('http://www.puzzledragonx.com/en/monsterbook.asp'),
          label: Text('PDX'),
          avatar: Icon(Icons.open_in_new),
        ),
        SizedBox(width: 8),
        ActionChip(
          onPressed: () => launch('http://pad.skyozora.com/pets'),
          label: Text('Skyo'),
          avatar: Icon(Icons.open_in_new),
        ),
      ],
    );
  }
}

class AttributeFilterRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);
    var displayState = Provider.of<MonsterDisplayState>(context);
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
              child: AttributeSection(
                  loc.monsterFilterModalMainAttr, displayState.filterArgs.mainAttr)),
          VerticalDivider(thickness: 1, color: grey(context, 300)),
          Expanded(
              child:
                  AttributeSection(loc.monsterFilterModalSubAttr, displayState.filterArgs.subAttr)),
        ],
      ),
    );
  }
}

class AttributeSection extends StatelessWidget {
  final String _title;
  final List<int> _selectedAttrs;

  const AttributeSection(this._title, this._selectedAttrs, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(_title),
        SizedBox(height: 4),
        Row(
          children: [
            ColorButton(OrbType.fire.id, _selectedAttrs, DadGuideIcons.fire),
            ColorButton(OrbType.water.id, _selectedAttrs, DadGuideIcons.water),
            ColorButton(OrbType.wood.id, _selectedAttrs, DadGuideIcons.wood),
            ColorButton(OrbType.light.id, _selectedAttrs, DadGuideIcons.light),
            ColorButton(OrbType.dark.id, _selectedAttrs, DadGuideIcons.dark),
          ],
        ),
      ],
    );
  }
}

var greyscaleFilter = ColorFilter.matrix([
  .33, .59, .11, 0, 0, // red
  .33, .59, .11, 0, 0, //green
  .33, .59, .11, 0, 0, // blue
  .33, .59, .11, 1, 0, // alpha
]);

class ColorButton extends StatelessWidget {
  final int _attr;
  final List<int> _selectedAttrs;
  final Image _image;
  const ColorButton(this._attr, this._selectedAttrs, this._image, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var displayState = Provider.of<MonsterDisplayState>(context);
    var widget = _selectedAttrs.contains(_attr)
        ? _image
        : ColorFiltered(colorFilter: greyscaleFilter, child: _image);
    return Expanded(
      child: GestureDetector(
        child: widget,
        onTap: () {
          if (_selectedAttrs.contains(_attr)) {
            _selectedAttrs.remove(_attr);
          } else {
            _selectedAttrs.add(_attr);
          }
          displayState.notify();
        },
      ),
    );
  }
}

class RarityCostFilterRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);
    var displayState = Provider.of<MonsterDisplayState>(context);
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
              child: MinMaxSection(loc.monsterFilterModalRarity, displayState.filterArgs.rarity)),
          VerticalDivider(thickness: 1, color: grey(context, 300)),
          Expanded(child: MinMaxSection(loc.monsterFilterModalCost, displayState.filterArgs.cost)),
        ],
      ),
    );
  }
}

class MinMaxSection extends StatelessWidget {
  final String title;
  final MinMax minMax;

  const MinMaxSection(this.title, this.minMax, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title),
        SizedBox(height: 4),
        Row(
          children: [
            Flexible(
                child: BoxedInput(TextInputType.number, minMax.min?.toString() ?? '',
                    (v) => minMax.min = v.trim() == '' ? null : int.parse(v))),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text('~'),
            ),
            Flexible(
                child: BoxedInput(TextInputType.number, minMax.max?.toString() ?? '',
                    (v) => minMax.max = v.trim() == '' ? null : int.parse(v))),
          ],
        ),
      ],
    );
  }
}

class BoxedInput extends StatelessWidget {
  final String _text;
  final ValueChanged<String> _onChanged;
  final TextInputType _textInputType;

  const BoxedInput(this._textInputType, this._text, this._onChanged, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: TextFormField(
        keyboardType: _textInputType,
        initialValue: _text,
        onChanged: _onChanged,
        decoration: InputDecoration(
          border: new OutlineInputBorder(borderRadius: new BorderRadius.circular(2.0)),
          focusedBorder: new OutlineInputBorder(borderRadius: new BorderRadius.circular(2.0)),
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          fillColor: grey(context, 200),
          filled: true,
        ),
      ),
    );
  }
}

class TypeSeriesFilterRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(child: TypeFilterSection()),
          VerticalDivider(thickness: 1, color: grey(context, 300)),
          Expanded(child: SeriesFilterSection()),
        ],
      ),
    );
  }
}

class SeriesFilterSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);
    var displayState = Provider.of<MonsterDisplayState>(context);

    return Column(children: [
      Text(loc.monsterFilterModalSeries),
      BoxedInput(TextInputType.text, displayState.filterArgs.series,
          (v) => displayState.filterArgs.series = v)
    ]);
  }
}

class TypeFilterSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);
    var displayState = Provider.of<MonsterDisplayState>(context);

    return Column(
      children: [
        Text(loc.monsterFilterModalType),
        SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (var monsterType in MonsterType.all)
              TypeButton(monsterType.id, displayState.filterArgs.types,
                  typeContainer(monsterType.id, size: 20)),
          ],
        ),
      ],
    );
  }
}

class TypeButton extends StatelessWidget {
  final int _type;
  final List<int> _selectedTypes;
  final Widget _image;
  const TypeButton(this._type, this._selectedTypes, this._image, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var displayState = Provider.of<MonsterDisplayState>(context);
    var widget = _selectedTypes.contains(_type)
        ? _image
        : ColorFiltered(colorFilter: greyscaleFilter, child: _image);
    return GestureDetector(
      child: widget,
      onTap: () {
        if (_selectedTypes.contains(_type)) {
          _selectedTypes.remove(_type);
        } else {
          _selectedTypes.add(_type);
        }
        displayState.notify();
      },
    );
  }
}

class AwokenSkillsFilterRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);
    var displayState = Provider.of<MonsterDisplayState>(context);
    var selectedSkills = displayState.filterArgs.awokenSkills;
    var awokenSkills = DatabaseHelper.allAwokenSkills;

    return Column(
      children: [
        Row(
          children: [
            Text(loc.monsterFilterModalAwokens),
            SizedBox(width: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: new BorderRadius.circular(2.0),
                  border: Border.all(),
                  color: grey(context, 200),
                ),
                child: Row(
                  children: [
                    for (var skillId in selectedSkills)
                      Padding(
                          padding: EdgeInsets.all(1), child: awakeningContainer(skillId, size: 16)),
                    Spacer(),
                    Material(
                      color: Colors.transparent,
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: IconButton(
                            padding: EdgeInsets.all(0),
                            onPressed: () {
                              selectedSkills.clear();
                              displayState.showAwakenings = false;
                              displayState.notify();
                            },
                            icon: Icon(Icons.clear)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var skill in awokenSkills)
              AwakeningButton(
                  skill.awokenSkillId, selectedSkills, awakeningContainer(skill.awokenSkillId)),
          ],
        ),
      ],
    );
  }
}

class AwakeningButton extends StatelessWidget {
  final int _awakening;
  final List<int> _selectedAwakenings;
  final Widget _image;
  const AwakeningButton(this._awakening, this._selectedAwakenings, this._image, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var displayState = Provider.of<MonsterDisplayState>(context);
    return GestureDetector(
      child: _image,
      onTap: () {
        if (_selectedAwakenings.length >= 9) {
          return;
        }

        _selectedAwakenings
          ..add(_awakening)
          ..sort();

        displayState.showAwakenings = true;

        displayState.notify();
      },
    );
  }
}

class ActiveSkillTagsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);
    var displayState = Provider.of<MonsterDisplayState>(context);
    return SkillTagsRow(
      title: loc.monsterFilterModalActiveSkills,
      tagHolder: displayState.filterArgs.activeTags,
      tagOptions: DatabaseHelper.allActiveSkillTags,
    );
  }
}

class LeaderSkillTagsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);
    var displayState = Provider.of<MonsterDisplayState>(context);
    return SkillTagsRow(
      title: loc.monsterFilterModalLeaderSkills,
      tagHolder: displayState.filterArgs.leaderTags,
      tagOptions: DatabaseHelper.allLeaderSkillTags,
    );
  }
}

class SkillTagsRow extends StatelessWidget {
  final String title;
  final Set<dynamic> tagHolder;
  final List<dynamic> tagOptions;

  const SkillTagsRow({Key key, this.title, this.tagHolder, this.tagOptions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var displayState = Provider.of<MonsterDisplayState>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title),
        GridView.count(
          padding: EdgeInsets.all(8),
          crossAxisCount: 2,
          childAspectRatio: 8 / 1,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            for (var tag in tagOptions)
              ToggleTagButton(
                tagHolder.contains(tag),
                LanguageSelector.name(tag).call(),
                () {
                  if (tagHolder.contains(tag)) {
                    tagHolder.remove(tag);
                  } else {
                    tagHolder.add(tag);
                  }
                  displayState.notify();
                },
              ),
          ],
        )
      ],
    );
  }
}

class ToggleTagButton extends FlatButton {
  final bool _selected;
  final String _text;
  final VoidCallback _selectedOnPressed;

  ToggleTagButton(this._selected, this._text, this._selectedOnPressed);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: _selected ? Colors.lightBlueAccent : grey(context, 200),
      textColor: _selected ? grey(context, 0) : grey(context, 1000),
      child: FittedBox(child: Text(_text)),
      onPressed: _selectedOnPressed,
    );
  }
}
