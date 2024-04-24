import 'package:collapsible/collapsible.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    print("SAVED FORMS " + savedForms.toString());

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
    print("UNREACHABLE UUIDS: " + unreachableUUIDs.toString());
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
          "Welcome Back"
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

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: () {
                    navigateTo(context, ViewForm(generatedForm: generatedForm));
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            style: standardTextStyle(),
                            "${generatedForm.emoji}  ${generatedForm.name}"
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                responseListViewStatuses[formJson] = !responseListViewStatuses[formJson]!;
                              });
                            },
                            icon: !responseListViewStatuses[formJson]!?
                              const Icon(Icons.expand_more) :
                              const Icon(Icons.expand_less)
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Collapsible(
                  collapsed: !responseListViewStatuses[formJson]!,
                  fade: true,
                  curve: Curves.easeInOut,
                  axis: CollapsibleAxis.vertical,
                  child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8),
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
                  ),
                ),
              ],
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
