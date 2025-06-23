import 'dart:math';

import 'package:advance_budget_request_system/views/api_service.dart';
import 'package:advance_budget_request_system/views/data.dart';
import 'package:advance_budget_request_system/views/login.dart';
import 'package:flutter/material.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  List<Department> department = [];
  List<User> user = [];
  String? _selectedDepartment;
  String? _selectedDepartmentId;

  final List<String> roles = ["Manager", "MD", "Staff"];
  String? _selectedRole;
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isObscured = true;

  @override
  void initState() {
    _fetchData();
    super.initState();
      loadDepartments();

  }
  void loadDepartments() async {
  try {
    final data = await ApiService().fetchDepartment();
    setState(() {
      department = data; 
    });
  } catch (e) {
    print("Error loading departments: $e");
  }
}

  void _fetchData() async {
    try {
      List<Department> departments = await ApiService().fetchDepartment();
      List<User> users = await ApiService().fetchUser();
      setState(() {
        department = departments;
        user = users;
      });
    } catch (e) {
      print("Fail to load: $e");
      print("Fetched departments: ${department.length}");
    }
  }

  String? passwordValidation(String value) {
    String pattern =
        r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
    RegExp regex = RegExp(pattern);
    if (value.isEmpty) {
      return 'Please Enter Your Password';
    } else if (!regex.hasMatch(value)) {
      return 'Your Password must include at least 8 characters.\n The password must also include an uppercase, lowercase letters, number, and special character';
    }
    return null;
  }

  //generated ID
  String generateRandomId(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    Random rnd = Random();
    return List.generate(length, (_) => chars[rnd.nextInt(chars.length)])
        .join();
  }

  void _submitForm() async {
  if (_formkey.currentState!.validate()) {
    try {
      final selectedDeptCode = _selectedDepartment;
      if (selectedDeptCode == null || selectedDeptCode.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a department")),
        );
        return;
      }

      Department? selectedDep;
      try {
        selectedDep = department.firstWhere(
          (dept) => dept.departmentCode == _selectedDepartment,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Selected department not found")),
        );
        return;
      }

      final userData = {
        'username': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'role': _selectedRole,
        'departmentId': selectedDep.id,
      };

      await ApiService().registerUser(userData); // <-- this now sends the correct format

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful!")),
      );
    } catch (e) {
      print("Failed to register user: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: ${e.toString()}")),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Color.fromARGB(255, 111, 139, 97),
        child: Row(
          children: [
            Container(
              // color: const Color.fromARGB(255, 83, 107, 62),
              color: Colors.grey.shade50,
              width: MediaQuery.of(context).size.width / 7 * 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image(
                  image: const AssetImage("images/register.png"),
                  width: MediaQuery.of(context).size.width / 7 * 2,
                  height: MediaQuery.of(context).size.height / 7 * 7,
                ),
              ),
            ),
            Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Center(
                      child: Text(
                        "Create An Account",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30, top: 10),
                    child: SingleChildScrollView(
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
                                      Icons.person,
                                      color: Colors.black,
                                      size: 40,
                                    ),
                                    title: TextFormField(
                                      controller: _nameController,
                                      decoration: const InputDecoration(
                                        labelText: "Enter Your Name",
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
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please Enter Your Name';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
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
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please Enter Your Email";
                                        }
                                        final emailRegex = RegExp(
                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                        if (!emailRegex.hasMatch(value)) {
                                          return 'Please Enter a Vaild Email Address';
                                        }
                                        if (user.any(
                                            (u) => u.email == value.trim())) {
                                          return 'This email is already exist!!';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        if (_formkey.currentState != null) {
                                          _formkey.currentState!.validate();
                                        }
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
                                        items: department.map((dept) {
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
                                            final dep = department.firstWhere(
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
                                        Icons.layers,
                                        color: Colors.black,
                                        size: 40,
                                      ),
                                      title: DropdownButtonFormField(
                                        decoration: const InputDecoration(
                                            labelText: "Choose Your Role",
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
                                        items: roles.map((role) {
                                          return DropdownMenuItem(
                                              value: role, child: Text(role));
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedRole = value;
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
                                            return 'Please select your role!!';
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
                                        labelStyle:
                                            const TextStyle(color: Colors.white),
                                        enabledBorder: const UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        focusedBorder: const UnderlineInputBorder(
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
                                      validator: (value) =>
                                          passwordValidation(value!),
                                    ),
                                  ),
                                  ListTile(
                                    title: const Text(
                                      "Login an Account",
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
                                                  const Login()));
                                    },
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  ElevatedButton(
                                    onPressed: _submitForm,
                                    style: ButtonStyle(
                                        shape: WidgetStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0)),
                                        ),
                                        minimumSize: WidgetStateProperty.all(
                                            const Size(150, 50))),
                                    child: const Text(
                                      "Submit",
                                      style: TextStyle(
                                          fontFamily: 'Schyler',
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                                ],
                              ),
                ))
          ],
        ),
      ),
    );
  }
}
