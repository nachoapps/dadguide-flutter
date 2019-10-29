import 'package:dadguide2/components/enums.dart';
import 'package:dadguide2/components/icons.dart';
import 'package:dadguide2/components/images.dart';
import 'package:dadguide2/data/database.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/screens/monster/monster_search_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Displays a dialog that lets the user toggle their event server, or kick off the update.
Future<void> showMonsterFilterDialog(BuildContext context) async {
  var loc = DadGuideLocalizations.of(context);

  var displayState = Provider.of<MonsterDisplayState>(context);
  var dialogResults = await showDialog(
      context: context,
      builder: (innerContext) {
        return ChangeNotifierProvider.value(
          value: displayState,
          child: SimpleDialog(
            title: Text(loc.monsterFilterModalTitle),
            contentPadding: EdgeInsets.all(8),
            children: [
              FilterWidget(),
            ],
          ),
        );
      });
  displayState.doSearch();
  return dialogResults;
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
        TypeFilterRow(),
        Divider(),
        AwokenSkillsFilterRow(),
        Divider(),
        FilterActionBar(),
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
        ),
        SizedBox(width: 8),
        ActionChip(
          onPressed: () => launch('http://www.puzzledragonx.com/en/monsterbook.asp'),
          label: Text('PDX'),
        ),
        SizedBox(width: 8),
        ActionChip(
          onPressed: () => launch('http://pad.skyozora.com/pets'),
          label: Text('Skyo'),
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
          VerticalDivider(thickness: 1, color: Colors.grey[300]),
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
        : ColorFiltered(
            colorFilter: ColorFilter.mode(Colors.white.withOpacity(.6), BlendMode.hardLight),
            child: _image);
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
          VerticalDivider(thickness: 1, color: Colors.grey[300]),
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
                child: BoxedInput(minMax.min?.toString() ?? '',
                    (v) => minMax.min = v.trim() == '' ? null : int.parse(v))),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text('~'),
            ),
            Flexible(
                child: BoxedInput(minMax.max?.toString() ?? '',
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

  const BoxedInput(this._text, this._onChanged, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.number,
      initialValue: _text,
      onChanged: _onChanged,
      decoration: InputDecoration(
        border: new OutlineInputBorder(borderRadius: new BorderRadius.circular(2.0)),
        focusedBorder: new OutlineInputBorder(borderRadius: new BorderRadius.circular(2.0)),
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        fillColor: Colors.grey[200],
        filled: true,
      ),
    );
  }
}

class TypeFilterRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);
    var displayState = Provider.of<MonsterDisplayState>(context);

    return Column(
      children: [
        Text(loc.monsterFilterModalType),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
        : ColorFiltered(
            colorFilter: ColorFilter.mode(Colors.white.withOpacity(.6), BlendMode.hardLight),
            child: _image);
    return Expanded(
      child: GestureDetector(
        child: widget,
        onTap: () {
          if (_selectedTypes.contains(_type)) {
            _selectedTypes.remove(_type);
          } else {
            _selectedTypes.add(_type);
          }
          displayState.notify();
        },
      ),
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
                  color: Colors.grey[200],
                ),
                child: Row(
                  children: [
                    for (var skillId in selectedSkills)
                      Padding(
                          padding: EdgeInsets.all(1), child: awakeningContainer(skillId, size: 16)),
                    Spacer(),
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: IconButton(
                          // Disable the inkwell, it looks ugly
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          padding: EdgeInsets.all(2),
                          onPressed: () {
                            selectedSkills.clear();
                            displayState.showAwakenings = false;
                            displayState.notify();
                          },
                          icon: Icon(Icons.clear)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 4,
          runSpacing: 4,
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

class FilterActionBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);
    var displayState = Provider.of<MonsterDisplayState>(context);

    return Row(
      children: [
        FlatButton(
          child: Text(loc.monsterFilterModalClose),
          onPressed: () => Navigator.pop(context),
        ),
        Spacer(),
        FlatButton(
          child: Text(loc.monsterFilterModalReset),
          onPressed: () {
            displayState.filterArgs = MonsterFilterArgs();
            displayState.sortType = MonsterSortType.no;
            displayState.sortAsc = false;
            displayState.notify();
          },
        ),
      ],
    );
  }
}
