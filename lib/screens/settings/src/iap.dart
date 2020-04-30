import 'package:dadguide2/components/firebase/src/ads.dart';
import 'package:dadguide2/components/utils/streams.dart';
import 'package:flutter/material.dart';

class RemoveAdsIapWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SimpleRxStreamBuilder<AdStatus>(
      stream: AdStatusManager.instance.status,
      builder: (context, adStatus) {
        if (adStatus == AdStatus.disabled) {
          return ListTile(
            title: Text('Ads removed'),
            subtitle: Text('Thanks for supporting DadGuide!'),
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
            final result = await AdStatusManager.instance.startPurchaseFlow();
            if (!result) {
              Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text('Failed to start purchase')));
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
