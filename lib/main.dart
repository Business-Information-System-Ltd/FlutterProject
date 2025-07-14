import 'package:advance_budget_request_system/views/cashpaymentEntry.dart';
import 'package:advance_budget_request_system/views/login.dart';
import 'package:advance_budget_request_system/views/settlement.dart';
import 'package:advance_budget_request_system/views/tripForm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:advance_budget_request_system/views/permission.dart';
import 'package:advance_budget_request_system/views/cashpaymentsettlemententry.dart';
import 'package:advance_budget_request_system/views/advancerequestlist.dart';
import 'package:advance_budget_request_system/views/cashpaymentpage.dart';
import 'package:advance_budget_request_system/views/budgetinformation.dart';
import 'package:advance_budget_request_system/views/budgetamounts.dart';
import 'package:advance_budget_request_system/views/projecttable.dart';
import 'package:advance_budget_request_system/views/triptable.dart';
import 'package:advance_budget_request_system/views/projectentryform.dart';
import 'package:advance_budget_request_system/views/tripentryform.dart';

void main() {
  runApp(
      // ChangeNotifierProvider(
      //   create: (context) => UserProvider(),
      //   child: const MaterialApp(
      //   debugShowCheckedModeBanner: false

      //  home: Dashboard(),
      //  home: Login(),
      // )
      //)
      MaterialApp(
    //home:SettlementPage(),
    // home:PaymentPage(),
    //home:CashPaymentPage(),
    //home: AdvanceRequestPage(),
    // home: BudgetForm(),
   //home:BudgetAmount(),
   //home: ProjectInformation(),
    // home: AddProjectForm(),
    home:TripInformation(currentUser: UserModel(name: 'MM', department: 'Admin'),tripId: "0"),
    // home:TripEntryForm(),
    //home:AdvancePage(),
   // home: TripRequestForm(currentUser: UserModel(name: 'MM', department: 'Admin'), tripId: 0),
   
 
    debugShowCheckedModeBanner: false,
  ));
}
