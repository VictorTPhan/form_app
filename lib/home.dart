import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:collapsible/collapsible.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:fluid_dialog/fluid_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
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
    delay = -delayIncrease;
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

  Widget displayResponseBar(List<String> responseUUIDs) {
    return ListView.builder(
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
                child: Text(
                  style: standardTextStyle(),
                  "${response.emoji}  ${response.name}"
                ),
              ),
            ),
          );
        }
    );
  }

  Widget displayResponseList(Map<String, dynamic> formJson, List<String> responseUUIDs) {
    return Padding(
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
                duration: const Duration(milliseconds: 200),
                child: displayResponseBar(responseUUIDs)
            ),
          ),
        ),
      ),
    );
  }

  void deleteForm(Map<String, dynamic> formJson, GeneratedForm generatedForm, List<String> responseUUIDs) {
    // remove this form
    box.remove(generatedForm.uuid);

    // remove this form from saved_forms
    List<dynamic> savedForms = box.read("SAVED_FORMS") ?? [];
    savedForms.remove(generatedForm.uuid);
    box.write("SAVED_FORMS", savedForms);

    // remove all responses related to this form
    for (String responseUUID in responseUUIDs) {
      box.remove(responseUUID);
    }

    // remove the list of responses
    box.remove("${generatedForm.uuid}/responses");

    fetchSavedDataSetState();
  }

  void displayFormDeletionDialog(Map<String, dynamic> formJson, GeneratedForm generatedForm, List<String> responseUUIDs) {
    showDialog(
      context: context,
      builder: (context) => FluidDialog(
        // Set the first page of the dialog.
        rootPage: FluidDialogPage(
          alignment: Alignment.center, //Aligns the dialog to the bottom left.
          builder: (context) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeIn(
                    child: Text(
                        style: standardTextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        "Form Deletion"
                    ),
                  ),
                  FadeIn(
                    child: Text(
                        textAlign: TextAlign.center,
                        style: standardTextStyle(),
                        "Do you want to delete ${generatedForm.emoji} ${generatedForm.name}? This will also delete all associated with it."
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            deleteForm(formJson, generatedForm, responseUUIDs);
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green
                          ),
                          child: Text(
                            style: standardTextStyle(
                              color: Colors.white
                            ),
                            "Go ahead"
                          )
                      ),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent
                          ),
                          child: Text(
                              style: standardTextStyle(
                                  color: Colors.white
                              ),
                              "Nevermind"
                          )
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ), // This can be any widget.
        ),
      ),
    );
  }

  Widget displayFormBar(Map<String, dynamic> formJson, GeneratedForm generatedForm, List<String> responseUUIDs) {
    return GestureDetector(
      onTap: () {
        navigateTo(context, ViewForm(generatedForm: generatedForm));
      },
      onLongPress: () {
        displayFormDeletionDialog(formJson, generatedForm, responseUUIDs);
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
    );
  }

  Widget getMainBody() {
    if (displayForms.isNotEmpty) {
      return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(8),
          itemCount: displayForms.keys.length,
          itemBuilder: (BuildContext context, int fIndex) {
            Map<String, dynamic> formJson = displayForms.keys.elementAt(fIndex);
            GeneratedForm generatedForm = GeneratedForm.fromJson(formJson);
            List<String> responseUUIDs = displayForms[formJson]!;

            delay += delayIncrease;

            return FadeInLeft(
              delay: Duration(milliseconds: delay),
              child: Column(
                children: [
                  displayFormBar(formJson, generatedForm, responseUUIDs),
                  displayResponseList(formJson, responseUUIDs)
                ],
              ),
            );
          }
      );
    } else {
      return ListView(
        children: [
          FadeIn(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                style: standardTextStyle(),
                "You don't have any forms made right now. Try making one below."
              ),
            ),
          )
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: FadeInDown(
          child: Text(
            style: standardTextStyle(fontSize: 25),
            "Welcome Back!"
          ),
        ),
      ),
      body: EasyRefresh(
        onRefresh: fetchSavedDataSetState,
        child: getMainBody()
      ),
      floatingActionButton: FadeInUp(
        child: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            navigateTo(context, CreateForm());
          },
        ),
      ),
    );
  }
}
