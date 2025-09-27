
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final internetProvider = StateNotifierProvider<InternetNotifier,InternetState>((ref)=>InternetNotifier());

class InternetState{
  final bool isConnected;

  InternetState({
    this.isConnected = true
  });

  InternetState copyWith({
    bool? isConnected
  }){
    return InternetState(
        isConnected: isConnected ?? this.isConnected
    );
  }
}

class InternetNotifier extends StateNotifier<InternetState>{

  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  InternetNotifier() : super(InternetState()){
    checkConnection();
    _subscription = Connectivity().onConnectivityChanged.listen(updateConnection);
  }


  Future<void> checkConnection()async{
    List<ConnectivityResult> result = await Connectivity().checkConnectivity();
    await updateConnection(result);
  }

  Future<void> updateConnection(List<ConnectivityResult> result)async{
    bool isNowConnected = await result.isNotEmpty && result.any((i)=>i!=ConnectivityResult.none);

    if(isNowConnected!=state.isConnected){
      state = state.copyWith(
        isConnected: isNowConnected
      );
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}