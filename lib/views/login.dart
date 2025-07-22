import 'dart:convert';
import 'package:advance_budget_request_system/views/data.dart';
import 'package:advance_budget_request_system/views/api_service.dart';
import 'package:advance_budget_request_system/views/permission.dart';
import 'package:http/http.dart' as http;
import 'package:advance_budget_request_system/views/dashoard.dart';
import 'package:advance_budget_request_system/views/register.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final List<Department> departments = [];
  String? _selectedDepartment;
  String? _selectedDepartmentId;

  final _formkey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _isObscured = true;
  bool _isLoading = false;

@override
void initState() {
  super.initState();
  fetchDepartments(); 
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: const Color.fromARGB(255, 100, 131, 84),
        child: Row(
          children: [
            Container(
              // color: const Color.fromARGB(255, 83, 107, 62),
              color:  Colors.grey.shade50,
              width: MediaQuery.of(context).size.width / 7 * 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image(
                  image: const AssetImage("images/login.png"),
                  width: MediaQuery.of(context).size.width / 7 * 2,
                  height: MediaQuery.of(context).size.height / 7 * 7,
                ),
              ),
            ),
            Expanded(
                child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Center(
                    child: Text(
                      "Login An Account",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, top: 10),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 7 * 5,
                    child: Column(
                      children: [
                        Form(
                            key: _formkey,
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(
                                    Icons.email_outlined,
                                    color: Colors.black,
                                    size: 40,
                                  ),
                                  title: TextFormField(
                                    controller: _emailController,
                                    decoration: const InputDecoration(
                                      labelText: "Enter Your Email",
                                      labelStyle:
                                          TextStyle(color: Colors.white),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.white, width: 2.0),
                                      ),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    autofillHints: [AutofillHints.username],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Enter Your Email";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                ListTile(
                                    leading: const Icon(
                                      Icons.apartment,
                                      color: Colors.black,
                                      size: 40,
                                    ),
                                    title: DropdownButtonFormField(
                                      value: _selectedDepartment,
                                      decoration: const InputDecoration(
                                          labelText: "Choose Your Department",
                                          labelStyle:
                                              TextStyle(color: Colors.white),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.white),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white))),
                                      dropdownColor: Colors.white,
                                      items: departments.map((dept) {
                                        return DropdownMenuItem(
                                           value: dept.departmentCode,
                                          child:
                                              Text(dept.departmentName),
                                          onTap: () {
                                            _selectedDepartmentId = dept
                                                .id
                                                .toString(); 
                                          },
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedDepartment = value;
                                          final dep = departments.firstWhere(
                                              (d) => d.departmentCode == value);
                                          _selectedDepartmentId =
                                              dep.id.toString();
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please select your department!!';
                                        }
                                        return null;
                                      },
                                    )),
                                ListTile(
                                  leading: const Icon(
                                    Icons.key,
                                    color: Colors.black,
                                    size: 40,
                                  ),
                                  title: TextFormField(
                                      controller: _passwordController,
                                      decoration: InputDecoration(
                                        labelText: "Enter Your Password",
                                        labelStyle: const TextStyle(
                                            color: Colors.white),
                                        enabledBorder:
                                            const UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        focusedBorder:
                                            const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 2.0),
                                        ),
                                        suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _isObscured = !_isObscured;
                                              });
                                            },
                                            icon: Icon(
                                              _isObscured
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: Colors.white,
                                            )),
                                      ),
                                      obscureText: _isObscured,
                                      
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please Enter your Password!!";
                                        }
                                        return null;
                                      }),
                                ),
                                ListTile(
                                  title: const Text(
                                    "Create an Account",
                                    style: TextStyle(
                                        color: Colors.lightBlueAccent,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.blue,
                                        decorationThickness: 2.0),
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const RegisterView()));
                                  },
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                ElevatedButton(
                                  onPressed: _loginUser,
                                  style: ButtonStyle(
                                      shape: WidgetStateProperty.all(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0)),
                                      ),
                                      minimumSize: WidgetStateProperty.all(
                                          const Size(150, 50))),
                                  child: const Text(
                                    "Login",
                                    style: TextStyle(
                                        fontFamily: 'Schyler',
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            ))
                      ],
                    ),
                  ),
                )
              ],
            ))
          ],
        ),
      ),
    );
  }

  Future<void> fetchDepartments() async {
    try {
      final apiService = ApiService();
      final response = await apiService.fetchDepartment();
      if (response != null) {
        setState(() {
          departments.clear(); 
          departments.addAll(response);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load departments")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
 Future<void> _loginUser() async {
  final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
  if (_formkey.currentState?.validate() ?? false) {
    if(_selectedDepartmentId == null){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a department")),
      );
      return;
    }
     setState(() {
      _isLoading = true;
    });
    try {
      final apiService = ApiService();
      final userData = await apiService.loginUser(email, password, _selectedDepartmentId!); 
       
      if (userData != null) {
        final hasFullAccess = userData['Role'] == 'Admin'; 
        final department =  userData['Department_Name'];
        Provider.of<UserProvider>(context, listen: false).setDepartment(department);
         
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) =>
        //         hasFullAccess ? Dashboard(userData: userData,)
        //                        : LimitedDashboard(userData: userData,),
        //   ),
        // );
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login Successfully!!")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: Invalid credentials")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
      
    }finally{
      setState(() {
        _isLoading = false;
      });
    }
  }
}

}

