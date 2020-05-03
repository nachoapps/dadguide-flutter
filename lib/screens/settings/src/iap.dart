import 'package:dadguide2/components/firebase/analytics.dart';
import 'package:dadguide2/components/firebase/src/ads.dart';
import 'package:dadguide2/components/utils/streams.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:flutter/material.dart';

class RemoveAdsIapWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loc = DadGuideLocalizations.of(context);

    return SimpleRxStreamBuilder<AdStatus>(
      stream: AdStatusManager.instance.status,
      builder: (context, adStatus) {
        if (adStatus == AdStatus.disabled) {
          return ListTile(
            title: Text(loc.iapAdsRemoved),
            subtitle: Text(loc.iapAdsRemovedSubtitle),
          );
        }
        var product = AdStatusManager.instance.getRemoveAdsProduct();

        if (product == null) {
          return ListTile(
            title: Text('Oops'),
            leading: Icon(Icons.error, color: Colors.red),
            subtitle: Text('Something went wrong; IAP is disabled.'),
          );
        }

        return ListTile(
          onTap: () async {
            iapClicked();
            final result = await AdStatusManager.instance.startPurchaseFlow();
            if (!result) {
              iapClickFailed();
              Scaffold.of(context).showSnackBar(SnackBar(content: Text(loc.iapLaunchFailed)));
            }
          },
          title: Text(product.title),
          trailing: Text(product.price),
          subtitle: Text(product.description),
        );
      },
    );
  }
}
