import 'package:dadguide2/components/images/images.dart';
import 'package:dadguide2/components/models/data_objects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

/// A header-tabbed screen displaying events.
class ExchangeTabbedViewWidget extends StatelessWidget {
  final List<FullExchange> data;

  ExchangeTabbedViewWidget(this.data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      initialIndex: 0,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: ExchangeHeaderWidget(),
        ),
        body: Padding(
          padding: const EdgeInsets.all(4.0),
          child: ExchangeTabViewWidget(data),
        ),
      ),
    );
  }
}

/// The event tab header.
class ExchangeHeaderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Row(
        children: [
          SizedBox(width: 48),
          Flexible(
            child: TabBar(tabs: [
              Tab(text: 'Event'),
              Tab(text: 'Collab'),
              Tab(text: 'Gem'),
              Tab(text: 'Enhance'),
            ]),
          ),
        ],
      ),
    );
  }
}

/// The tab contents.
class ExchangeTabViewWidget extends StatelessWidget {
  final List<FullExchange> data;
  ExchangeTabViewWidget(this.data);

  @override
  Widget build(BuildContext context) {
    return TabBarView(children: [
      SingleChildScrollView(child: ExchangeViewWidget(_prepList((fem) => fem.isEvent))),
      SingleChildScrollView(child: ExchangeViewWidget(_prepList((fem) => fem.isCollab))),
      SingleChildScrollView(child: ExchangeViewWidget(_prepList((fem) => fem.isGem))),
      SingleChildScrollView(child: ExchangeViewWidget(_prepList((fem) => fem.isEnhance))),
    ]);
  }

  List<FullExchange> _prepList(bool Function(FullExchange) accept) {
    return data.where(accept).toList()..sort((l, r) => l.exchange.orderIdx - r.exchange.orderIdx);
  }
}

/// Displays a list of Events, chunked into sections by type.
class ExchangeViewWidget extends StatelessWidget {
  final List<FullExchange> data;

  ExchangeViewWidget(this.data);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (ctx, idx) => ExchangeWidget(data[idx]),
        separatorBuilder: (ctx, idx) => Divider(),
        itemCount: data.length);
  }
}

class ExchangeWidget extends StatelessWidget {
  final FullExchange em;

  ExchangeWidget(this.em);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        PadIcon(em.exchange.targetMonsterId, monsterLink: true),
        VerticalDivider(),
        Text('${em.exchange.requiredCount} of'),
        SizedBox(width: 8),
        for (var fodderId in em.fodderIds.take(4))
          Padding(
            padding: EdgeInsets.only(left: 4),
            child: PadIcon(fodderId, monsterLink: true),
          ),
        if (em.fodderIds.length > 4)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(Feather.plus),
          ),
      ],
    );
  }
}
