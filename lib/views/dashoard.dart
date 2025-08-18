import 'package:advance_budget_request_system/views/advanceRequest.dart';
import 'package:advance_budget_request_system/views/advancerequestlist.dart';
import 'package:advance_budget_request_system/views/approvalsetup.dart';
import 'package:advance_budget_request_system/views/approvaltable.dart';
// import 'package:advance_budget_request_system/views/budgetAmount.dart';
import 'package:advance_budget_request_system/views/budgetamounts.dart';
import 'package:advance_budget_request_system/views/budgetcodeview.dart';
import 'package:advance_budget_request_system/views/budgetinformation.dart';
import 'package:advance_budget_request_system/views/cashPayment.dart';
import 'package:advance_budget_request_system/views/cashpaymentpage.dart';
import 'package:advance_budget_request_system/views/login.dart';
import 'package:advance_budget_request_system/views/project.dart';
import 'package:advance_budget_request_system/views/projecttable.dart';
import 'package:advance_budget_request_system/views/settlement.dart';
import 'package:advance_budget_request_system/views/settlementTable.dart';
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
    const ProjectInformation(),
    TripInformation(currentUser: UserModel(name: 'Riel', department: 'Admin'),tripId: '0',),
    AdvanceRequestPage(),
     CashPaymentPage(),
     SettlementTable(),
    ApprovalSetupList(),
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
        const SettlementTable(),
        ApprovalSetupList(),
      ];
    // }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(100, 207, 198, 0.855),
        toolbarHeight: 45,
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
                                              const Row(
                                                children: [
                                                  Text("Name  "),
                                                  Text(
                                                    " - ",
                                                    style:
                                                        TextStyle(fontSize: 30),
                                                  ),
                                                  Text('')
                                                ],
                                              ),
                                              const Row(
                                                children: [
                                                  Text("Email "),
                                                  Text(
                                                    " - ",
                                                    style:
                                                        TextStyle(fontSize: 30),
                                                  ),
                                                  Text('')
                                                ],
                                              ),
                                              const Row(
                                                children: [
                                                  Text('Department'),
                                                  Text(
                                                    ' - ',
                                                    style:
                                                        TextStyle(fontSize: 30),
                                                  ),
                                                  Text('')
                                                ],
                                              ),
                                              const Row(
                                                children: [
                                                  Text('Role '),
                                                  Text(
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
              const Text(''),
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
      const ProjectInformation(),
      const TripInfo(),
      AdvanceRequestPage(),
       CashPaymentPage(),
       SettlementTable(),
      ApprovalSetupList(),
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
              title: const Text('Settlement'),
              onTap: () => widget.onItemTapped(6)),
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
              title: const Text('Approval SetUp'),
              onTap: () => widget.onItemTapped(7)),
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
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Department: ',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '',
                          style: TextStyle(
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
    return const Scaffold(
      body: Dashboard(),
    );
  }
}
