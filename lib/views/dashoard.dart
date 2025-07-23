// import 'package:advance_budget_request_system/views/advanceRequest.dart';
// import 'package:advance_budget_request_system/views/approvalsetup.dart';
// import 'package:advance_budget_request_system/views/budgetAmount.dart';
// import 'package:advance_budget_request_system/views/budgetcodeview.dart';
// import 'package:advance_budget_request_system/views/budgetinformation.dart';
// import 'package:advance_budget_request_system/views/cashPayment.dart';
// import 'package:advance_budget_request_system/views/data.dart';
// import 'package:advance_budget_request_system/views/login.dart';
// import 'package:advance_budget_request_system/views/permission.dart';
// import 'package:advance_budget_request_system/views/project.dart';
// import 'package:advance_budget_request_system/views/projecttable.dart';
// import 'package:advance_budget_request_system/views/trip.dart';
// import 'package:advance_budget_request_system/views/tripForm.dart';
// import 'package:advance_budget_request_system/views/triptable.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class Dashboard extends StatefulWidget {
//   final Map<String, dynamic> userData;
//   const Dashboard({super.key, required this.userData});

//   @override
//   State<Dashboard> createState() => _DashboardState();
// }

// class _DashboardState extends State<Dashboard>
//     with SingleTickerProviderStateMixin {
//   late AnimationController controller;
//   bool isMenuBar = false;
//   // ignore: unused_field
//   int _selectedIndex = 0;
//   final PageController _pageController = PageController();
//   late String userName;
//   late String userEmail;
//   late String department;
//   late String role;

//   late List<Widget> _widgetOptions = <Widget>[
//     DashboardView(department: department),
//      BudgetForm(),
//     const Budgetamount(),
//     ProjectInformation(),
//     // TripInformation(),
//     //  Advancerequest(userData: widget.userData,),
//     const Cashpayment(),
//     // const Settlement(),
//     ApprovalSetupStep(),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     userName = widget.userData['UserName'];
//     userEmail = widget.userData['User_Email'] ?? '';
//     department = widget.userData['Department_Name'] ?? '';
//     role = widget.userData['Role'] ?? '';
//     controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }

//   void _toggleMenuBar() {
//     setState(() {
//       if (isMenuBar) {
//         controller.reverse();
//       } else {
//         controller.forward();
//       }
//       isMenuBar = !isMenuBar;
//     });
//   }

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//       _pageController.jumpToPage(index);
//       _toggleMenuBar();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final department = Provider.of<UserProvider>(context).department;

//     List<Widget> pages = [];

