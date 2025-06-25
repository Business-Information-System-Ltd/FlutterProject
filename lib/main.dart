import 'package:advance_budget_request_system/views/budgetUISample.dart';
import 'package:advance_budget_request_system/views/cashpaymentEntry.dart';
import 'package:advance_budget_request_system/views/cashpaymentsettlemententry.dart';

import 'package:flutter/material.dart';


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
      
      home: AdvancePage(),
      //home:AdvanceRequestPage(),
     // home: AdvanceRequestPage(),
      debugShowCheckedModeBanner: false,
    )
  );
}