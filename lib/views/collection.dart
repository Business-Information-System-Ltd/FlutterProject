import 'package:advance_budget_request_system/views/budgetamounts.dart';
import 'package:advance_budget_request_system/views/budgetinformation.dart';
import 'package:advance_budget_request_system/views/projecttable.dart';
import 'package:advance_budget_request_system/views/tripForm.dart';
import 'package:advance_budget_request_system/views/triptable.dart';
import 'package:flutter/material.dart';

class Collection extends StatefulWidget {
  const Collection({super.key});

  @override
  State<Collection> createState() => _CollectionState();
}

class _CollectionState extends State<Collection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 110, 184, 112),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=> BudgetForm() ));
              }, 
              child: const Text("Budget Information")
              
              ),
              const SizedBox(height: 20,),
        
            ElevatedButton(
              onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=> BudgetAmount() ));
              }, 
              child: const Text("Budget Amount")
              
              ),
              const SizedBox(height: 20,),
            
            ElevatedButton(
              onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=> ProjectInformation() ));
              }, 
              child: const Text("Project Request")
              
              ),
              const SizedBox(height: 20,),
        
          ElevatedButton(
              onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=> TripInformation(currentUser: UserModel(name: "David", department: "Admin"),tripId: "0", ) ));
              }, 
              child: const Text("Trip Request")
              
              ),
              const SizedBox(height: 20,),
          
        
          ],
        ),
      ),
    );
  }
}