//     if (department == 'HR' ||
//         department == 'Marketing' ||
//         department == 'Engineering') {
//       pages = [ProjectInfo(), const TripInfo(),  
//       // Advancerequest(userData: widget.userData)
//       ];
//     } else if (department == 'Finance') {
//       pages = [
//         ProjectInfo(),
//         const TripInfo(),
//         //  Advancerequest(userData: widget.userData,),
//         const Cashpayment(),
//         // Settlement()
//       ];
//     } else if (department == 'Admin') {
//       pages = [
//         DashboardView(department: department),
//         const Budgetcodeview(),
//         const Budgetamount(),
//         ProjectInfo(),
//         const TripInfo(),
//         //  Advancerequest(userData: widget.userData,),
//         const Cashpayment(),
//         // const Settlement(),
//         ApprovalSetupStep(),
//       ];
//     }

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color.fromRGBO(100, 207, 198, 0.855),
//         title: const Text("Advance Budget Request System"),
//         leading: IconButton(
//           onPressed: _toggleMenuBar,
//           icon: AnimatedIcon(
//             icon: AnimatedIcons.menu_close,
//             progress: controller,
//           ),
//         ),
//         actions: [
//           Row(
//             children: [
//               IconButton(
//                   onPressed: () {
//                     showDialog(
//                         context: context,
//                         builder: (BuildContext context) {
//                           final screenWidth = MediaQuery.of(context).size.width;
//                           final screenHeight =
//                               MediaQuery.of(context).size.height;
//                           return Stack(
//                             children: [
//                               Positioned(
//                                   left: screenWidth * 0.4,
//                                   top: screenHeight / 25 * 1,
//                                   // height: screenHeight * 0.2,
//                                   child: SizedBox(
//                                     width: screenWidth * 0.8,
//                                     child: Dialog(
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(10),
//                                       ),
//                                       child: SizedBox(
//                                         width:
//                                             MediaQuery.of(context).size.width *
//                                                 0.2,
//                                         child: Padding(
//                                           padding: const EdgeInsets.only(
//                                               left: 10, top: 10),
//                                           child: Column(
//                                             mainAxisSize: MainAxisSize.min,
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceEvenly,
//                                             children: [
//                                               ClipRRect(
//                                                 borderRadius:
//                                                     BorderRadius.circular(50.0),
//                                                 // child: Image.asset(
//                                                 //   "images/Kayla-Person.png",
//                                                 //   width: 70,
//                                                 //   height: 70,
//                                                 //   fit: BoxFit.cover,
//                                                 // ),
//                                                 child: CircleAvatar(
//                                                   radius: 35,
//                                                   backgroundColor:
//                                                       Colors.deepPurple[100],
//                                                   child: Text(
//                                                     userName.isNotEmpty
//                                                         ? userName[0]
//                                                             .toUpperCase()
//                                                         : '',
//                                                     style: const TextStyle(
//                                                       fontSize: 30,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       color: Colors.black,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                               const Divider(),
//                                               Row(
//                                                 children: [
//                                                   const Text("Name  "),
//                                                   const Text(
//                                                     " - ",
//                                                     style:
//                                                         TextStyle(fontSize: 30),
//                                                   ),
//                                                   Text(userName)
//                                                 ],
//                                               ),
//                                               Row(
//                                                 children: [
//                                                   const Text("Email "),
//                                                   const Text(
//                                                     " - ",
//                                                     style:
//                                                         TextStyle(fontSize: 30),
//                                                   ),
//                                                   Text(userEmail)
//                                                 ],
//                                               ),
//                                               Row(
//                                                 children: [
//                                                   const Text('Department'),
//                                                   const Text(
//                                                     ' - ',
//                                                     style:
//                                                         TextStyle(fontSize: 30),
//                                                   ),
//                                                   Text(department)
//                                                 ],
//                                               ),
//                                               Row(
//                                                 children: [
//                                                   const Text('Role '),
//                                                   const Text(
//                                                     ' - ',
//                                                     style:
//                                                         TextStyle(fontSize: 30),
//                                                   ),
//                                                   Text(role)
//                                                 ],
//                                               ),
//                                               Padding(
//                                                 padding: const EdgeInsets.only(
//                                                     top: 8.0, bottom: 10.0),
//                                                 child: ElevatedButton(
//                                                     onPressed: () {
//                                                       Navigator.push(
//                                                           context,
//                                                           MaterialPageRoute(
//                                                               builder: (context) =>
//                                                                   const Login()));
//                                                       ScaffoldMessenger.of(
//                                                               context)
//                                                           .showSnackBar(
//                                                               const SnackBar(
//                                                                   content: Text(
//                                                                       "LogOut successfully!!")));
//                                                     },
//                                                     child:
//                                                         const Text("LogOut")),
//                                               ),
//                                               const SizedBox(
//                                                 height: 10,
//                                               )
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ))
//                             ],
//                           );
//                         });
//                   },
//                   icon: const Icon(Icons.person)),
//               Text(userName),
//               SizedBox(
//                 width: MediaQuery.of(context).size.width / 45,
//               )
//             ],
//           )
//         ],
//       ),
//       body: Container(
//         color: Colors.green,
//         child: Stack(
//           children: [
//             AnimatedPositioned(
//               duration: const Duration(milliseconds: 300),
//               left: isMenuBar ? 0 : -200, // Adjust the width as per your drawer
//               top: 0,
//               bottom: 0,
//               child: Container(
//                   width: 200,
//                   color: Colors.white,
//                   child: SizedBox(
//                     child: CustomDrawer(onItemTapped: _onItemTapped,userData: widget.userData,),
//                   )),
//             ),
//             AnimatedPositioned(
//                 duration: const Duration(milliseconds: 300),
//                 left: isMenuBar ? 200 : 0,
//                 right: 0,
//                 top: 0,
//                 bottom: 0,
//                 child: PageView(
//                   controller: _pageController,
//                   physics: const NeverScrollableScrollPhysics(),
//                   onPageChanged: (index) {
//                     setState(() {
//                       _selectedIndex = index;
//                     });
//                   },
//                   children: _widgetOptions,
//                 )),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class CustomDrawer extends StatefulWidget {
//   final ValueChanged<int> onItemTapped;
//   final Map<String, dynamic> userData;

