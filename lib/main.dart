
import 'package:advance_budget_request_system/views/budgetcodeview.dart';
import 'package:advance_budget_request_system/views/data.dart';
import 'package:advance_budget_request_system/views/login.dart';
import 'package:advance_budget_request_system/views/settlementTable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:advance_budget_request_system/views/permission.dart'; 

void main(){
  runApp(
    // ChangeNotifierProvider(
    //   create: (context) => UserProvider(),
    //   child: const MaterialApp(
    //   debugShowCheckedModeBanner: false,
    // //  home: Dashboard(),
    //  home: Login(),
    // )
    // )
    const MaterialApp(
      home: const Budgetcodeview(),
      debugShowCheckedModeBanner: false,
    )
  );
}