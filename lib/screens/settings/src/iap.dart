import 'package:dadguide2/components/firebase/analytics.dart';
import 'package:dadguide2/components/firebase/src/ads.dart';
import 'package:dadguide2/components/utils/streams.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:flutter_icons/flutter_icons.dart';

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
        var available = AdStatusManager.instance.iapAvailable;

        if (product == null || !available) {
          return ListTile(
            title: Text('Error'),
            leading: Icon(Icons.error, color: Colors.red),
            subtitle: Text('IAP is disabled. Tap to try again.'),
            onTap: () async {
              try {
                final init = await AdStatusManager.instance.populateIap();
                if (!init) {
                  Scaffold.of(context).showSnackBar(
                      SnackBar(content: Text('An error occurred. Are you logged in?')));
                }
              } catch (ex) {
                Fimber.e('Error trying to re-init on demand', ex: ex);
              }
            },
          );
        }

        return Column(
          children: <Widget>[
            ListTile(
              onTap: () async {
                iapRestoreClicked();
                await AdStatusManager.instance.populatePurchases();
                if (AdStatusManager.instance.getAdRemovalPurchase() == null) {
                  Scaffold.of(context).showSnackBar(SnackBar(content: Text(loc.iapRestoreError)));
                }
              },
              title: Text(loc.iapRestoreTitle),
              trailing: Icon(FontAwesome.get_pocket),
              subtitle: Text(loc.iapRestoreSubtitle),
            ),
            ListTile(
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
            ),
          ],
        );
      },
    );
  }
}
