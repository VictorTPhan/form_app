import 'package:animate_do/animate_do.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:collapsible/collapsible.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:form_app/create_form.dart';
import 'package:form_app/misc.dart';
import 'package:form_app/response.dart';
import 'package:form_app/view_form.dart';
import 'package:get_storage/get_storage.dart';

import 'generated_form.dart';
import 'generated_response.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Map of JSON -> List<String>
  // Form JSON -> Response UUIDs
  Map<Map<String, dynamic>, List<String>> displayForms = {};

  // Used to keep track of which form response ListViews are being shown
  Map<Map<String, dynamic>, bool> responseListViewStatuses = {};

  late final box;
  int delayIncrease = 200;
  late int delay = -delayIncrease;

  @override
  initState() {
    box = GetStorage();
    fetchSavedData();
  }

  void fetchSavedData() {
    displayForms.clear();
    responseListViewStatuses.clear();

    // add a reference to this entry in a list
    List<dynamic> savedForms = box.read("SAVED_FORMS") ?? [];
    // print("SAVED FORMS " + savedForms.toString());

    List<String> unreachableUUIDs = [];
    for (String formUUID in savedForms) {
      var searchResult = box.read(formUUID);
      if (searchResult == null) {
        unreachableUUIDs.add(formUUID);
        continue;
      } else {
        displayForms[searchResult] = [];
        responseListViewStatuses[searchResult] = false;

        List<dynamic> responses = box.read("$formUUID/responses") ?? [];
        for (String responseUUID in responses) {
          var responseExists = box.read(responseUUID);
          if (responseExists != null){
            displayForms[searchResult]!.add(responseUUID);
          } else {
            unreachableUUIDs.add(responseUUID);
          }
        }
      }
    }
    // print("UNREACHABLE UUIDS: " + unreachableUUIDs.toString());
  }

  Future<void> fetchSavedDataSetState() async {
    setState(() {
      fetchSavedData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text(
          style: standardTextStyle(fontSize: 25),
          "Welcome Back!"
        ),
      ),
      body: EasyRefresh(
        onRefresh: fetchSavedDataSetState,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(8),
          itemCount: displayForms.keys.length,
          itemBuilder: (BuildContext context, int fIndex) {
            Map<String, dynamic> formJson = displayForms.keys.elementAt(fIndex);
            var generatedForm = GeneratedForm.fromJson(formJson);
            List<String> responseUUIDs = displayForms[formJson]!;

            delay += delayIncrease;

            return FadeInLeft(
              delay: Duration(milliseconds: delay),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      navigateTo(context, ViewForm(generatedForm: generatedForm));
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: gradients[generatedForm.colorIndex],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  style: standardTextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ).copyWith(
                                    overflow: TextOverflow.ellipsis
                                  ),
                                  "${generatedForm.emoji}  ${generatedForm.name}"
                                ),
                              ),
                              if (responseUUIDs.isNotEmpty)
                                IconButton(
                                  color: Colors.white,
                                  onPressed: () {
                                    setState(() {
                                      responseListViewStatuses[formJson] = !responseListViewStatuses[formJson]!;
                                    });
                                  },
                                  icon: !responseListViewStatuses[formJson]!?
                                    const Icon(Icons.expand_more) :
                                    const Icon(Icons.expand_less)
                                )
                              else
                                SizedBox.fromSize(size: const Size(50, 50))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.90,
                        child: Collapsible(
                          collapsed: !responseListViewStatuses[formJson]!,
                          fade: true,
                          curve: Curves.easeInOut,
                          axis: CollapsibleAxis.vertical,
                          child: FadeInDown(
                            from: 10,
                            duration: Duration(milliseconds: 200),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: responseUUIDs.length,
                              itemBuilder: (BuildContext context, int rIndex) {
                                final response = GeneratedResponse.fromJson(box.read(responseUUIDs[rIndex]));

                                return GestureDetector(
                                  onTap: () {
                                    navigateTo(context, ResponsePage(responseUUID: responseUUIDs[rIndex]));
                                  },
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: AnimatedTextKit(
                                        isRepeatingAnimation: false,
                                        animatedTexts: [
                                          TypewriterAnimatedText(
                                            speed: const Duration(milliseconds: 50),
                                            textStyle: standardTextStyle(),
                                            "${response.emoji}  ${response.name}"
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          navigateTo(context, CreateForm());
        },
      ),
    );
  }
}
