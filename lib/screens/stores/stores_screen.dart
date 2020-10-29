import 'package:flutter/material.dart';
import 'package:lojaronilson/common/custom_drawer.dart';
import 'package:lojaronilson/models/stores_manager.dart';
import 'package:lojaronilson/screens/stores/components/store_card.dart';
import 'package:provider/provider.dart';

class StoresScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: const Text('Lojas'),
        centerTitle: true,
      ),
      body: Consumer<StoresManager>(
        builder: (_, storesManager, __){
          if(storesManager.stores.isEmpty){
            return LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
              backgroundColor: Colors.transparent,
            );
          }

          return ListView.builder(
            itemCount: storesManager.stores.length,
            itemBuilder: (_, index){
              return StoreCard(storesManager.stores[index]);
            },
          );
        },
      ),
    );
  }
}