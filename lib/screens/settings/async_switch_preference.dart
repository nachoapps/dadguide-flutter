import 'package:flutter/material.dart';
import 'package:preferences/preference_service.dart';

/// Similar to SwitchPreference, except the pref value is expected to be toggled when enable/disable
/// complete.
class AsyncSwitchPreference extends StatefulWidget {
  final String title;
  final String desc;
  final String localKey;
  final bool defaultVal;
  final bool ignoreTileTap;

  final Function onEnable;
  final Function onDisable;
  final Function onChange;

  final bool disabled;

  final Color switchActiveColor;

  AsyncSwitchPreference(
    this.title,
    this.localKey, {
    this.desc,
    this.defaultVal = false,
    this.ignoreTileTap = false,
    this.onEnable,
    this.onDisable,
    this.onChange,
    this.disabled = false,
    this.switchActiveColor,
  });

  @override
  _AsyncSwitchPreferenceState createState() => _AsyncSwitchPreferenceState();
}

class _AsyncSwitchPreferenceState extends State<AsyncSwitchPreference> {
  bool _stateDisabled = false;

  @override
  void initState() {
    super.initState();
    if (PrefService.getBool(widget.localKey) == null) {
      PrefService.setBool(widget.localKey, widget.defaultVal);
    }
  }

  bool _isDisabled() {
    return _stateDisabled || widget.disabled;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.title),
      subtitle: widget.desc == null ? null : Text(widget.desc),
      trailing: Switch.adaptive(
        value: PrefService.getBool(widget.localKey) ?? widget.defaultVal,
        activeColor: widget.switchActiveColor,
        onChanged: _isDisabled() ? null : (val) => val ? onEnable() : onDisable(),
      ),
      onTap: (_isDisabled() || widget.ignoreTileTap)
          ? null
          : () => (PrefService.getBool(widget.localKey) ?? widget.defaultVal)
              ? onDisable()
              : onEnable(),
    );
  }

  Future<void> onEnable() async {
    setState(() {
      _stateDisabled = true;
    });
    try {
      if (widget.onChange != null) widget.onChange();
      if (widget.onEnable != null) {
        try {
          await widget.onEnable();
        } catch (e) {
          if (mounted) PrefService.showError(context, e.message as String);
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _stateDisabled = false;
        });
      }
    }
  }

  Future<void> onDisable() async {
    setState(() {
      _stateDisabled = true;
    });
    try {
      if (widget.onChange != null) widget.onChange();
      if (widget.onDisable != null) {
        try {
          await widget.onDisable();
        } catch (e) {
          if (mounted) PrefService.showError(context, e.message as String ?? 'An error occurred');
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _stateDisabled = false;
        });
      }
    }
  }
}