//   const CustomDrawer({super.key, required this.onItemTapped, required this.userData});

//   @override
//   State<CustomDrawer> createState() => _CustomDrawerState();
// }

// class _CustomDrawerState extends State<CustomDrawer> {
//   @override
//   Widget build(BuildContext context) {
//     final department = Provider.of<UserProvider>(context).department;
//     final List<Widget> menuItems = [];
//     int _selectedIndex = 0;

//     late List<Widget> _widgetOptions = <Widget>[
//       DashboardView(department: department),
//       const Budgetcodeview(),
//       const Budgetamount(),
//       ProjectInfo(),
//       const TripInfo(),
//       //  Advancerequest(userData: widget.userData,),
//       const Cashpayment(),
//       // const Settlement(),
//       ApprovalSetupStep(),
//     ];

//     if (department == 'HR' ||
//         department == 'Marketing' ||
//         department == 'Engineering') {
//       menuItems.addAll([
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: ListTile(
//             title: const Text("Project Information"),
//             onTap: () => widget.onItemTapped(3),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: ListTile(
//             title: const Text("Trip Information"),
//             onTap: () => widget.onItemTapped(4),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: ListTile(
//             title: const Text("Advance Request"),
//             onTap: () => widget.onItemTapped(5),
//           ),
//         ),
//       ]);
//     } else if (department == 'Finance') {
//       menuItems.addAll([
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: ListTile(
//             title: const Text("Project Information"),
//             onTap: () => widget.onItemTapped(3),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: ListTile(
//             title: const Text("Trip Information"),
//             onTap: () => widget.onItemTapped(4),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: ListTile(
//             title: const Text("Advance Request"),
//             onTap: () => widget.onItemTapped(5),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: ListTile(
//             title: const Text("Cash Payment"),
//             onTap: () => widget.onItemTapped(6),
//           ),
//         ),
//         // ListTile(
//         //   title: const Text("Settlement"),
//         //   onTap: () => widget.onItemTapped(7),
//         // ),
//       ]);
//     } else if (department == 'Admin') {
//       menuItems.addAll([
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: ListTile(
//             title: const Text("Dashboard"),
//             onTap: () => widget.onItemTapped(0),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: ListTile(
//             title: const Text("Budget Code"),
//             onTap: () => widget.onItemTapped(1),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0),
//           child: ListTile(
//               title: const Text('Budget Amount'),
//               onTap: () => widget.onItemTapped(2)),
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0),
//           child: ListTile(
//               title: const Text('Project Information'),
//               onTap: () => widget.onItemTapped(3)),
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0),
//           child: ListTile(
//               title: const Text('Trip Information'),
//               onTap: () => widget.onItemTapped(4)),
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0),
//           child: ListTile(
//               title: const Text('Advance Request'),
//               onTap: () => widget.onItemTapped(5)),
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0),
//           child: ListTile(
//               title: const Text('Cash Payment'),
//               onTap: () => widget.onItemTapped(6)),
//         ),
//         // Padding(
//         //   padding: const EdgeInsets.symmetric(vertical: 8.0),
//         //   child: ListTile(
//         //       title: const Text('Settlement'),
//         //       onTap: () => widget.onItemTapped(7)),
//         // ),
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0),
//           child: ListTile(
//               title: const Text('Approval SetUp'),
//               onTap: () => widget.onItemTapped(8)),
//         ),
//       ]);
//     }

