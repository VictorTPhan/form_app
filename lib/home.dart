import 'package:animate_do/animate_do.dart';
import 'package:collapsible/collapsible.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:fluid_dialog/fluid_dialog.dart';
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
  /// The forms that we want to display on this page. Specifically, this is...
  ///
  /// A Map of JSON -> List<String>
  ///
  /// Otherwise, you can think of this as...
  ///
  /// A Form JSON -> A list of response UUIDs for that form
  Map<Map<String, dynamic>, List<String>> displayForms = {};

  /// A [Map] used to keep track of which form response ListViews are being shown
  Map<Map<String, dynamic>, bool> responseListViewStatuses = {};

  /// A reference to the phone's storage.
  late final box;

  /// The amount of milliseconds to increase the delay by every time a widget
  /// is loaded.
  int delayIncrease = 200;

  /// The amount of milliseconds to delay a widget by when it loads.
  late int delay = -delayIncrease;

  @override
  initState() {
    box = GetStorage();
    fetchSavedData();
  }

  /// Fetches the forms and responses from the phone's storage.
  void fetchSavedData() {
    // Reset all of the data on this page
    delay = -delayIncrease;
    displayForms.clear();
    responseListViewStatuses.clear();

    // Attempt to grab a list of saved forms.
    List<dynamic> savedForms = box.read("SAVED_FORMS") ?? [];
    List<String> unreachableUUIDs = [];

    // Loop through all of the form UUIDs.
    for (String formUUID in savedForms) {
      // Attempt to read the form UUID to get its JSON.
      var searchResult = box.read(formUUID);

      // If we can't reach it, it's a dud.
      if (searchResult == null) {
        unreachableUUIDs.add(formUUID);
        continue;
      } else {
        // Update our page data with the form's information
        displayForms[searchResult] = [];
        responseListViewStatuses[searchResult] = false;

        List<dynamic> responses = box.read("$formUUID/responses") ?? [];
        for (String responseUUID in responses) {
          // Attempt to read the response UUIDs.
          var responseExists = box.read(responseUUID);

          // Add each response we can successfully read to displayForms
          if (responseExists != null){
            displayForms[searchResult]!.add(responseUUID);
          } else {
            unreachableUUIDs.add(responseUUID);
          }
        }
      }
    }
  }

  /// A function called once the page is loaded to reload everything.
  Future<void> fetchSavedDataSetState() async {
    setState(() {
      fetchSavedData();
    });
  }

  /// Generates a [ListView] of all of the responses for a form from its
  /// [responseUUIDs].
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

  /// Frames the [ListView] of response widgets into a collapsible and padded [Widget].
  ///
  /// [formJson] - The JSON object representing the form associated to the responses.
  ///
  /// [responseUUIDs] - The list of responses to display.
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

  /// Deletes a form and all of its associated responses.
  ///
  /// [formJson] - The JSON object representing the form to delete.
  ///
  /// [generatedForm] - the [GeneratedForm] representation of the [formJSON].
  ///
  /// [responseUUIDs] - The list of responses associated with the form to delete.
  void deleteForm(Map<String, dynamic> formJson, GeneratedForm generatedForm, List<String> responseUUIDs) {
    // Remove this form from storage.
    box.remove(generatedForm.uuid);

    // Remove this form from the list of saved forms.
    List<dynamic> savedForms = box.read("SAVED_FORMS") ?? [];
    savedForms.remove(generatedForm.uuid);
    box.write("SAVED_FORMS", savedForms);

    // Remove all responses related to this form.
    for (String responseUUID in responseUUIDs) {
      box.remove(responseUUID);
    }

    // Remove the list of responses.
    box.remove("${generatedForm.uuid}/responses");

    // Reload the page.
    fetchSavedDataSetState();
  }

  /// Displays the deletion form alert dialog.
  ///
  /// [formJson] - The JSON object representing the form to delete.
  ///
  /// [generatedForm] - the [GeneratedForm] representation of the [formJSON].
  ///
  /// [responseUUIDs] - The list of responses associated with the form to delete.
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

  /// Displays a widget representing a form that the user has made and saved.
  ///
  /// [formJson] - The JSON object representing the form.
  ///
  /// [generatedForm] - the [GeneratedForm] representation of the [formJSON].
  ///
  /// [responseUUIDs] - The list of responses associated with the form.
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

  /// Displays all of the user's saved forms in a [ListView].
  /// If there are no forms saved, we show a notice [Text] instead.
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
