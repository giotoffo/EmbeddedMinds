import 'package:flutter/material.dart';

//SCREENS
import 'package:project_app1/screens/homepage.dart';

//PROVIDERS
import '../providers/profile_provider.dart';

//PLUG IN
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:provider/provider.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({Key? key}) : super(key: key);

  //static const routename = 'Homepage';
  @override
  State<Onboarding> createState() => _OnboardingState();
}

// Variables for temporary storage of user input
class _OnboardingState extends State<Onboarding> {
  late TextEditingController nameController;
  late TextEditingController surnameController;
  String? tempAge;
  String? tempGender;
  bool tempIsPregnant = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    surnameController = TextEditingController();

    final profile = Provider.of<ProfileProvider>(context, listen: false);
    profile.loadFromPrefs().then((_) {
      setState(() {
        nameController.text = profile.name;
        surnameController.text = profile.surname;
        tempAge = profile.age;
        tempGender = profile.gender;
        tempIsPregnant = profile.isPregnant;
      });
    });
  }

  // To avoid memory leaks, dispose the controllers
  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 249, 244, 252),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 249, 244, 252),
        title: Text(
          'Settings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Avatar mostrato in base al sesso
              Image.asset(
                tempGender == 'F'
                    ? 'immagini/avatar_F.png'
                    : tempGender == 'M'
                    ? 'immagini/avatar_M.png'
                    : 'immagini/avatar_null.png',
                width: 200,
                height: 200,
              ),

              const SizedBox(height: 20),

              // Input name
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.black),
                ),
                onChanged: (value) {},
              ),

              const SizedBox(height: 20),

              // Input surname
              TextField(
                controller: surnameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  labelText: 'Surname',
                  labelStyle: TextStyle(color: Colors.black),
                ),
                onChanged: (value) {},
              ),

              const SizedBox(height: 20),

              // Row for age and sex
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        isExpanded: true,
                        hint: Text(
                          'Age',
                          style: TextStyle(fontSize: 15, color: Colors.black),
                        ),
                        items:
                            List.generate(80, (index) => (index + 1).toString())
                                .map(
                                  (String item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        value:
                            List.generate(
                                  80,
                                  (index) => (index + 1).toString(),
                                ).contains(tempAge)
                                ? tempAge
                                : null,
                        onChanged: (value) {
                          setState(() {
                            tempAge = value;
                          });
                        },
                        buttonStyleData: ButtonStyleData(
                          height: 55,
                          padding: const EdgeInsets.only(left: 2, right: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Color.fromARGB(255, 128, 128, 128),
                            ),
                            color: Color.fromARGB(255, 249, 244, 252),
                          ),
                        ),
                        iconStyleData: IconStyleData(
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 20,
                          iconEnabledColor: Colors.black,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: GenderSelector(
                      initialGender: tempGender,
                      onGenderSelected: (gender) {
                        setState(() {
                          tempGender = gender;
                          if (gender != 'F') tempIsPregnant = false;
                        });
                      },
                    ),
                  ),
                ],
              ),
              if (tempGender == 'F')
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('Pregnant?', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 6),
                      Switch(
                        value: tempIsPregnant,
                        onChanged: (value) {
                          setState(() {
                            tempIsPregnant = value;
                          });
                        },
                        activeColor: Color.fromARGB(255, 240, 100, 147),
                        inactiveTrackColor: Color.fromARGB(255, 249, 244, 252),
                      ),
                    ],
                  ),
                ),

              const Spacer(), // Space to push buttons to the bottom
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              title: Text("Confirm deletion"),
                              content: Text(
                                "Are you sure you want to delete all your data?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text("Confirm"),
                                ),
                              ],
                            ),
                      );

                      if (confirm == true) {
                        profile.clearProfile();
                        await profile.saveToPrefs();
                        setState(() {
                          nameController.clear();
                          surnameController.clear();
                          tempGender = null;
                          tempAge = null;
                          tempIsPregnant = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("All data cleared")),
                        );
                      }
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[300],
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Clear all',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color.fromARGB(255, 249, 244, 252),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10), // Space between buttons

                  ElevatedButton(
                    onPressed: () async {
                      profile.setName(nameController.text);
                      profile.setSurname(surnameController.text);
                      profile.setGender(tempGender ?? '');
                      profile.setAge(tempAge ?? '');
                      profile.setPregnant(tempIsPregnant);
                      await profile.saveToPrefs();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Data are saved!")),
                      );
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => HomePage()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[400],
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color.fromARGB(255, 249, 244, 252),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GenderSelector extends StatelessWidget {
  final Function(String) onGenderSelected;
  final String? initialGender;

  const GenderSelector({
    Key? key,
    required this.onGenderSelected,
    this.initialGender,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GenderButton(
            label: 'M',
            selected: initialGender == 'M',
            onTap: () => onGenderSelected('M'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GenderButton(
            label: 'F',
            selected: initialGender == 'F',
            onTap: () => onGenderSelected('F'),
          ),
        ),
      ],
    );
  }
}

class GenderButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const GenderButton({
    Key? key,
    required this.label,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color =
        label == 'F'
            ? (selected
                ? const Color.fromARGB(255, 240, 100, 147)
                : const Color.fromARGB(255, 249, 244, 252))
            : (selected
                ? const Color.fromARGB(255, 87, 172, 241)
                : const Color.fromARGB(255, 249, 244, 252));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey),
        ),
        child: Center(child: Text(label, style: const TextStyle(fontSize: 17))),
      ),
    );
  }
}