//     return Drawer(
//       child: Container(
//         color: Colors.white,
//         width: MediaQuery.of(context).size.width / 2,
//         child: SingleChildScrollView(
//           child: Column(
//             children: menuItems,
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Dashboard
// class DashboardView extends StatefulWidget {
//   final String department;
//   const DashboardView({super.key, required this.department});

//   @override
//   State<DashboardView> createState() => _DashboardViewState();
// }

// class _DashboardViewState extends State<DashboardView> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           double containerWidth = constraints.maxWidth;
//           bool isSmallScreen = constraints.maxWidth < 700;

//           return SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Container(
//               width:
//                   isSmallScreen ? constraints.maxWidth / 0.55 : containerWidth,
//               child: Column(
//                 // mainAxisAlignment: MainAxisAlignment.center,
//                 // crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(0.0),
//                     child: Image(
//                       image: const AssetImage("images/budget-approvals.png"),
//                       width: MediaQuery.of(context).size.width,
//                       // height: MediaQuery.of(context).size.height,
//                     ),
//                   ),
//                   Container(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text(
//                           'Department: ',
//                           style: TextStyle(
//                               fontSize: 16, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 10),
//                         Text(
//                           widget.department,
//                           style: const TextStyle(
//                             fontSize: 20, fontWeight: FontWeight.bold
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class LimitedDashboard extends StatelessWidget {
//   final Map<String, dynamic> userData;

//   const LimitedDashboard({super.key, required this.userData});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Dashboard(userData: userData),
//     );
//   }
// }
import 'package:advance_budget_request_system/views/advanceRequest.dart';
import 'package:advance_budget_request_system/views/approvalsetup.dart';
// import 'package:advance_budget_request_system/views/budgetAmount.dart';
import 'package:advance_budget_request_system/views/budgetamounts.dart';
import 'package:advance_budget_request_system/views/budgetcodeview.dart';
import 'package:advance_budget_request_system/views/budgetinformation.dart';
import 'package:advance_budget_request_system/views/cashPayment.dart';
import 'package:advance_budget_request_system/views/login.dart';
import 'package:advance_budget_request_system/views/project.dart';
import 'package:advance_budget_request_system/views/projecttable.dart';
import 'package:advance_budget_request_system/views/trip.dart';
import 'package:advance_budget_request_system/views/tripForm.dart';
import 'package:advance_budget_request_system/views/triptable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  bool isMenuBar = false;
 
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  

  final List<Widget> _widgetOptions = <Widget>[
     BudgetForm(),
    BudgetAmount(),
    ProjectInformation(),
    TripInformation(currentUser: UserModel(name: 'Riel', department: 'Admin'),tripId: '0',),
    const Cashpayment(),
    ApprovalSetupStep(),
  ];

  @override
  void initState() {
    super.initState();
   
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _toggleMenuBar() {
    setState(() {
      if (isMenuBar) {
        controller.reverse();
      } else {
        controller.forward();
      }
      isMenuBar = !isMenuBar;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
      _toggleMenuBar();
    });
  }

  @override
  Widget build(BuildContext context) {
      

    List<Widget> pages = [];

  
      pages = [
        const Budgetcodeview(),
         BudgetAmount(),
        ProjectInfo(),
        TripInformation(currentUser: UserModel(name: 'Riel', department: 'Admin'),tripId: '0',),
        const Cashpayment(),
        // const Settlement(),
        ApprovalSetupStep(),
      ];
    // }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(100, 207, 198, 0.855),
        title: const Text("Advance Budget Request System"),
        leading: IconButton(
          onPressed: _toggleMenuBar,
          icon: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: controller,
          ),
        ),
        actions: [
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          final screenWidth = MediaQuery.of(context).size.width;
                          final screenHeight =
                              MediaQuery.of(context).size.height;
                          return Stack(
                            children: [
                              Positioned(
                                  left: screenWidth * 0.4,
                                  top: screenHeight / 25 * 1,
                                  // height: screenHeight * 0.2,
                                  child: SizedBox(
                                    width: screenWidth * 0.8,
                                    child: Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.2,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, top: 10),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              
                                              const Divider(),
                                              Row(
                                                children: [
                                                  const Text("Name  "),
                                                  const Text(
                                                    " - ",
                                                    style:
                                                        TextStyle(fontSize: 30),
                                                  ),
                                                  Text('')
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  const Text("Email "),
                                                  const Text(
                                                    " - ",
                                                    style:
                                                        TextStyle(fontSize: 30),
                                                  ),
                                                  Text('')
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  const Text('Department'),
                                                  const Text(
                                                    ' - ',
                                                    style:
                                                        TextStyle(fontSize: 30),
                                                  ),
                                                  Text('')
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  const Text('Role '),
                                                  const Text(
                                                    ' - ',
                                                    style:
                                                        TextStyle(fontSize: 30),
                                                  ),
                                                  Text('')
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0, bottom: 10.0),
                                                child: ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const Login()));
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              const SnackBar(
                                                                  content: Text(
                                                                      "LogOut successfully!!")));
                                                    },
                                                    child:
                                                        const Text("LogOut")),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ))
                            ],
                          );
                        });
                  },
                  icon: const Icon(Icons.person)),
              Text(''),
              SizedBox(
                width: MediaQuery.of(context).size.width / 45,
              )
            ],
          )
        ],
      ),
      body: Container(
        color: Colors.green,
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              left: isMenuBar ? 0 : -200, 
              top: 0,
              bottom: 0,
              child: Container(
                  width: 200,
                  color: Colors.white,
                  child: SizedBox(
                    child: CustomDrawer(onItemTapped: _onItemTapped),
                  )),
            ),
            AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                left: isMenuBar ? 200 : 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  children: _widgetOptions,
                )),
          ],
        ),
      ),
    );
  }
}

