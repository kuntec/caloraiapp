import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final InAppPurchase _iap = InAppPurchase.instance;

  final Set<String> _productIds = {
    'premium_monthly',
    'premium_yearly',
  };

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _subscription = _iap.purchaseStream.listen(
      _listenToPurchaseUpdated,
      onDone: () => _subscription?.cancel(),
      onError: (error) {
        debugPrint('purchase stream error: $error');
      },
    );

    _initStore();
  }

  Future<void> _initStore() async {
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) {
      setState(() => _loading = false);
      return;
    }

    final response = await _iap.queryProductDetails(_productIds);
    if (response.error != null) {
      debugPrint('query error: ${response.error}');
    }

    setState(() {
      _products = response.productDetails;
      _loading = false;
    });
  }

  void _buy(ProductDetails product) {
    final purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
    // For subscriptions, the plugin uses store subscription products.
  }

  Future<void> _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        debugPrint('pending');
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        // Send purchaseDetails.verificationData to your backend
        // Backend verifies with Apple/Google and activates subscription
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        debugPrint('error: ${purchaseDetails.error}');
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await _iap.completePurchase(purchaseDetails);
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAvailable) {
      return const Scaffold(
        body: Center(child: Text('Store not available')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Subscriptions')),
      body: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return ListTile(
            title: Text(product.title),
            subtitle: Text(product.description),
            trailing: Text(product.price),
            onTap: () => _buy(product),
          );
        },
      ),
    );
  }
}
