import 'package:advance_budget_request_system/views/login.dart';
import 'package:advance_budget_request_system/views/settlement.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:advance_budget_request_system/views/permission.dart'; 
import 'package:advance_budget_request_system/views/cashpaymentsettlemententry.dart';
import 'package:advance_budget_request_system/views/advancerequestlist.dart';

void main(){
  runApp(
    // ChangeNotifierProvider(
    //   create: (context) => UserProvider(),
    //   child: const MaterialApp(
    //   debugShowCheckedModeBanner: false,
    // //  home: Dashboard(),
    //  home: Login(),
    // )
    //)
    MaterialApp(
      
      //home:SettlementPage(),
      home:PaymentPage(),
      //home:AdvanceRequestPage(),
     // home: AdvanceRequestPage(),
      debugShowCheckedModeBanner: false,
    )
  );
}