class CustomDrawer extends StatefulWidget {
  final ValueChanged<int> onItemTapped;


  const CustomDrawer({super.key, required this.onItemTapped});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    final List<Widget> menuItems = [];
    int _selectedIndex = 0;

    late List<Widget> _widgetOptions = <Widget>[
       BudgetForm(),
      BudgetAmount(),
      ProjectInformation(),
      const TripInfo(),
      const Cashpayment(),
      ApprovalSetupStep(),
    ];

   
      menuItems.addAll([
       
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            title: const Text("Budget Code"),
            onTap: () => widget.onItemTapped(0),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
              title: const Text('Budget Amount'),
              onTap: () => widget.onItemTapped(1)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
              title: const Text('Project Information'),
              onTap: () => widget.onItemTapped(2)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
              title: const Text('Trip Information'),
              onTap: () => widget.onItemTapped(3)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
              title: const Text('Advance Request'),
              onTap: () => widget.onItemTapped(4)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
              title: const Text('Cash Payment'),
              onTap: () => widget.onItemTapped(5)),
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
              title: const Text('Approval SetUp'),
              onTap: () => widget.onItemTapped(6)),
        ),
      ]);
    // }

    return Drawer(
      child: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width / 2,
        child: SingleChildScrollView(
          child: Column(
            children: menuItems,
          ),
        ),
      ),
    );
  }
}

// Dashboard
class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double containerWidth = constraints.maxWidth;
          bool isSmallScreen = constraints.maxWidth < 700;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width:
                  isSmallScreen ? constraints.maxWidth / 0.55 : containerWidth,
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Image(
                      image: const AssetImage("images/budget-approvals.png"),
                      width: MediaQuery.of(context).size.width,
                      // height: MediaQuery.of(context).size.height,
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Department: ',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '',
                          style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class LimitedDashboard extends StatelessWidget {
  final Map<String, dynamic> userData;

  const LimitedDashboard({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Dashboard(),
    );
  }
}
